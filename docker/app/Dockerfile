FROM node:7

MAINTAINER Andrey Bukatov <andrey.bukatov@gmail.com>

RUN apt-get update && apt-get install -y netcat
RUN npm install -g nightwatch

RUN useradd -d /nightwatch nw

COPY ./docker/scripts /scripts
COPY ./docker/app/scripts /scripts/app

WORKDIR /nightwatch

CMD ["/scripts/app/start.sh"]
