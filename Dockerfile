FROM alpine:3.12

RUN apk --no-cache add lftp

COPY filter-and-delete.sh /filter-and-delete.sh
COPY ls-and-filter.sh /ls-and-filter.sh
COPY deleteaction.sh /deleteaction.sh

RUN chmod +x /ls-and-filter.sh
RUN chmod +x /filter-and-delete.sh
RUN chmod +x /deleteaction.sh

ENTRYPOINT ["sh", "/filter-and-delete.sh"]
