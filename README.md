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

**The dirty work**

This one-liner sets up the directory tree and files you'll need for this docker-compose.yml file with the correct permissions and ownership. I put all this at the root of my linux distros for simplicity. Towards the end you need to input your username where it says "YOUR-USER:" but don't delete the colon.

`cd / && sudo mkdir apps && cd apps && sudo touch docker-compose.yml && sudo mkdir traefik wiki nextcloud nextclouddb && cd traefik && sudo touch acme.json traefik.toml && sudo chmod 600 acme.json && cd / && sudo chown -R YOUR-USER: /apps/`

In both files, docker-compose.yml and traefik.toml, there are spots in all caps where you need to add your own values. Your domain name and your email address for LetsEncrypt. You can copy the text from my files over to the requisite files the above one-liner created, while changing those values in all caps.

You should then be ready to run `docker-compose up -d` and bring up your apps. If you want to add more or other apps to the docker-compose file, you simply need to add the labels section to each service.
