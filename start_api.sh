#!/bin/bash

set -e

DB_DIR=${DB_DIR:-"/app/db"}

start_dispatcher() {
    echo "Starting dispatcher..."
    /app/osm-3s/bin/dispatcher --osm-base --meta="$OVERPASS_META" --db-dir="$DB_DIR" &
    chmod 666 "$DB_DIR/osm3s_v0.7.55_osm_base"
}

configure_fcgiwrap() {
    echo "Configuring fcgiwrap..."
    sed -i "s/FCGI_CHILDREN=.*/FCGI_CHILDREN=$OVERPASS_FASTCGI_PROCESSES/" /etc/init.d/fcgiwrap
    service fcgiwrap start
}

configure_overpass() {
    echo "Configuring Overpass settings..."
    echo "$OVERPASS_RATE_LIMIT" > "$DB_DIR/rate_limit"
    echo "$OVERPASS_TIME" > "$DB_DIR/max_allowed_time"
    echo "$OVERPASS_SPACE" > "$DB_DIR/max_allowed_space"
    echo "$OVERPASS_MAX_TIMEOUT" > "$DB_DIR/max_allowed_timeout"
}

if [ "$OVERPASS_MODE" = "update" ]; then
    echo "Running in update mode"
    exec /app/update_overpass.sh
else
    echo "Running in API mode"
    start_dispatcher
    configure_fcgiwrap
    configure_overpass
    nginx -g 'daemon off;'
fi