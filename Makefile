#!/usr/bin/make -f

SHELL := /bin/bash


metricbeat-image:
	docker pull phlax/beatbox:$$BEATS_BRANCH
	sudo mkdir -p /var/lib/beatbox/src/github.com/elastic
	sudo chown -R travis /var/lib/beatbox
	cd /var/lib/beatbox/src/github.com/elastic \
		&& git clone https://github.com/elastic/beats \
		&& cd beats \
		&& git checkout $$BEATS_BRANCH
	docker run --rm \
		-v /var/lib/beatbox/pkg:/tmp/pkg \
		phlax/beatbox:$BEATS_BRANCH \
		cp -a /var/lib/beatbox/pkg/mod /tmp/pkg
	docker run --rm \
		-v /var/lib/beatbox/pkg/mod:/var/lib/beatbox/pkg/mod \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src/github.com/elastic/beats:/var/lib/beatbox/src/github.com/elastic/beats \
		-w /var/lib/beatbox/src/github.com/elastic/beats/metricbeat \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-e GO111MODULE=on \
		-e WORKSPACE=/var/lib/beatbox/src/github.com/elastic/beats/metricbeat \
		phlax/beatbox:$$BEATS_BRANCH \
		make release
	docker build -t phlax/metricbeat:$$BEATS_BRANCH context/metricbeat

images: metricbeat-image
	docker build --build-arg BEATS_BRANCH=$$BEATS_BRANCH -t phlax/beatbox:$$BEATS_BRANCH context

hub-images:
	docker push phlax/metricbeat:$$BEATS_BRANCH
