#!/bin/bash

sudo mkdir /apps /apps/traefik /apps/wiki /apps/wiki/data /apps/wiki/conf /apps/wiki/lib /apps/wiki/lib/plugins /apps/wiki/lib/tpl /apps/wiki/logs
sudo touch /apps/docker-compose.yml /apps/traefik/acme.json /apps/traefik/traefik.toml
sudo chmod 600 /apps/traefik/acme.json
sudo chown -R $USER: /apps/

cat <<EOF >/apps/docker-compose.yml
version: '2'
services:

#Reverse Proxy and LetsEncrypt
  traefik:
    container_name: traefik
    image: traefik:alpine
    restart: always
    networks:
      - srv
    ports:
      - 80:80
      - 443:443
    volumes:
      - /apps/traefik/traefik.toml:/traefik.toml
      - /var/run/docker.sock:/var/run/docker.sock
      - /apps/traefik/acme.json:/acme.json

#Dokuwiki
  wiki:
    container_name: dokuwiki
    image: mprasil/dokuwiki:2018-04-22b
    restart: always
    networks:
      - srv
    ports:
      - "8082:80"
    volumes:
      - /apps/wiki/data/:/dokuwiki/data
      - /apps/wiki/conf/:/dokuwiki/conf
      - /apps/wiki/lib/plugins/:/dokuwiki/lib/plugins
      - /apps/wiki/lib/tpl/:/dokuwiki/lib/tpl
      - /apps/wiki/logs/:/dokuwiki/var/log
    labels:
      - traefik.enable=true
      - "traefik.frontend.rule=Host:SUB.DOMAIN.TLD"
# Change the line after Host:   ex. doku.myawesomewebsite.com

networks:
   srv:

#OPTIONAL!! Only for if you are configuring Dynamic DNS. This example is assuming you're using namecheap.
#You should only need to change the DOMAIN.TLD field, and the key at the end to the one provided by Namecheap.
#You will need to set up three A+ Records with Namecheap that have the same values you put for the regular DNS setup
#Except the server IP in each A+ Record will be 127.0.0.1, and then will automatically be changed by the below container.
# ddns:
#   container_name: ddns
#   image: qmcgaw/ddns-updater
#   restart: unless-stopped
#   network_mode: bridge
#   ports:
#     - "8000:8000"
#   environment:
#     - DELAY=300
#     - LISTENINGPORT=8000
#     - RECORD1=DOMAIN.TLD,*,namecheap,opendns,98da23132wsa54dwdr4524234
#     - RECORD2=DOMAIN.TLD,@,namecheap,opendns,sdfghrsdfdsfdasadssdadsads
#     - RECORD3=DOMAIN.TLD,www,namecheap,opendns,234233wasd24daw18dad5f123asd
EOF

cat <<EOF >/apps/traefik/traefik.toml
[entryPoints]
  [entryPoints.http]
    address = ":80"
      [entryPoints.http.redirect]
        entryPoint = "https"
  [entryPoints.https]
    address = ":443"
      [entryPoints.https.tls]

[docker]
endpoint = "unix:///var/run/docker.sock"
domain = "YOURWEBSITE.TLD"
exposedByDefault = false
watch = true

[acme]
email = "YOUREMAIL@EMAIL.COM"
storage = "acme.json"
entryPoint = "https"
onHostRule = true
  [acme.httpChallenge]
  entryPoint = "http"
EOF

cd /apps
