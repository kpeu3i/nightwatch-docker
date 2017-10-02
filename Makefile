-include .env

NW_CHROME_CONTAINERS_NUMBER ?= 1
NW_FIREFOX_CONTAINERS_NUMBER ?= 1
NW_TESTING_ENVIRONMENT ?= chrome,firefox

.PHONY: default pull build up down recreate start stop restart status test

default: up

pull:
	docker-compose pull

build:
	docker-compose build

up:
	docker-compose up -d selenium_hub
	docker-compose up -d --scale chrome=$(NW_CHROME_CONTAINERS_NUMBER) --no-deps chrome
	docker-compose up -d --scale firefox=$(NW_FIREFOX_CONTAINERS_NUMBER) --no-deps firefox

down:
	docker-compose down

recreate: down up

start:
	docker-compose start

stop:
	docker-compose stop

restart:
	docker-compose restart

status:
	docker-compose ps

test:
	docker-compose run ${CLR_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --user nw --rm app nightwatch --env $(NW_TESTING_ENVIRONMENT)
