SHELL := /bin/bash

TF_ROOT := infra
ENV ?= dev
TF_DIR := $(TF_ROOT)/envs/$(ENV)

PLAN_FILE := tfplan
