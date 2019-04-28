defaultEntryPoints = ["http", "https"]

[entryPoints]
  [entryPoints.dashboard]
    address = ":8080"
    [entryPoints.dashboard.auth]
      [entryPoints.dashboard.auth.basic]
        users = ["%%HTPASSWORD%%"]
  [entryPoints.http]
    address = ":80"
      [entryPoints.http.redirect]
        entryPoint = "https"
  [entryPoints.https]
    address = ":443"
      [entryPoints.https.tls]
  [entryPoints.https.auth.basic]
    users = ["%%HTPASSWORD%%"]

[api]
entrypoint="dashboard"
dashboard = true

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
