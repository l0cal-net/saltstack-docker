# What is Salt?

Salt is a configuration management tool / orchestration platform.

This image contains a running salt-master and salt-api process, which can be used to control other salt-minions.

![SaltProject](https://gitlab.com/saltstack/open/salt-branding-guide/-/raw/master/logos/SaltProject_altlogo_teal.png)

# How to use this image

## Start a Salt instance

```console
$ docker run --name salt --hostname salt -p 4505-4506:4505-4506 -p 8000:8000 -e SALT_SHARED_SECRET=mysecretpassword -d saltstack/salt
```

The default `salt` user is created but the shared secret is specified in the `/etc/salt/master.d/api.conf`.

The api listens on port `8000` with `ssl` enabled.

# How to extend this image

There are many ways to extend the `salt` image. Without trying to support every possible use case, here are just a few that we have found useful.

## Environment Variables

The Salt image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

### `SALT_MASTER_CONFIG`

A JSON object. This variable is dumped to /etc/salt/master.d/master.conf and can be used to provide extra config for the salt master.

### `SALT_API_CONFIG`

A JSON object. This variable is dumped to /etc/salt/master.d/api.conf, and defaults to the following.

```yaml
rest_cherrypy:
  port: 8000,
  ssl_crt: /etc/pki/tls/certs/localhost.crt
  ssl_key: /etc/pki/tls/certs/localhost.key
external_auth:
    sharedsecret:
        salt: ['.*', '@wheel', '@jobs', '@runner']
sharedsecret: $SALT_SHARED_SECRET
```

### `SALT_SHARED_SECRET`

If this environment variable is set, it will set the sharedsecret variable for using the salt-api with the salt user.

## Salt Wheel Modules

If the salt-master is not configured immediately at the start, the master config can be updated using wheel modules via the salt api using the [Salt Config Wheel Module](https://docs.saltproject.io/en/latest/ref/wheel/all/salt.wheel.config.html)

## Volumes for Salt Keys

In order to make volumes available to the `salt` user in the container, assign the group id `450` to the directory before it mounting it on the container.
