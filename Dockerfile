# Engram (spaced-repetition flashcards, bestnite/engram) on Railway: official image, binary unmodified, plus a start wrapper.
# Railway changes only: SQLite + media on the /data volume (chowned for the image's uid 10001), HTTPS-aware defaults,
# and a first-boot step that creates the administrator from ENGRAM_ADMIN_PASSWORD on a loopback-only port BEFORE the
# public port opens, so the one-time /setup wizard can never be claimed by whoever finds a fresh deploy first.
FROM docker.io/nite07/engram:v0.3.0
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/engram-srs"
USER 0
RUN apk add --no-cache su-exec curl
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod +x /usr/local/bin/railway-start.sh
ENV HTTP_ADDR=0.0.0.0:8080 \
    DB_DRIVER=sqlite \
    DB_DSN=/data/engram.db \
    AUTO_MIGRATE=1 \
    MEDIA_DIR=/data/media \
    TRUSTED_PROXIES=100.64.0.0/10 \
    ENGRAM_ADMIN_USER=admin \
    BOOTSTRAP_ADMIN_EMAIL=admin@example.com
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
