FROM node:7

MAINTAINER Andrey Bukatov <andrey.bukatov@gmail.com>

COPY ./docker/scripts /scripts
COPY ./docker/app/scripts /scripts/app

RUN apt-get update && apt-get install -y netcat
RUN npm install -g nightwatch

RUN useradd -d /nightwatch nw

WORKDIR /nightwatch

CMD ["/scripts/app/start.sh"]
