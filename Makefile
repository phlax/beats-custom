#!/usr/bin/make -f

SHELL := /bin/bash


filebeat-image:
	docker pull phlax/beatbox:$$BEATS_BRANCH
	sudo mkdir -p /var/lib/beatbox/src/github.com/elastic
	sudo chown -R travis /var/lib/beatbox
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

metricbeat-image:
	docker pull phlax/beatbox:$$BEATS_BRANCH
	sudo mkdir -p /var/lib/beatbox/src/github.com/elastic
	sudo chown -R travis /var/lib/beatbox
	export modules=$$(cat metricbeat-modules) \
		&& cd /var/lib/beatbox/src/github.com/elastic \
		&& if [ ! -d beats ]; then git clone https://github.com/elastic/beats; fi \
		&& cd beats \
		&& git checkout $$BEATS_BRANCH \
		&& cd metricbeat \
		&& for mod in $$(find module/ -mindepth 1 -maxdepth 1 -type d -name "*" | cut -d/ -f2); do \
			if [ -z "$$(echo $$modules | grep $$mod)" ]; then \
				echo "DISABLING MODULE $$mod"; \
				rm -rf "module/$$mod"; \
			fi; \
		   done
	docker run --rm \
		-v /var/lib/beatbox/pkg/mod:/var/lib/beatbox/pkg/mod \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/beatbox/src/github.com/elastic/beats:/var/lib/beatbox/src/github.com/elastic/beats \
		-w /var/lib/beatbox/src/github.com/elastic/beats/metricbeat \
		-e SNAPSHOT=true \
		-e PLATFORMS=linux/amd64 \
		-e WORKSPACE=/var/lib/beatbox/src/github.com/elastic/beats/metricbeat \
		phlax/beatbox:$$BEATS_BRANCH \
		bash -c "cd .. && make update && git grep aerospike && make release"
	docker build -t phlax/metricbeat:$$BEATS_BRANCH context/metricbeat

images: metricbeat-image
	echo "done"

hub-images:
	docker push phlax/metricbeat:$$BEATS_BRANCH
