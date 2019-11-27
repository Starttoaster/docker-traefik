version: "2"

services:
  # Reverse Proxy and Let's Encrypt
  traefik:
    container_name: traefik:v2.0
    image: traefik
    restart: always
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /opt/traefik/traefik.yml:/traefik.yml
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/traefik/acme.json:/acme.json
  # Dokuwiki
  wiki:
    container_name: dokuwiki
    image: mprasil/dokuwiki
    restart: unless-stopped
    networks:
      - proxy
    ports:
      - "8080:80"
    volumes:
      - /opt/wiki/data/:/dokuwiki/data
      - /opt/wiki/conf/:/dokuwiki/conf
      - /opt/wiki/lib/plugins/:/dokuwiki/lib/plugins
      - /opt/wiki/lib/tpl/:/dokuwiki/lib/tpl
      - /opt/wiki/logs/:/dokuwiki/var/log
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dokuwiki.entrypoints=http"
      - "traefik.http.routers.dokuwiki.rule=Host(`doku.%%DOMAIN%%`)"
      - "traefik.http.middlewares.dokuwiki-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.dokuwiki.middlewares=dokuwiki-https-redirect"
      - "traefik.http.routers.dokuwiki-secure.entrypoints=https"
      - "traefik.http.routers.dokuwiki-secure.rule=Host(`doku.%%DOMAIN%%`)"
      - "traefik.http.routers.dokuwiki-secure.tls=true"
      - "traefik.http.routers.dokuwiki-secure.tls.certresolver=http"
      - "traefik.http.routers.dokuwiki-secure.service=dokuwiki"
      - "traefik.http.services.dokuwiki.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"

networks:
   proxy:
