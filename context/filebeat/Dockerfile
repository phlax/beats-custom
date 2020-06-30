
ARG BUILD_FROM=docker.elastic.co/beats/filebeat:7.9.0-SNAPSHOT

FROM $BUILD_FROM

COPY filebeat.yml /usr/share/filebeat/filebeat.yml
USER root

# add checksum...
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

RUN chown root:filebeat /usr/share/filebeat/filebeat.yml
COPY fields.yml /usr/share/filebeat/fields.yml
RUN chmod go-w /usr/share/filebeat/filebeat.yml \
	&& chmod go-w /usr/share/filebeat/fields.yml
USER filebeat

HEALTHCHECK --interval=10s --timeout=1s --retries=5 \
	CMD curl -s --unix-socket /var/run/filebeat.sock http://localhost/stats | exit $(jq -r '.libbeat.output.write.errors')
