# tiddlywiki

[TiddlyWiki 5](https://tiddlywiki.com) Docker image.

Google Cloud users may also be interested in
https://github.com/neechbear/tiddlywiki-gce.

## Supported Tags

* `5.2.0`, `5.2.0-node17.0-alpine3.13`
* `5.1.23`, `5.1.23-node14.18.1-alpine3.14`
* `5.1.22`, `5.1.22-node14.9.0-alpine3.12`

## Requirements

1. Install Docker. See https://docs.docker.com/install/ for help. For lazy and
   non-security minded Linux users, simply run the following command:
   `curl -fsSL get.docker.com | sudo bash`

2. If you want to automatically start TiddlyWiki on boot, you will need to be
   running a recent Linux distribution that uses systemd. (Ubuntu 12 or older,
   for example, do not support systemd by default).

## Manual Execution

```
$ docker run -p 8080:8080 --name mywiki nicolaw/tiddlywiki
```

Open your browser to http://localhost:8080 to access the TiddlyWiki.

Alternatively the following will instruct Docker to keep your TiddlyWiki
container running at all times untill explicitly stopped with a `docker stop` or
`docker kill` command:

```
$ mkdir ~/tiddlywiki
$ docker run \
    -p 8080:8080 -d --restart unless-stopped --name mywiki \
    -v ~/tiddlywiki:/var/lib/tiddlywiki \
    nicolaw/tiddlywiki
```

## Systemd Service

A systemd service unit file is included in the source repository of this
project. (See https://github.com/neechbear/tiddlywiki ). This can be installed to
automatically start one or more TiddlyWikis every time your machine boots.

It also provides you with some level of configurability by simply changing the
contents of the `/etc/tiddlywiki/mywiki.service.conf` configuration file.

```
$ sudo mkdir /etc/tiddlywiki/
$ sudo cp tiddlywiki.service /etc/systemd/system/mywiki.service
$ sudo cp tiddlywiki.service.conf /etc/tiddlywiki/mywiki.service.conf
$ sudo systemctl daemon-reload
$ sudo systemctl start mywiki.service
```

Check the status of the TiddlyWiki service, or watch the logs using the
following commands:

```
$ sudo systemctl status mywiki.service
$ sudo journalctl -f -u mywiki.service
```

## Tiddler Data Storage

The container stores the Tiddler data in `/var/lib/tiddlywiki`. This will
automatically be saved inside an anonymous Docker volume.

Specifying a volume bind mount location for `/var/lib/tiddlywiki` will cause the
Tiddler data to be written to that location on your local filesystem.

```
$ docker run --rm -p 8080:8080 -v ~/wikidata:/var/lib/tiddlyiki --name mywiki nicolaw/tiddlywiki
```

In the case of operating TiddlyWiki from systemd, the Docker volume has the
same name as the systemd service name (`mywiki.service` by default). Use
`docker volume inspect mywiki.service` see where your data is being stored
on disk in the event that you wish to perform a backup.

Alternatively, to specify a bind mount location, uncomment and modify the
`TW_DOCKERVOLUME` line, and optionally the `TW_DOCKERUID` and `TW_DOCKERGID`
lines in the `/etc/tiddlywiki/mywiki.service.conf` configuration file.

You will need to restart the service once you have saved your file change.

```
$ sudo vi /etc/tiddlywiki/mywiki.service.conf
$ sudo systemctl restart mywiki.service
```

## Authentication

By default, the username is set to `anonymous` with no password.

Specify the `TW_USERNAME` and `TW_PASSWORD` environment variables to enable
password authentication.

```
$ docker run -p 8080:8080 -e "TW_USERNAME=$USER" -e "TW_PASSWORD=hunter2" --name mywiki nicolaw/tiddlywiki
```

Similarly if you are using systemd to start your TiddlyWiki, uncomment and
modify the `TW_USERNAME` and `TW_PASSWORD` lines from the
`/etc/tiddlywiki/mywiki.service.conf` file.

You will need to restart the service once you have saved your file change.

```
$ sudo vi /etc/tiddlywiki/mywiki.service.conf
$ sudo systemctl restart mywiki.service
```

## Configurable Variables

Refer to the canonical online documentation for help for additional help.

* https://tiddlywiki.com/static/Using%2520TiddlyWiki%2520on%2520Node.js.html
* https://tiddlywiki.com/static/ServerCommand.html

```
TW_WIKINAME=mywiki
TW_USERNAME=janedoe
TW_PASSWORD=
TW_PORT=8080
TW_ROOTTIDDLER=$:/core/save/all
TW_RENDERTYPE=text/plain
TW_SERVETYPE=text/html
TW_HOST=0.0.0.0
TW_PATHPREFIX=
```

You can alter how the NodeJS tiddlywiki server will operate by changing these
two variables.

If you are operating in a low memory environment (inside a small
AWS, GCE or other cloud virtual machine for example), you may wish to set
`NODE_MEM` to specify the maximum memory can NodeJS may use (specified in MB).

```
NODE_MEM=400
NODE_OPTIONS=
```

The following variables only affect the operation while using the system service
unit to start TiddlyWiki. They do nothing if you are running the Docker
container independently of systemd.

```
TW_DOCKERVOLUME=/home/janedoe/tiddlywiki
TW_DOCKERUID=0
TW_DOCKERGID=0
```

## Docker Compose

More experienced users may wish to use `docker-compose` to dynamically build a
customised container image using the Git source repostiory as the build context.
This allows control over the following `Dockerfile` build arguments:

* `TW_VERSION` - The upstream version of TiddlyWiki to install from NPM
  (https://www.npmjs.com/package/tiddlywiki)

* `BASE_IMAGE` - The Docker base container image to inherit from (should
  contain the `node` interpreter)

* `USER` - Unix user or UID to run the TiddlyWiki process as (useful if
  your container runtime environment does not allow you to override)

The `Makefile` in the https://github.com/neechbear/tiddlywiki.git also makes use
of these build arguments in a similar way.

Example [Docker compose](https://docs.docker.com/compose/) definition:

```
tiddlywiki:
   container_name: tiddlywiki
   image: nicolaw/tiddlywiki
   build:
     context: https://github.com/neechbear/tiddlywiki.git
     args:
       TW_VERSION: 5.1.23
       USER: 501
       BASE_IMAGE: 14-alpine3.12
````

## Author

Nicola Worthington <nicolaw@tfb.net>, https://nicolaw.uk,
https://nicolaw.uk/#TiddlyWiki.

## License

MIT License

Copyright (c) 2018-2021 Nicola Worthington

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
