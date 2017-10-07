FROM node:8

MAINTAINER Andrey Bukatov <andrey.bukatov@gmail.com>

RUN apt-get update && apt-get install -y netcat
RUN npm install -g nightwatch

RUN useradd -d /app nw

WORKDIR /app

COPY ./build/src /app
RUN chown -R nw:nw /app
USER nw:nw
RUN npm install
USER root

COPY ./docker/scripts /scripts
COPY ./docker/app/scripts /scripts/app

RUN find /app -not -path "*/node_modules/*" -exec chown nw:nw {} \;

CMD ["/scripts/app/start.sh"]
