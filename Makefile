SHELL := /bin/sh

mode ?= debug
export NW_MODE = ${mode}

env ?= local
export NW_ENV = ${env}

settings ?= default
export NW_TESTING_SETTINGS = ${settings}

-include .env

ifeq ($(shell [[ $(NW_MODE) != debug && $(NW_MODE) != release ]] && echo true),true)
    $(error Invalid mode value)
endif

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
CURRENT_BASE_DIR := $(notdir $(patsubst %/,%,$(dir $(MKFILE_PATH))))

NW_CHROME_CONTAINERS_NUMBER ?= 1
NW_FIREFOX_CONTAINERS_NUMBER ?= 1
NW_BUILD_DIR = ${CURRENT_DIR}/build
export NW_HOST_UID ?= $(shell id -u)
export NW_HOST_GID ?= $(shell id -g)

.PHONY: default login build push pull up down recreate start stop restart status deps-install cleanup test

default: up

define DOCKER_HOST_SWITCH
	$(eval export DOCKER_HOST=${1})
	$(eval export DOCKER_CERT_PATH=${2})
	$(eval export DOCKER_TLS_VERIFY=${3})
endef

login:
	docker login -u ${NW_REGISTRY_USER} -p ${NW_REGISTRY_PASSWORD} ${NW_REGISTRY}

build:
	@mkdir -p ${NW_BUILD_DIR}/src
	@rm -rf ${NW_BUILD_DIR}/src
	@cp -r ${NW_APP_VOLUME_PATH} ${NW_BUILD_DIR}/src
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml pull selenium_hub chrome firefox
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml build

push: login
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml push

pull: login
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml pull

up:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d --scale chrome=$(NW_CHROME_CONTAINERS_NUMBER) chrome
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d --scale firefox=$(NW_FIREFOX_CONTAINERS_NUMBER) firefox
    ifneq ($(NW_APP_COMMAND),)
		@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml up -d app
    endif

down:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml down --remove-orphans

recreate: down up

start:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml start

stop:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml stop

restart:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml restart

status:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml ps

deps-install:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --rm app npm install

cleanup:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml down --rmi all --volumes --remove-orphans

test:
    ifeq ($(mode),release)
		@$(call DOCKER_HOST_SWITCH,${NW_DOCKER_ADDR},${NW_DOCKER_CERT_PATH},${NW_DOCKER_TLS_VERIFY})
    endif
	@${CURRENT_DIR}/scripts/dcg.sh app -p ${NW_APP_PORTS} > ${CURRENT_DIR}/docker-compose.extra.yml
	@docker-compose -f docker-compose.yml -f docker-compose.${NW_MODE}.yml -f docker-compose.extra.yml run ${NW_COMPOSE_TTY_ALLOCATION_OPTION} --no-deps --rm app nightwatch --env $(NW_TESTING_SETTINGS)
