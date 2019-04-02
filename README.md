# Traefik-in-Docker-Compose

These files configure a Traefik reverse proxy that sets up LetsEncrypt certs for your public webapps. In my example, I set up a DokuWiki (excellent plain text with markdown wiki app.) While doing this I felt there was no really simple guide to achieve this result, and may be a little confusing for other people, so here you go. I chose not to configure the web interface for Traefik as it is mostly a security vulnerability with no real benefit.

**Domain Registry + DNS Configuration**

I purchased my domain through NameCheap. Whatever domain dealer you go through, you're going to need to set up DNS records properly through them. I recommend NameCheap because of how simple it was, but as long as the provider allows wildcard DNS records it should be safe. In NameCheap I added these:

 - Type | Host | Value | TTL
 - A Record | * | IP-ADDRESS | Automatic
 - A Record | @ | IP-ADDRESS | Automatic
 - A Record | www | IP-ADDRESS | Automatic
 - CNAME Record | www | DOMAIN-NAME | Automatic
 
Change the values accordingly for your server's IP, and the domain you've purchased! 

# **The dirty work -- Setting up the files**

For this you have two options. First being to use a bash setup script in this repo, the second is to run a one-liner I provided. The benefit of the script is that it also adds the necessary text to the compose and traefik config files.

## Option 1: Setup Script method

 1. Clone this github repo to anywhere on your server. `git clone https://github.com/Starttoaster/Traefik-in-Docker-Compose.git`

 2. Next you will need to enter the repo directory and chmod the script file to make it runnable: `chmod u+x script.sh`

 3. Run the script with: `./script.sh`  ...The script created all necessary directories and files with the correct permissions at the root of the filesystem.


## Option 2: Manual setup

This one-liner sets up the directory tree and files you'll need for this docker-compose.yml file with the correct permissions and owned by the current user. I put all this at the root of my linux distros for simplicity.

`sudo mkdir /apps /apps/traefik /apps/wiki /apps/wiki/data /apps/wiki/conf /apps/wiki/lib /apps/wiki/lib/plugins /apps/wiki/lib/tpl /apps/wiki/logs && sudo touch /apps/docker-compose.yml /apps/traefik/acme.json /apps/traefik/traefik.toml && sudo chmod 600 /apps/traefik/acme.json && sudo chown -R $USER: /apps/`

## Post-setup steps

In both files, docker-compose.yml and traefik.toml, there are spots in all caps where you need to add your own values. Your domain name and your email address for LetsEncrypt. You can copy the text from my files over to the requisite files the above one-liner created, while changing those values in all caps.

You should then be ready to run `docker-compose up -d` and bring up your apps. If you want to add more or other apps to the docker-compose file, you simply need to add the labels section to each service.


**For home networks and servers using private IP addresses**

If you've done this guide on a server using a private IP address (behind some kind of router), make sure to also open up your router's configuration page and forward ports 80 and 443 to your server's private IP address. I cannot instruct on how to do this as each router has different configuration pages, but just search Google for your router + "port forwarding". While you're here, also make sure your server has a statically assigned private IP. This will save a great deal of headache if your server ever gets rebooted and assigned a new IP from your DHCP pool.

**For home networks extra credit**

Internet service providers do not typically assign static public IP addresses to residential home users. You may find one day that your cable modem/router was reset for some reason. After the modem/router came back online, it was potentially assigned a new public IP address by your ISP's DHCP. In this instance you have two options:

1: Manually find your new public IP address, (Go to: https://diagnostic.opendns.com/myip), and change the IPADDRESS sections to match your new IP address on your DNS A Records with whoever your DNS provider is. Mine being Namecheap's Basic DNS.

2: Set up Dynamic DNS (DDNS). DDNS runs a minimal web application from within your home server that periodically sends an update of what IP address you're currently using to your DNS provider. It authenticates to the DNS provider via a passkey that is assigned by the DNS provider, and if your IP address ever receives a change the DNS provider will update their "A+ Records" automatically. I recommend following the setup instructions here: https://github.com/qdm12/ddns-updater
