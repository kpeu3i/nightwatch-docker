FROM node:8

MAINTAINER Andrey Bukatov <andrey.bukatov@gmail.com>

RUN apt-get update -y && apt-get install -y \
    vim \
    curl \
    netcat \
    net-tools

ENV GOSU_VERSION 1.10
RUN set -x \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

RUN npm install -g nightwatch

ENV NW_CONTAINER_USER_UID 1001
ENV NW_CONTAINER_USER_NAME nw
ENV NW_CONTAINER_USER_GROUP_NAME nw
RUN useradd -d /app --uid $NW_CONTAINER_USER_UID -U $NW_CONTAINER_USER_NAME

WORKDIR /app

COPY ./build/src /app
RUN chown -R $NW_CONTAINER_USER_NAME:$NW_CONTAINER_USER_GROUP_NAME /app

USER $NW_CONTAINER_USER_NAME:$NW_CONTAINER_USER_GROUP_NAME

RUN npm install

USER root

COPY ./docker/scripts /scripts
COPY ./docker/app/scripts /scripts/app

RUN find /app -not -path "*/node_modules/*" -exec chown $NW_CONTAINER_USER_NAME:$NW_CONTAINER_USER_GROUP_NAME {} \;

ENTRYPOINT ["/scripts/app/entrypoint.sh"]

CMD ["nightwatch"]
