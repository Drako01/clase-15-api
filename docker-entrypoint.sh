#!/bin/sh
set -eu

# Prefer Render-provided URLs; fallback to defaults defined in application.properties.
if [ -z "${SPRING_DATASOURCE_URL:-}" ]; then
  if [ -n "${DATABASE_URL:-}" ]; then
    SPRING_DATASOURCE_URL="$DATABASE_URL"
  elif [ -n "${DATABASE_INTERNAL_URL:-}" ]; then
    SPRING_DATASOURCE_URL="$DATABASE_INTERNAL_URL"
  fi
fi

# Render exposes postgres:// URIs, but the JDBC driver expects jdbc:postgresql://.
if [ -n "${SPRING_DATASOURCE_URL:-}" ]; then
  case "$SPRING_DATASOURCE_URL" in
    postgres://*)
      SPRING_DATASOURCE_URL="jdbc:postgresql://${SPRING_DATASOURCE_URL#postgres://}"
      ;;
    postgresql://*)
      SPRING_DATASOURCE_URL="jdbc:postgresql://${SPRING_DATASOURCE_URL#postgresql://}"
      ;;
  esac
  export SPRING_DATASOURCE_URL
fi

exec java $JAVA_OPTS -Dserver.port="${PORT:-8080}" -jar app.jar
