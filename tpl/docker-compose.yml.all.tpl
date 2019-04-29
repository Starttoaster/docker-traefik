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
    labels:
      - traefik.enable=true
      - traefik.port=8080
      - traefik.frontend.rule=Host:dash.%%DOMAIN%%
  # Dokuwiki
  wiki:
    container_name: dokuwiki
    image: mprasil/dokuwiki
    restart: always
    networks:
      - srv
    ports:
      - "8081:80"
    volumes:
      - /opt/wiki/data/:/dokuwiki/data
      - /opt/wiki/conf/:/dokuwiki/conf
      - /opt/wiki/lib/plugins/:/dokuwiki/lib/plugins
      - /opt/wiki/lib/tpl/:/dokuwiki/lib/tpl
      - /opt/wiki/logs/:/dokuwiki/var/log
    labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:doku.%%DOMAIN%%
  # Dynamic DNS
  ddns:
    container_name: ddns
    image: qmcgaw/ddns-updater
    restart: unless-stopped
    networks:
      - srv
    ports:
      - "8000:8000"
    environment:
      - DELAY=300
      - LISTENINGPORT=8000
      - RECORD1=%%DOMAIN%%,*,namecheap,opendns,%%DNSPASS%%
      - RECORD2=%%DOMAIN%%,@,namecheap,opendns,%%DNSPASS%%
      - RECORD3=%%DOMAIN%%,www,namecheap,opendns,%%DNSPASS%%
    labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:ddns.%%DOMAIN%%
#
# This example is assuming you're using Namecheap DNS as I am.
# This DDNS image has configuration instructions from the owner here: https://github.com/qdm12/ddns-updater
# If you entered your dynamic DNS password when the script was ran, this should already be properly configured.
#
networks:
  srv:
