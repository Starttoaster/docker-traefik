#!/bin/bash
#
# Configure Traefik Reverse-Proxy.
#

#
# Functions
#
function setup {
	read -p "What is your domain name? " -r DOMAIN
	read -p "What is your email address? " -r EMAIL
	echo
	
	if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
	    echo "Please enter domain name and email address" 1>&2
	    exit 1
	fi

	sudo -- mkdir -p /opt/traefik /opt/wiki/{conf,data,logs} /opt/wiki/lib/{plugins,tpl}
	sudo -- touch /opt/traefik/docker-compose.yml /opt/traefik/acme.json /opt/traefik/traefik.yml
	sudo -- chmod 0600 /opt/traefik/acme.json
	sudo -- chown -R "$USER": /opt/traefik /opt/wiki
}

#
# Script main
#
setup

sed -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.yml.tpl >/opt/traefik/traefik.yml
sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.tpl >/opt/traefik/docker-compose.yml

cat <<"EOF"

This script has set up your docker-compose.yml file and Traefik configuration in your /opt/traefik directory.
EOF
