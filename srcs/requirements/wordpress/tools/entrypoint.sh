#!/bin/sh

set -eu

WP_PATH="/var/www/html"
TEMPLATE="/app/wp"

WP_DB_PASSWORD="$(cat "$WP_DB_PASSWORD_FILE")"
WP_ADMIN_PASSWORD="$(cat "$WP_ADMIN_PASSWORD_FILE")"
WP_USER_PASSWORD="$(cat "$WP_USER_PASSWORD_FILE")"

i=0
until mariadb-admin ping -h "$WP_DB_HOST" -P "$WP_DB_PORT" -u "$WP_DB_USER" --password="$WP_DB_PASSWORD" >/dev/null 2>&1; do
	i=$((i + 1))
	[ "$i" -lt 30 ] || { echo "MariaDB not reachable" >&2; exit 1; }
	sleep 1
done

mkdir -p "$WP_PATH"
chown -R wp_user:wp_group "$WP_PATH"
chmod -R u+rwX,go+rX "$WP_PATH"

if [ ! -f "$WP_PATH/wp-load.php" ]; then
	cp -a "$TEMPLATE/." "$WP_PATH/"
	chown -R wp_user:wp_group "$WP_PATH"
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
	su-exec wp_user wp config create --path="$WP_PATH" \
		--dbname="$WP_DB" --dbuser="$WP_DB_USER" --dbpass="$WP_DB_PASSWORD" \
		--dbhost="$WP_DB_HOST:$WP_DB_PORT" --dbprefix="$WP_DB_PREFIX" --skip-check
	su-exec wp_user wp config set FS_METHOD direct --path="$WP_PATH"
fi

if [ ! -f "$WP_PATH/.wp_initialized" ]; then
	su-exec wp_user wp core install --path="$WP_PATH" \
		--url="$WP_WEBSITE_URL" --title="$WP_WEBSITE_TITLE" \
		--admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" --skip-email
	su-exec wp_user wp user create --path="$WP_PATH" \
		"$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD"
	su-exec wp_user touch "$WP_PATH/.wp_initialized"
fi

exec su-exec wp_user php-fpm83 -F
