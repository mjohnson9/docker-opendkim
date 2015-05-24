# docker-opendkim
docker-opendkim is a Docker container that supplies an OpenDKIM verifier/milter

## Configuration
**docker-opendkim is intended to be run on CoreOS.** At minimum, you must be running etcd.

To set etcd's location, specify the `ETCD_HOST` and `ETCD_PORT` environment variables. By default, the container looks at `172.17.42.1:4001` for etcd.

The server's domain and selector must be specified with the `DOMAIN` and `SELECTOR` environment variables.

This container exposes its milter on port 12301. It is intended to be linked with other containers.

### etcd keys
docker-opendkim uses the following etcd keys:
```
/services/dkim/$DOMAIN/$SELECTOR/key - DKIM key
```

## Copyright and license
docker-opendkim is licensed under the MIT license, as found in the LICENSE file.
