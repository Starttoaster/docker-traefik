#!/bin/bash
#
# Configure Traefik Reverse-Proxy.
#

# User input
read -p "What is your domain name? " -r DOMAIN
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
sudo -- chown -R "$USER": /opt/traefik /opt/wiki

#Layer1
read -p "Would you like to set up the Traefik web user interface? Not necessary but looks pretty.. (y/n)? " -r CHOICE
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
						read -p "Please enter your dynamic DNS password (leave blank if unknown): " -r DNSPASS
						sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.all.tpl >/opt/traefik/traefik.toml
						sed -e "s#%%DNSPASS%%#${DNSPASS}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.all.tpl >/opt/traefik/docker-compose.yml
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
		                                read -p "Please enter your dynamic DNS password (leave blank if unknown): " -r DNSPASS
						sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.dash.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DNSPASS%%#${DNSPASS}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.all.tpl >/opt/traefik/docker-compose.yml
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
						read -p "Please enter your dynamic DNS password (leave blank if unknown): " -r DNSPASS
                                                sed -e "s#%%HTPASSWORD%%#${HTPASSWORD}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.passwd.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DNSPASS%%#${DNSPASS}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.ddns.tpl >/opt/traefik/docker-compose.yml
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
						read -p "Please enter your dynamic DNS password (leave blank if unknown): " -r DNSPASS
                                                sed -e "s#%%DOMAIN%%#${DOMAIN}#g" -e "s#%%EMAIL%%#${EMAIL}#g" ./tpl/traefik.toml.tpl >/opt/traefik/traefik.toml
                                                sed -e "s#%%DNSPASS%%#${DNSPASS}#g" -e "s#%%DOMAIN%%#${DOMAIN}#g" ./tpl/docker-compose.yml.ddns.tpl >/opt/traefik/docker-compose.yml
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
It also set up an example DokuWiki container with the required Traefik labels for a subdomain in /opt/wiki.
If you chose to configure dDNS, ensure that you have followed all instructions from the container's owner: https://github.com/qdm12/ddns-updater
Make any necessary changes specific to you, and run 'docker-compose up -d' to start your containers.
And thank you, Quentin McGaw (GitHub: qdm12), for the excellent dynamic DNS image.
EOF
