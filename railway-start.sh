#!/bin/sh
# Railway start wrapper for Engram (the server binary is unmodified).
set -e
mkdir -p /data/media
[ "$(stat -c %u /data)" = "10001" ] || chown -R 10001:10001 /data

MARK=/data/.railway-admin-created
if [ -n "$ENGRAM_ADMIN_PASSWORD" ] && [ ! -f "$MARK" ]; then
  # First boot: run Engram on loopback only, create the admin through its own setup API, then stop it.
  HTTP_ADDR=127.0.0.1:18080 su-exec 10001:10001 /usr/local/bin/engram serve &
  PID=$!
  n=0
  until curl -fsS -o /dev/null http://127.0.0.1:18080/healthz; do
    n=$((n+1)); if [ $n -gt 120 ]; then echo "railway-start: engram did not come up"; kill $PID; exit 1; fi; sleep 1
  done
  T=$(head -c 32 /dev/urandom | base64 | tr -d '\n=+/' )
  BODY=$(printf '{"username":"%s","email":"%s","display_name":"Administrator","password":"%s"}' \
    "$ENGRAM_ADMIN_USER" "$BOOTSTRAP_ADMIN_EMAIL" "$ENGRAM_ADMIN_PASSWORD")
  code=$(curl -sS -o /tmp/setup.out -w '%{http_code}' -X POST http://127.0.0.1:18080/api/v1/auth/setup \
    -H 'Content-Type: application/json' -H "Accept-Language: ${ENGRAM_ADMIN_LOCALE:-en}" -H "X-CSRF-Token: $T" -b "csrf_double=$T" --data-binary "$BODY" || true)
  case "$code" in
    200) echo "railway-start: administrator '$ENGRAM_ADMIN_USER' created from ENGRAM_ADMIN_PASSWORD"; touch "$MARK" ;;
    404) echo "railway-start: an administrator already exists, nothing to do"; touch "$MARK" ;;
    *) echo "railway-start: admin setup failed (HTTP $code): $(cat /tmp/setup.out)"; kill $PID; wait $PID 2>/dev/null; exit 1 ;;
  esac
  rm -f /tmp/setup.out
  kill -TERM $PID; wait $PID 2>/dev/null || true
fi

exec su-exec 10001:10001 /usr/local/bin/engram serve
