# Traefik Reverse-Proxy

This script configures a Traefik reverse proxy with LetsEncrypt certs for your public webapps. In my example, I set up a DokuWiki (excellent plain text with markdown wiki app.) 
While doing this I felt there was no really simple guide to achieve this result, and may be a little confusing for other people, so here you go. 

NOTE: This currently works with Traefik v1. Support for v2 to come soon.

### Domain Registry + DNS Configuration

I purchased my domain through NameCheap. Whatever domain registrar you go through, you're going to need to set up DNS records properly through them. 
I recommend NameCheap because of how simple it was, but they are all about the same. As long as the provider allows wildcard DNS records you should be good to go. 
In Namecheap's "Advanced DNS" tab I only added this, change the IP-ADDRESS value to your server's public IP address:

| Type | Host | Value | TTL |
| ---- | ---- | ----- | --- |
| A Record | `*` | IP-ADDRESS | Automatic |

### Installation

 1. Clone the repo: `git clone https://github.com/Starttoaster/docker-traefik.git`

 2. Change directory: `cd docker-traefik`

 2. Run the script: `./docker-traefik.sh`

 3. Change directory: `cd /opt/traefik` 

Once you answer a couple questions, the script should complete. If you are running on a VPS (cloud server) you should then be ready to run `docker-compose up -d` and bring up your apps.
If you are self-hosting from home, then move on to the next sections for home networks. 

If you want to add more or other apps to the docker-compose file, you need to add this labels section to each service you wish to expose, and change all instances of "dokuwiki" to the name of your container. Traefik v2 made many changes including the required labels to expose a service properly. You will also need to change the "server.port" line to the default port number exposed in the Dockerfile of the image you're using, not the one you might yourself. For instance, if you added a port section of "8080:80" you would specify "80" in the server.port line.

### For home networks and servers using private IP addresses

If you've done this guide on a server using a private IP address (behind some kind of router), make sure to also open up your router's configuration page and 
forward ports 80 and 443 to your server's private IP address. I cannot instruct on how to do this as each router has different configuration pages, but just search Google for your 
router + "port forwarding". While you're here, also make sure your server has a statically assigned private IP. This will save a great deal of headache if your server 
ever gets rebooted and assigned a new IP from your DHCP pool.