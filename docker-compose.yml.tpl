version: "2"

services:
  # Reverse Proxy and Let's Encrypt
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
      - /opt/traefik/traefik.toml:/traefik.toml
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/traefik/acme.json:/acme.json
  # Dokuwiki
  wiki:
    container_name: dokuwiki
    image: mprasil/dokuwiki:2018-04-22b
    restart: always
    networks:
      - srv
    ports:
      - "8080:80"
    volumes:
      - /opt/wiki/data/:/dokuwiki/data
      - /opt/wiki/conf/:/dokuwiki/conf
      - /opt/wiki/lib/plugins/:/dokuwiki/lib/plugins
      - /opt/wiki/lib/tpl/:/dokuwiki/lib/tpl
      - /opt/wiki/logs/:/dokuwiki/var/log
    labels:
      - traefik.enable=true
      - "traefik.frontend.rule=Host:doku.%%DOMAIN%%"
networks:
   srv:

# OPTIONAL!! Only for if you are configuring Dynamic DNS. This example is assuming you're using namecheap.
# You should only need to change the DOMAIN.TLD field, and the key at the end to the one provided by Namecheap.
# You will need to set up three A+ Records with Namecheap that have the same values you put for the regular DNS setup
# Except the server IP in each A+ Record will be 127.0.0.1, and then will automatically be changed by the below container.
#
#ddns:
#  container_name: ddns
#  image: qmcgaw/ddns-updater
#  restart: unless-stopped
#  network_mode: bridge
#  ports:
#    - "8000:8000"
#  environment:
#    - DELAY=300
#    - LISTENINGPORT=8000
#    - RECORD1=%%DOMAIN%%,*,namecheap,opendns,98da23132wsa54dwdr4524234
#    - RECORD2=%%DOMAIN%%,@,namecheap,opendns,sdfghrsdfdsfdasadssdadsads
#    - RECORD3=%%DOMAIN%%,www,namecheap,opendns,234233wasd24daw18dad5f123asd
