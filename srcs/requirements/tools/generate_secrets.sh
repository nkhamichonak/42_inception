#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

ENV_FILE="$REPO_ROOT/srcs/.env"

if [ -f "$ENV_FILE" ]; then
	set -a
	. "$ENV_FILE"
	set +a
else
	echo "Error: missing $ENV_FILE" >&2
	exit 1
fi

LOGIN="${LOGIN:-$USER}"

SECRETS_DIR="${SECRETS_DIR:-$REPO_ROOT/secrets}"
CERT_DIR="$SECRETS_DIR/certificate"

mkdir -p "$SECRETS_DIR" "$CERT_DIR"

gen_password_file() {
	local file="$1"
	if [ ! -f "$file" ] || [ ! -s "$file" ]; then
		openssl rand -base64 32 > "$file"
		chmod 600 "$file"
	fi
}

gen_password_file "$SECRETS_DIR/db_password.txt"
gen_password_file "$SECRETS_DIR/db_root_password.txt"
gen_password_file "$SECRETS_DIR/wp_admin_password.txt"
gen_password_file "$SECRETS_DIR/wp_user_password.txt"

KEY="$CERT_DIR/key.pem"
CERT="$CERT_DIR/cert.pem"

if [ ! -f "$KEY" ] || [ ! -s "$KEY" ] || [ ! -f "$CERT" ] || [ ! -s "$CERT" ]; then
	DOMAIN_NAME="${DOMAIN_NAME:-${LOGIN}.42.fr}"

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout "$KEY" \
		-out "$CERT" \
		-subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=42/CN=$DOMAIN_NAME" \
		>/dev/null 2>&1

	chmod 600 "$KEY"
	chmod 644 "$CERT"
fi

CRED="$SECRETS_DIR/credentials.txt"
{
	echo "DOMAIN_NAME=${DOMAIN_NAME:-${LOGIN}.42.fr}"
	echo
	echo "# MariaDB"
	echo "MARIADB_DATABASE=${MARIADB_DATABASE:-}"
	echo "MARIADB_USER=${MARIADB_USER:-}"
	echo "DB_PASSWORD_FILE=./secrets/db_password.txt"
	echo "DB_ROOT_PASSWORD_FILE=./secrets/db_root_password.txt"
	echo

	echo "# TLS"
	echo "TLS_CERT=./secrets/certificate/cert.pem"
	echo "TLS_KEY=./secrets/certificate/key.pem"
	echo

	echo "# WordPress"
	echo "WP_ADMIN_USER=${WP_ADMIN_USER:-}"
	echo "WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-}"
	echo "WP_ADMIN_PASSWORD_FILE=./secrets/wp_admin_password.txt"
	echo
	echo "WP_USER=${WP_USER:-}"
	echo "WP_USER_EMAIL=${WP_USER_EMAIL:-}"
	echo "WP_USER_PASSWORD_FILE=./secrets/wp_user_password.txt"
} > "$CRED"
chmod 644 "$CRED"
