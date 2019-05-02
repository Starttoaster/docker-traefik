# Traefik Reverse-Proxy

This script configures a Traefik reverse proxy with LetsEncrypt certs for your public webapps. In my example, I set up a DokuWiki (excellent plain text with markdown wiki app.) 
While doing this I felt there was no really simple guide to achieve this result, and may be a little confusing for other people, so here you go. 

### Domain Registry + DNS Configuration

I purchased my domain through NameCheap. Whatever domain registrar you go through, you're going to need to set up DNS records properly through them. 
I recommend NameCheap because of how simple it was, but I imagine they are all about the same. As long as the provider allows wildcard DNS records you should be good to go. 
In NameCheap's "Advanced DNS" tab I added these:

| Type | Host | Value | TTL |
| ---- | ---- | ----- | --- |
| A Record | `*` | IP-ADDRESS | Automatic |
| CNAME Record | `www` | DOMAIN-NAME | Automatic |
 
Change the values accordingly for your server's IP, and the domain you've purchased! 

### Installation

 1. Clone the repo: `git clone https://github.com/Starttoaster/docker-traefik.git`

 2. Change directory: `cd docker-traefik`

 2. Run the script: `./docker-traefik.sh`

 3. Change directory: `cd /opt/traefik` 

Once you answer a couple questions, the script should complete. If you are running on a VPS (cloud server) you should then be ready to run `docker-compose up -d` and bring up your apps.
If you are self-hosting from home, then move on to the next sections for home networks. 
If you want to add more or other apps to the docker-compose file, you simply need to add the labels section to each service and just change the subdomain to what you want its URL to be.

### For home networks and servers using private IP addresses

If you've done this guide on a server using a private IP address (behind some kind of router), make sure to also open up your router's configuration page and 
forward ports 80 and 443 to your server's private IP address. I cannot instruct on how to do this as each router has different configuration pages, but just search Google for your 
router + "port forwarding". While you're here, also make sure your server has a statically assigned private IP. This will save a great deal of headache if your server 
ever gets rebooted and assigned a new IP from your DHCP pool.

### Home networks extra credit: Dynamic DNS

Setting up "dDNS" is entirely optional. Internet service providers do not typically assign static public IP addresses to residential home users. You may find one day that your cable modem/router was 
reset for some reason. After the modem/router came back online, it was potentially assigned a new public IP address by your ISP's DHCP. In this instance you have two options:

 1. Manually find your new public IP address, (Go to: https://diagnostic.opendns.com/myip), and change the IPADDRESS sections to match your new IP address on your DNS A Records with whoever your DNS provider is. Mine being Namecheap's Basic DNS.

 2. Set up Dynamic DNS (DDNS). DDNS runs a minimal web application from within your home server that periodically sends an update of what IP address you're currently using to your DNS provider. It authenticates to the DNS provider via a passkey that is assigned by the DNS provider, and if your IP address ever receives a change the DNS provider will update their "A+ Records" automatically. I recommend following the setup instructions here: https://github.com/qdm12/ddns-updater

If you set up dynamic DNS via the container offered in this script, ensure that you configure it properly before running `docker-compose up -d` to bring up your containers. Otherwise you will need to stop the containers,
finish the configuration, and restart them.

### Traefik Dashboard

This is entirely optional. The Traefik dashboard offers some information about the applications behind your web proxy. I have added a conditional that allows you to automate the configuration of the web dashboard.
You will need an 'htpasswd' which I have included a section below on how to obtain one. An htpasswd is just a username with a hashed password. See 'To generate an htpasswd' below.
When the Traefik dashboard is configured, you will just need to enter your username and password in the dialog box that pops up at https://dash.YOUR-DOMAIN.TLD

### HTTP Basic Auth

This is entirely optional. If you would like all of your apps to have an additional layer of protection then you can configure an htpasswd in the traefik.toml file.
An htpasswd is just a username with a hashed password. 
I have added a conditional in the script that will configure this for you. All you need is an "htpasswd" to enter when the script asks for it.
When you want to visit one of your webapps, you will need to enter the username and password you chose in the dialog box that pops up.

#### To generate an htpasswd, either:

 1. Install the 'apache2-utils' package on your linux distro, and run: `htpasswd -nb user password`

Making sure to replace user with the desired username, and password with the desired password; or

 2. Visit: `http://www.htaccesstools.com/htpasswd-generator/`

Simply enter your desired username and password, then copy that string and enter it in the script when asked for it.

### Special Thanks

To GitHub user [qdm12](https://github.com/qdm12) for their lightweight Dynamic DNS updating docker image. [qdm12/ddns-updater](https://github.com/qdm12/ddns-updater) 

To GitHub user [szepeviktor](https://github.com/szepeviktor) for their contributions to this script.

To Miroslav Prasil for the best DokuWiki docker image on Docker Hub.

