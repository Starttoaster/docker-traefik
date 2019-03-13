# Traefik-in-Docker-Compose

These files configure a Traefik reverse proxy that sets up LetsEncrypt certs for your public webapps. In my example, I set up a DokuWiki (excellent plain text with markdown wiki app) and a NextCloud server with database (think Dropbox replacement.) Each webapp can have a different subdomain on the domain you've purchased. While doing this I felt there was no really simple guide to achieve this result, and may be a little confusing for other people, so here you go.

I purchase my domain through NameCheap. Whatever domain dealer you go through, you're going to need to set up DNS records properly through them. I recommend NameCheap because of how simple it was, but as long as the provider allows wildcard DNS records it should be safe. In NameCheap I added these:

 - Type | Host | Value | TTL
 - A Record | * | IP-ADDRESS | Automatic
 - A Record | @ | IP-ADDRESS | Automatic
 - A Record | www | IP-ADDRESS | Automatic
 - CNAME Record | www | DOMAIN-NAME | Automatic
 
 Change the values accordingly for your server's IP, and the domain you've purchased!

In both files, docker-compose.yml and traefik.toml, there are spots in all caps where you need to add your own values. Your domain name, whatever SQL passwords you choose, or your email address for LetsEncrypt.

When you run 'docker-compose up -d' it will automatically create all the necessary folders at filepath /doku/. It does not matter where docker-compose.yml is, however the 'traefik.toml' file needs to be placed in /doku/traefik/. 

Additionally, you will need to create a file in /doku/traefik/ named 'acme.json'. The file should be empty. Your certificates for various domains will be added automatically. 'touch acme.json'


(If you have trouble setting up your NextCloud server, you'll need to determine the IP address that Docker assigned your database. You should be able to see the IP address of that container with 'docker container inspect nextcloud-db'. The address to configure in NextCloud will be 'IP-Address:3306')
