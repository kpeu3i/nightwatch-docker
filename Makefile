SHELL := /bin/sh

mode ?= debug
export NW_MODE = ${mode}

env ?= local
export NW_ENV = ${env}

settings ?= default
export NW_TESTING_SETTINGS = ${settings}

-include .env

ifeq ($(shell [[ $(NW_MODE) != debug && $(NW_MODE) != release ]] && echo true),true)
    $(error "Invalid mode)
endif

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
CURRENT_BASE_DIR := $(notdir $(patsubst %/,%,$(dir $(MKFILE_PATH))))

NW_CHROME_CONTAINERS_NUMBER ?= 1
NW_FIREFOX_CONTAINERS_NUMBER ?= 1
NW_BUILD_DIR = ${CURRENT_DIR}/build
export NW_HOST_UID ?= $(shell id -u)
export NW_HOST_GID ?= $(shell id -g)

.PHONY: default build login pull push up down recreate cleanup start stop restart status deps-install test

default: up

build:
	@mkdir -p ${NW_BUILD_DIR}/src
	@rm -rf ${NW_BUILD_DIR}/src
	@cp -r ${NW_APP_VOLUME_PATH} ${NW_BUILD_DIR}/src
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml build

login:
	docker login -u ${NW_REGISTRY_USER} -p ${NW_REGISTRY_PASSWORD} ${NW_REGISTRY}

pull: login
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml push

push: login
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml pull

up:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d --scale chrome=$(NW_CHROME_CONTAINERS_NUMBER) chrome
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d --scale firefox=$(NW_FIREFOX_CONTAINERS_NUMBER) firefox
    ifneq ($(NW_APP_COMMAND),)
		@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d app
    endif

down:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml down --remove-orphans

recreate: down up

cleanup:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml down --volumes --remove-orphans

start:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml start

stop:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml stop

restart:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml restart

status:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml ps

deps-install:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --rm app npm install

test:
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --rm app nightwatch --env $(NW_TESTING_SETTINGS)
