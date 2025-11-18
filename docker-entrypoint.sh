#!/bin/sh
set -eu

log_connection_vars() {
  echo "SPRING_DATASOURCE_URL (initial): ${SPRING_DATASOURCE_URL:-<empty>}"
  echo "DATABASE_URL: ${DATABASE_URL:-<empty>}"
  echo "DATABASE_INTERNAL_URL: ${DATABASE_INTERNAL_URL:-<empty>}"
}

to_jdbc_url() {
  raw="$1"
  # Remove scheme.
  raw="${raw#postgres://}"
  raw="${raw#postgresql://}"
  # Strip credentials (user:pass@) if present.
  host_and_path="${raw#*@}"
  if [ "$host_and_path" = "$raw" ]; then
    host_and_path="$raw"
  fi
  printf 'jdbc:postgresql://%s' "$host_and_path"
}

log_connection_vars

if [ -z "${SPRING_DATASOURCE_URL:-}" ]; then
  if [ -n "${DATABASE_URL:-}" ]; then
    SPRING_DATASOURCE_URL="$DATABASE_URL"
  elif [ -n "${DATABASE_INTERNAL_URL:-}" ]; then
    SPRING_DATASOURCE_URL="$DATABASE_INTERNAL_URL"
  fi
fi

if [ -n "${SPRING_DATASOURCE_URL:-}" ]; then
  case "$SPRING_DATASOURCE_URL" in
    postgres://*|postgresql://*)
      SPRING_DATASOURCE_URL="$(to_jdbc_url "$SPRING_DATASOURCE_URL")"
      ;;
  esac
  export SPRING_DATASOURCE_URL
fi

if [ -z "${SPRING_DATASOURCE_URL:-}" ]; then
  echo "ERROR: No hay ninguna URL de base de datos en SPRING_DATASOURCE_URL/DATABASE_URL/DATABASE_INTERNAL_URL." >&2
  echo "Configura la BD en Render (o ejecuta 'render blueprint deploy') antes de redeployar el servicio." >&2
  exit 1
fi

echo "SPRING_DATASOURCE_URL (resolved): ${SPRING_DATASOURCE_URL:-<empty>}"

exec java $JAVA_OPTS -Dserver.port="${PORT:-8080}" -jar app.jar
