FROM alpine

RUN apk add --no-cache bash docker curl

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
