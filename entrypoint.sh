#!/bin/sh

# Set defaults
DATABASE_PATH="${DATABASE_PATH:-/app/data/database.db}"
MASTODON_BASE_URL="${MASTODON_BASE_URL:-https://techhub.social}"

echo "Configuring cron job with dynamic environment variables..."

# Write out the cron job to /etc/cron.d/toot-cron.
# System cron daemon requires an extra newline at the end of the crontab file to be parsed correctly.
echo "0 * * * * root DATABASE_PATH=\"$DATABASE_PATH\" MASTODON_ACCESS_TOKEN=\"$MASTODON_ACCESS_TOKEN\" MASTODON_BASE_URL=\"$MASTODON_BASE_URL\" /usr/local/bin/toot >> /var/log/cron.log 2>&1
" > /etc/cron.d/toot-cron

chmod 0644 /etc/cron.d/toot-cron

# Touch log file so we can tail it or check it if needed
touch /var/log/cron.log

# Start system cron daemon
echo "Starting cron..."
cron

# Start Nginx in the foreground
echo "Starting Nginx..."
exec nginx -g "daemon off;"
