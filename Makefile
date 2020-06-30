#!/usr/bin/make -f

SHELL := /bin/bash


image:
	docker build --build-arg BEATS_BRANCH=$$BEATS_BRANCH -t phlax/beatbox:$$BEATS_BRANCH context

hub-images:
	docker push phlax/metricbeat:$$BEATS_BRANCH
