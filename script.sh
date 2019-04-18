#!/bin/bash

#Ask for user input
echo "What is your domain name? "
read -r domain
echo -e "\nWhat is your email? "
read -r email

#Set up directories, files, permissions, and ownership
sudo mkdir /apps /apps/traefik /apps/wiki /apps/wiki/data /apps/wiki/conf /apps/wiki/lib /apps/wiki/lib/plugins /apps/wiki/lib/tpl /apps/wiki/logs
sudo touch /apps/docker-compose.yml /apps/traefik/acme.json /apps/traefik/traefik.toml
sudo chmod 600 /apps/traefik/acme.json
sudo chown -R "$USER": /apps/
cd /apps

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
      - "traefik.frontend.rule=Host:doku.$domain"

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
#     - RECORD1=$domain,*,namecheap,opendns,98da23132wsa54dwdr4524234
#     - RECORD2=$domain,@,namecheap,opendns,sdfghrsdfdsfdasadssdadsads
#     - RECORD3=$domain,www,namecheap,opendns,234233wasd24daw18dad5f123asd
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
domain = "$domain"
exposedByDefault = false
watch = true

[acme]
email = "$email"
storage = "acme.json"
entryPoint = "https"
onHostRule = true
  [acme.httpChallenge]
  entryPoint = "http"
EOF
echo "This script has set up your docker-compose.yml document and Traefik configuration in /apps at your Linux root directory. It also set up an example DokuWiki container with the requisite Traefik labels for a subdomain under the reverse-proxy. Please check your files, make any needed changes, and run 'docker-compose up -d' to start your containers."
