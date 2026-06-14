#!/bin/sh
set -e

wait_for_db() {
  echo "==> Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."
  i=0
  while [ "$i" -lt 30 ]; do
    if node -e "const { Client } = require('pg'); const c = new Client({ host: process.env.DB_HOST, port: Number(process.env.DB_PORT || 5432), user: process.env.DB_USER, password: process.env.DB_PASSWORD, database: process.env.DB_NAME }); c.connect().then(() => { c.end(); process.exit(0); }).catch(() => process.exit(1));"; then
      echo "==> PostgreSQL is ready."
      return 0
    fi
    i=$((i + 1))
    sleep 2
  done
  echo "==> PostgreSQL did not become ready in time."
  exit 1
}

wait_for_db

echo "==> Running database migrations..."
npm run db:migrate

echo "==> Running database seeds..."
npm run db:seed

echo "==> Starting API server..."
exec npm run start