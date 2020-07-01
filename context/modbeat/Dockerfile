
ARG BUILD_FROM=modbeat:7.9.0-SNAPSHOT

FROM $BUILD_FROM

USER root

# add checksum...
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

COPY modbeat.yml /usr/share/modbeat/modbeat.yml

RUN chmod go-w /usr/share/modbeat/modbeat.yml \
	&& chmod go-w /usr/share/modbeat/fields.yml

HEALTHCHECK --interval=10s --timeout=1s --retries=5 \
	CMD curl -s --unix-socket /var/run/modbeat.sock http://localhost/stats | exit $(jq -r '.libbeat.output.write.errors')
