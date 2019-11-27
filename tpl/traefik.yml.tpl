api:
  dashboard: true
entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: true
certificatesResolvers:
  http:
    acme:
      email: %%EMAIL%%
      storage: acme.json
      httpChallenge:
        entryPoint: http
