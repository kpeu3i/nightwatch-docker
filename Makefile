SHELL := /bin/sh

mode ?= debug
export NW_MODE = ${mode}

env ?= local
export NW_ENV = ${env}

-include .env

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
CURRENT_BASE_DIR := $(notdir $(patsubst %/,%,$(dir $(MKFILE_PATH))))

ifeq ($(shell [[ $(NW_MODE) != debug && $(NW_MODE) != release ]] && echo true),true)
    $(error "Invalid mode)
endif

NW_CHROME_CONTAINERS_NUMBER ?= 1
NW_FIREFOX_CONTAINERS_NUMBER ?= 1
NW_TESTING_SETTINGS ?= chrome,firefox
NW_BUILD_DIR = ${CURRENT_DIR}/build

.PHONY: default build pull up down recreate start stop restart status deps-install test

default: up

build:
	@mkdir -p ${NW_BUILD_DIR}/src
	@rm -rf ${NW_BUILD_DIR}/src
	@cp -r ${NW_APP_VOLUME_PATH} ${NW_BUILD_DIR}/src
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml pull
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml build

pull:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml pull

up:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml up -d selenium_hub
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml up -d --scale chrome=$(NW_CHROME_CONTAINERS_NUMBER) --no-deps chrome
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml up -d --scale firefox=$(NW_FIREFOX_CONTAINERS_NUMBER) --no-deps firefox

down:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml down

recreate: down up

cleanup:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml down --volumes --remove-orphans

start:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml start

stop:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml stop

restart:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml restart

status:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml ps

deps-install:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --user nw --rm app npm install

test:
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} -e NW_ENV=${NW_ENV} --no-deps --user nw --rm app "env"
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} -e NW_ENV=${NW_ENV} --no-deps --user nw --rm app nightwatch --env $(NW_TESTING_SETTINGS)
