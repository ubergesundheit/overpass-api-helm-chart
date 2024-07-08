#!/bin/bash

set -e

DB_DIR=${DB_DIR:-"/app/db"}
DIFF_DIR=${DIFF_DIR:-"/app/diffs"}

# Function to initialize the database if it doesn't exist
init_database() {
    if [ ! -f "$DB_DIR/replicate_id" ]; then
        echo "Initializing database..."
        wget -O "/app/planet.osm.bz2" "$OVERPASS_PLANET_URL"
        /app/osm-3s/bin/init_osm3s.sh "/app/planet.osm.bz2" "$DB_DIR" "/app/osm-3s" --meta="$OVERPASS_META" "--compression-method=$OVERPASS_COMPRESSION"
        rm "/app/planet.osm.bz2"
    fi
}

# Function to fetch and apply updates
fetch_and_apply_updates() {
    echo "Fetching updates..."
    /app/osm-3s/bin/fetch_osc.sh auto "$OVERPASS_DIFF_URL" "$DIFF_DIR" 
    
    echo "Applying updates..."
    /app/osm-3s/bin/apply_osc_to_db.sh "$DIFF_DIR" auto --meta="$OVERPASS_META"
    
    echo "Updating areas..."
    /app/osm-3s/bin/rules_loop.sh "$DB_DIR" "$OVERPASS_RULES_LOAD"
}

# Main execution
init_database

while true; do
    fetch_and_apply_updates
    sleep "$OVERPASS_UPDATE_SLEEP"
done