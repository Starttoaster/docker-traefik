defaultEntryPoints = ["http", "https"]

[entryPoints]
  [entryPoints.http]
    address = ":80"
      [entryPoints.http.redirect]
        entryPoint = "https"
  [entryPoints.https]
    address = ":443"
      [entryPoints.https.tls]
  [entryPoints.https.auth.basic]
    users = ["%%HTPASSWORD%%"]

[docker]
endpoint = "unix:///var/run/docker.sock"
domain = "%%DOMAIN%%"
exposedByDefault = false
watch = true

[acme]
email = "%%EMAIL%%"
storage = "acme.json"
entryPoint = "https"
onHostRule = true
  [acme.httpChallenge]
  entryPoint = "http"
