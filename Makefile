-include .env

NW_CHROME_CONTAINERS_NUMBER ?= 1
NW_FIREFOX_CONTAINERS_NUMBER ?= 1
NW_TESTING_ENVIRONMENT ?= chrome,firefox

.PHONY: default build up down recreate start stop restart status test

default: up

build:
	docker-compose pull
	docker-compose build

up:
	docker-compose up -d
	docker-compose scale chrome=$(NW_CHROME_CONTAINERS_NUMBER) firefox=$(NW_FIREFOX_CONTAINERS_NUMBER)
	docker-compose restart selenium_hub

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
	docker-compose exec --user nw app nightwatch --env $(NW_TESTING_ENVIRONMENT)

