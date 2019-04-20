#!/bin/bash
#
# Configure Traefik Reverse-Proxy.
#

# User input
read -p "What is your domain name? " -r DOMAIN
echo
read -p "What is your email address? " -r EMAIL
echo

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Please enter domain name and email address" 1>&2
    exit 1
fi

# Directory and file permissions, and ownership
sudo -- mkdir -p /opt/traefik /opt/wiki/{conf,data,logs} /opt/wiki/lib/{plugins,tpl}
sudo -- touch /opt/traefik/docker-compose.yml /opt/traefik/acme.json /opt/traefik/traefik.toml
sudo -- chmod 0600 /opt/traefik/acme.json
sudo -- chown -R "$USER": /opt/traefik

sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./docker-compose.yml.tpl >/opt/traefik/docker-compose.yml

read -p "Would you like to set up user/password for all containers behind Traefik (y/n)? " -r CHOICE
case "${CHOICE:0:1}" in
    y|Y)
        read -p "Please enter your htpasswd string here. See README for more information." -r HTPASSWORD
        sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./traefik-htpasswd.toml.tpl >/opt/traefik/traefik.toml
        ;;
    *)
        sed -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./traefik.toml.tpl >/opt/traefik/traefik.toml
        ;;
esac

cat <<"EOF"
This script has set up your docker-compose.yml file and Traefik configuration in /opt/traefik directory.
It also set up an example DokuWiki container with the required Traefik labels for a subdomain under the reverse-proxy.
Please check your files, make any needed changes, and run 'docker-compose up -d' to start your containers.
EOF
