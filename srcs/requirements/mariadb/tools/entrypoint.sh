#!/bin/sh

set -eu

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
MARKER="$DATADIR/.mariadb_configured"

if [ ! -d "$DATADIR/mysql" ]; then
	mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR"
fi

if [ ! -f "$MARKER" ]; then
	MARIADB_PASSWORD="$(cat "$MARIADB_PASSWORD_FILE")"
	MARIADB_ROOT_PASSWORD="$(cat "$MARIADB_ROOT_PASSWORD_FILE")"

	mariadbd --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
	pid="$!"

	i=0
	while [ ! -S "$SOCKET" ] && [ "$i" -lt 30 ]; do
		i=$((i + 1))
		sleep 1
	done
	[ -S "$SOCKET" ] || { echo "MariaDB init: socket not ready" >&2; kill "$pid"; exit 1; }

	mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;"
	mariadb -u root -e "CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';"
	mariadb -u root -e "GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';"
	mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';"
	mariadb -u root --password="$MARIADB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

	mariadb-admin -u root --password="$MARIADB_ROOT_PASSWORD" shutdown

	touch "$MARKER"
fi

exec su-exec mysql mariadbd --datadir="/var/lib/mysql"
