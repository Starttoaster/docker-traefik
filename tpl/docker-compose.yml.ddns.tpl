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
    restart: always
    networks:
      - srv
    ports:
      - "8000:8000"
    volumes:
      - /opt/ddns:/updater/data
    labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:ddns.%%DOMAIN%%

networks:
   srv:

