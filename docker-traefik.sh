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
	sudo -- touch /opt/traefik/docker-compose.yml /opt/traefik/acme.json /opt/traefik/traefik.toml
	sudo -- chmod 0600 /opt/traefik/acme.json
	sudo -- chown -R "$USER": /opt/traefik /opt/wiki
}

function ddns_setup {
	#Directory setup
	sudo -- mkdir /opt/ddns
	sudo -- touch /opt/ddns/config.json
	sudo -- chown -R "$USER": /opt/ddns
	sudo -- chmod 700 /opt/ddns

	# Choose provider	
	shopt -s nocasematch
	read -p "What DNS provider are you using? (namecheap/duckdns/godaddy/dreamhost/cloudflare) " -r PROVIDER
	case "${PROVIDER}" in
		namecheap)
			namecheap_setup
			;;
		duckdns)
			duckdns_setup
			;;
		godaddy)
			godaddy_setup
			;;
		dreamhost)
			dreamhost_setup
			;;
		cloudflare)
			cloudflare_setup
			;;
		*)
			echo "Invalid choice; try again."
			ddns_setup
			;;
	esac
	shopt -u nocasematch

        # Read only access for config.json
	sudo -- chmod 400 /opt/ddns/config.json
}

function namecheap_setup {
	read -p "Enter your Dynamic DNS Password: " -r DNSPASS
        sed -e "s#%%DNSPASS%%#${DNSPASS}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/namecheap.config.json.tpl >/opt/ddns/config.json
}
function duckdns_setup {
        read -p "Enter your Dynamic DNS Token: " -r TOKEN
        sed -e "s#%%TOKEN%%#${TOKEN}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/duckdns.config.json.tpl >/opt/ddns/config.json
}
function godaddy_setup {
        read -p "Enter your Dynamic DNS Key: " -r KEY
        read -p "Enter your Dynamic DNS Secret: " -r SECRET
        sed -e "s#%%SECRET%%#${SECRET}#g" -e "s#%%KEY%%#${KEY}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/godaddy.config.json.tpl >/opt/ddns/config.json
}
function dreamhost_setup {
        read -p "Enter your Dynamic DNS Key: " -r KEY
        sed -e "s#%%KEY%%#${KEY}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/dreamhost.config.json.tpl >/opt/ddns/config.json
}
function cloudflare_setup {
	read -p "Enter your Global API Key: " -r KEY
	read -p "Enter your Zone Id: " -r ZONEIDENT
	read -p "Enter your Identifier: " -r IDENT
	sed -e "s#%%IDENT%%#${IDENT}#g" -e "s#%%KEY%%#${KEY}#g" -e "s#%%ZONEIDENT%%#${ZONEIDENT}#g" -e "s#%%EMAIL%%#${EMAIL}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/cloudflare.config.json.tpl >/opt/ddns/config.json
}

#
# Script main
#
setup

read -p "Would you like to set up the Traefik web user interface? (y/n)? " -r CHOICE
case "${CHOICE:0:1}" in
	#Layer1-YES
	y|Y)
	read -p "Please enter your htpasswd string here. See README for more information. " -r HTPASSWORD
		read -p "Would you like to set up user/password for all containers behind Traefik (y/n)? " -r CHOICE
		case "${CHOICE:0:1}" in
    			#Layer2-YES
			y|Y)
				read -p "Would you like to set up dynamic DNS? (For advanced users. Works for GoDaddy, Namecheap, Dreamhost, and DuckDNS) (y/n)? " -r CHOICE
				case "${CHOICE:0:1}" in
					#Layer3-YES
    					y|Y)
						ddns_setup
						sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.all.tpl >/opt/traefik/traefik.toml
						sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.all.tpl >/opt/traefik/docker-compose.yml
						;;
    					#Layer3-NO
					*)
				       		sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.all.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.dash.tpl >/opt/traefik/docker-compose.yml
						;;
				esac
	       			;;
    			#Layer2-NO
			*)
            			read -p "Would you like to set up dynamic DNS? (For advanced users. Works for GoDaddy, Namecheap, Dreamhost, and DuckDNS) (y/n)? " -r CHOICE
               			case "${CHOICE:0:1}" in
					#Layer3-YES
					y|Y)
						ddns_setup
						sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.dash.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.all.tpl >/opt/traefik/docker-compose.yml
              		          		;;
                			#Layer3-NO
					*)
   		                 		sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.dash.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.dash.tpl >/opt/traefik/docker-compose.yml
               		         		;;
              		  	esac
        			;;
		esac
       		;;
	#Layer1-NO
	*)
                read -p "Would you like to set up user/password for all containers behind Traefik (y/n)? " -r CHOICE
                case "${CHOICE:0:1}" in
                        #Layer2-YES
                        y|Y)
				read -p "Please enter your htpasswd string here. See README for more information. " -r HTPASSWORD
                                read -p "Would you like to set up dynamic DNS? (For advanced users. Works for GoDaddy, Namecheap, Dreamhost, and DuckDNS) (y/n)? " -r CHOICE
                                case "${CHOICE:0:1}" in
                                        #Layer3-YES
                                        y|Y)
						ddns_setup
                                                sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.passwd.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.ddns.tpl >/opt/traefik/docker-compose.yml
                                                ;;
                                        #Layer3-NO
                                        *)
                                                sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.passwd.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.tpl >/opt/traefik/docker-compose.yml
                                                ;;
                                esac
                                ;;
                        #Layer2-NO
                        *)
                                read -p "Would you like to set up dynamic DNS? (For advanced users. Works for GoDaddy, Namecheap, Dreamhost, and DuckDNS) (y/n)? " -r CHOICE
                                case "${CHOICE:0:1}" in
                                        #Layer3-YES
                                        y|Y)
						ddns_setup
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.ddns.tpl >/opt/traefik/docker-compose.yml
                                                ;;
                                        #Layer3-NO
                                        *)
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.tpl >/opt/traefik/docker-compose.yml
                                                ;;
                                esac
                                ;;
                esac
                ;;
esac

cat <<"EOF"

This script has set up your docker-compose.yml file and Traefik configuration in your /opt/traefik directory.
If you chose to configure dDNS, ensure that you have followed all instructions from the container's owner: https://github.com/qdm12/ddns-updater
EOF
