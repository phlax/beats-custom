#!/usr/bin/make -f

SHELL := /bin/bash


filebeat-image:
	docker pull phlax/beatbox:$$BEATS_BRANCH
	sudo mkdir -p /var/lib/beatbox/src/github.com/elastic
	sudo chown -R `whoami` /var/lib/beatbox
	cd /var/lib/beatbox/src/github.com/elastic \
		&& git clone https://github.com/elastic/beats \
		&& cd beats \
		&& git checkout $$BEATS_BRANCH
	docker run --rm \
		-v /var/lib/beatbox/pkg:/tmp/pkg \
		phlax/beatbox:$$BEATS_BRANCH \
		cp -a /var/lib/beatbox/pkg/mod /tmp/pkg
	docker run --rm \
		-v /var/lib/beatbox/pkg/mod:/var/lib/beatbox/pkg/mod \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src/github.com/elastic/beats:/var/lib/beatbox/src/github.com/elastic/beats \
		-w /var/lib/beatbox/src/github.com/elastic/beats/filebeat \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-e GO111MODULE=on \
		-e WORKSPACE=/var/lib/beatbox/src/github.com/elastic/beats/filebeat \
		phlax/beatbox:$$BEATS_BRANCH \
		make release
	docker build -t phlax/filebeat:$$BEATS_BRANCH context/filebeat

modbeat-image:
	docker pull phlax/beatbox:$$BEATS_BRANCH
	sudo mkdir -p /var/lib/beatbox/src/github.com/elastic
	sudo chown -R `whoami` /var/lib/beatbox
	cd /var/lib/beatbox/src/github.com/elastic \
		&& if [ ! -d beats ]; then git clone https://github.com/elastic/beats; fi \
		&& cd beats \
		&& git checkout $$BEATS_BRANCH
	docker run --rm \
		-v /var/lib/beatbox/pkg/mod:/var/lib/beatbox/pkg/mod \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src:/var/lib/beatbox/src \
		-v `pwd`/gitconfig:/root/.gitconfig \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-e NEWBEAT_TYPE=metricbeat \
		-e NEWBEAT_PROJECT_NAME=modbeat \
		-e NEWBEAT_GITHUB_NAME=phlax \
		-e NEWBEAT_BEAT_PATH=github.com/phlax/modbeat \
		-e NEWBEAT_FULL_NAME="Ryan Northey" \
		-e NEWBEAT_BEATS_REVISION=$$BEATS_BRANCH \
		-e MODULE=mymodule \
		-e METRICSET=mymetrics \
		phlax/beatbox:$$BEATS_BRANCH \
		mage GenerateCustomBeat
	export modules=$$(cat metricbeat-modules) \
		&& sudo chown -R `whoami` /var/lib/beatbox/src/github.com/phlax/modbeat/module \
		&& cd /var/lib/beatbox/src/github.com/elastic/beats/metricbeat \
		&& for mod in $$(find module/ -mindepth 1 -maxdepth 1 -type d -name "*" | cut -d/ -f2); do \
			if [ -n "$$(echo $$modules | grep $$mod)" ]; then \
				echo "ENABLING MODULE $$mod"; \
				cp -a "module/$${mod}" /var/lib/beatbox/src/github.com/phlax/modbeat/module; \
			fi; \
		   done
	docker run --rm \
		-v /var/lib/beatbox/pkg:/var/lib/beatbox/pkg \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src:/var/lib/beatbox/src \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-w /var/lib/beatbox/src/github.com/phlax/modbeat \
		phlax/beatbox:$$BEATS_BRANCH \
		make update
	docker run --rm \
		-v /var/lib/beatbox/pkg/mod:/var/lib/beatbox/pkg/mod \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src:/var/lib/beatbox/src \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-w /var/lib/beatbox/src/github.com/phlax/modbeat \
		phlax/beatbox:$$BEATS_BRANCH \
		make release
	ls /var/lib/beatbox/src/github.com/phlax/modbeat/module
	sudo cat /var/lib/beatbox/src/github.com/phlax/modbeat/modbeat.yml
	docker images
	docker build -t phlax/modbeat:$$BEATS_BRANCH context/modbeat

images: modbeat-image
	echo "done"

hub-images:
	docker push phlax/modbeat:$$BEATS_BRANCH
