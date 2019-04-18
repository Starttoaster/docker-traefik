# Traefik Reverse-Proxy

This script configures a Traefik reverse proxy with LetsEncrypt certs for your public webapps. In my example, I set up a DokuWiki (excellent plain text with markdown wiki app.) While doing this I felt there was no really simple guide to achieve this result, and may be a little confusing for other people, so here you go. I chose not to configure the web interface for Traefik as it is mostly a security vulnerability with no real benefit.

**Domain Registry + DNS Configuration**

I purchased my domain through NameCheap. Whatever domain dealer you go through, you're going to need to set up DNS records properly through them. I recommend NameCheap because of how simple it was, but I imagine they are all about the same. As long as the provider allows wildcard DNS records you should be good to go. In NameCheap's "Advanced DNS" tab I added these:

 - Type | Host | Value | TTL
 - A Record | * | IP-ADDRESS | Automatic
 - A Record | @ | IP-ADDRESS | Automatic
 - A Record | www | IP-ADDRESS | Automatic
 - CNAME Record | www | DOMAIN-NAME | Automatic
 
Change the values accordingly for your server's IP, and the domain you've purchased! 

# **Installation**

 1. Clone this github repo to anywhere on your server. `git clone https://github.com/Starttoaster/docker-traefik.git`

 2. Change directory: `cd docker-traefik`

 3. Run the script: `source ./script.sh` 

Once you answer a couple questions, the script should complete and you should then be ready to run `docker-compose up -d` and bring up your apps. If you want to add more or other apps to the docker-compose file, you simply need to add the labels section to each service and just change the subdomain to what you want its URL to be.

# **For home networks and servers using private IP addresses**

If you've done this guide on a server using a private IP address (behind some kind of router), make sure to also open up your router's configuration page and forward ports 80 and 443 to your server's private IP address. I cannot instruct on how to do this as each router has different configuration pages, but just search Google for your router + "port forwarding". While you're here, also make sure your server has a statically assigned private IP. This will save a great deal of headache if your server ever gets rebooted and assigned a new IP from your DHCP pool.

**For home networks extra credit**

Internet service providers do not typically assign static public IP addresses to residential home users. You may find one day that your cable modem/router was reset for some reason. After the modem/router came back online, it was potentially assigned a new public IP address by your ISP's DHCP. In this instance you have two options:

 1. Manually find your new public IP address, (Go to: https://diagnostic.opendns.com/myip), and change the IPADDRESS sections to match your new IP address on your DNS A Records with whoever your DNS provider is. Mine being Namecheap's Basic DNS.

 2. Set up Dynamic DNS (DDNS). DDNS runs a minimal web application from within your home server that periodically sends an update of what IP address you're currently using to your DNS provider. It authenticates to the DNS provider via a passkey that is assigned by the DNS provider, and if your IP address ever receives a change the DNS provider will update their "A+ Records" automatically. I recommend following the setup instructions here: https://github.com/qdm12/ddns-updater
