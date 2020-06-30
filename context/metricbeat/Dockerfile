
ARG BUILD_FROM=docker.elastic.co/beats/metricbeat-oss:7.9.0-SNAPSHOT

FROM $BUILD_FROM

USER root

# add checksum...
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

COPY metricbeat.yml /usr/share/metricbeat/metricbeat.yml

RUN chmod go-w /usr/share/metricbeat/metricbeat.yml \
	&& chmod go-w /usr/share/metricbeat/fields.yml

HEALTHCHECK --interval=10s --timeout=1s --retries=5 \
	CMD curl -s --unix-socket /var/run/metricbeat.sock http://localhost/stats | exit $(jq -r '.libbeat.output.write.errors')
