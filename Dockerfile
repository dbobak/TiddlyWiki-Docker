#
# MIT License
# Copyright (c) 2022 Darek Bobak
#
# https://github.com/dbobak/TiddlyWiki-Docker/
# based on https://gitlab.com/nicolaw/tiddlywiki
#

ARG BASE_IMAGE=node:17.9-alpine3.15
FROM ${BASE_IMAGE} AS build

ARG TW_VERSION=5.2.5
ARG USER=node

ENV NPM_ENV=production

RUN apk add libcap binutils \
 && setcap 'cap_net_bind_service=+ep' /usr/local/bin/node \
 && strip /usr/local/bin/node \
 && apk del libcap binutils \

 && apk del libc-utils musl-utils scanelf apk-tools \
 && rm -Rf /lib/apk /var/cache/apk /etc/apk /usr/share/apk \
 && find ~root/ ~node/ -mindepth 1 -delete \

 && mkdir -p /var/lib/tiddlywiki \
 && chown -R ${USER}:${USER} /var/lib/tiddlywiki \

 && npm install --only=production -g "tiddlywiki@${TW_VERSION}" \

 && find /usr/local/include/node/openssl/archs -type d -mindepth 1 -maxdepth 1 | grep -vi "/$(uname -s)-$(uname -m)$" | xargs rm -Rf \
 && rm -Rf /usr/local/lib/node_modules/npm \
 && rm -f /usr/local/bin/npm \
 && rm -f /usr/local/bin/npx \
 && rm -Rf /tmp/*

COPY --chmod=0555 --chown=root:root init-and-run /usr/local/bin/init-and-run

FROM scratch

ARG TW_VERSION=5.2.5
ARG USER=node

COPY --from=build / /

LABEL author="Darek Bobak" \
      vcs="https://github.com/dbobak/TiddlyWiki-Docker/" \
      description="TiddlyWiki - a non-linear personal web notebook" \
      version="$TW_VERSION" \
      com.tiddlywiki.version="$TW_VERSION" \
      com.tiddlywiki.homepage="https://tiddlywiki.com" \
      com.tiddlywiki.author="Jeremy Ruston" \
      com.tiddlywiki.vcs="https://github.com/Jermolene/TiddlyWiki5"

ENV TW_WIKINAME="mywiki" \
    TW_PORT="8080" \
    TW_ROOTTIDDLER="$:/core/save/all" \
    TW_RENDERTYPE="text/plain" \
    TW_SERVETYPE="text/html" \
    TW_USERNAME="anonymous" \
    TW_PASSWORD="" \
    TW_HOST="0.0.0.0" \
    TW_PATHPREFIX="" \
    NPM_ENV=production

EXPOSE 8080/tcp

VOLUME /var/lib/tiddlywiki
WORKDIR /var/lib/tiddlywiki
USER ${USER}

CMD ["/bin/sh","/usr/local/bin/init-and-run"]
