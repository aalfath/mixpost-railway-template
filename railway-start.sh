#!/bin/bash
# Railway start script for Mixpost. It follows the image's own start.sh
# (inovector/mixpost), with three changes:
#   1. nginx listens on $PORT (default 80), on IPv4 and IPv6;
#   2. the first admin account gets the password from MIXPOST_ADMIN_PASSWORD
#      instead of the image's fixed "changeme";
#   3. supervisord runs in the foreground, so the container stops (and
#      Railway restarts it) when the app stops.
set -e

: "${DB_HOST:=mysql}"
: "${DB_PORT:=3306}"
: "${PORT:=80}"
export DB_HOST DB_PORT PORT

if [ -z "$APP_KEY" ]; then
  echo "APP_KEY is not set. Set it to base64:<32 random bytes in base64>." >&2
  exit 1
fi

cd /var/www/html

# 1. nginx on $PORT
sed -i -E "s/^\s*listen\s+.*;/    listen ${PORT};\n    listen [::]:${PORT};/" /etc/nginx/sites-enabled/default
# Keep only one pair of listen lines if the script runs again in the same container.
awk '!(/listen/ && seen[$0]++)' /etc/nginx/sites-enabled/default > /tmp/nginx-default && cat /tmp/nginx-default > /etc/nginx/sites-enabled/default

# Volume: media live in storage/app. Recreate the public folder on an empty volume.
mkdir -p storage/app/public storage/logs storage/framework/cache/data storage/framework/sessions storage/framework/views
rm -rf storage/app/lost+found

# Same steps as the image's start.sh
cp -r /var/www/app/commands/* app/Console/Commands
cp -r /var/www/app/migrations database
chown -R www-data:www-data /var/www/html
/var/www/startup/create_env.sh
php artisan optimize

/usr/local/bin/wait-for-it.sh "$DB_HOST:$DB_PORT" -t 120

php artisan mixpost:update-migration-timestamps
php artisan migrate --force
php artisan mixpost:clear-settings-cache
php artisan mixpost:clear-services-cache

# 2. First admin account (only when there are no users yet)
php /var/www/railway/create-admin.php

service cron start

echo "------- Mixpost is starting on port ${PORT} -------"
# 3. supervisord in the foreground (php-fpm, nginx, horizon)
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
