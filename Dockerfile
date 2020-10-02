FROM alpine:3.12

RUN apk --no-cache add lftp

COPY ls-and-filter.sh /ls-and-filter.sh
COPY deleteaction.sh /deleteaction.sh

ENTRYPOINT ["sh", "/ls-and-filter.sh && /deleteaction.sh"]
