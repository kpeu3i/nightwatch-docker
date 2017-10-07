FROM node:8

MAINTAINER Andrey Bukatov <andrey.bukatov@gmail.com>

RUN apt-get update && apt-get install -y netcat
RUN npm install -g nightwatch

RUN useradd -d /app nw

WORKDIR /app

COPY ./build/src /app
RUN npm install
RUN chown -R nw:nw /app

COPY ./docker/scripts /scripts
COPY ./docker/app/scripts /scripts/app

CMD ["/scripts/app/start.sh"]
