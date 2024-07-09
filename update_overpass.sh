#!/bin/bash

set -e

# Function to download and prepare the planet file
download_and_prepare_planet() {
    local planet_file="/app/planet.osm.pbf"
    
    if [[ $OVERPASS_PLANET_URL == *.pbf ]]; then
        wget -O "$planet_file" "$OVERPASS_PLANET_URL"
        osmium cat "$planet_file" -o "/app/planet.osm"
        bzip2 "/app/planet.osm"
    elif [[ $OVERPASS_PLANET_URL == *.osm.bz2 ]]; then
        wget -O "/app/planet.osm.bz2" "$OVERPASS_PLANET_URL"
    else
        echo "Unsupported planet file format. Please use .pbf or .osm.bz2"
        exit 1
    fi
}

# Function to initialize the database if it doesn't exist
init_database() {
    if [ ! -f "$OVERPASS_DB_DIR/replicate_id" ]; then
        echo "Initializing database..."
        download_and_prepare_planet
        /app/osm-3s/bin/init_osm3s.sh "/app/planet.osm.bz2" "$OVERPASS_DB_DIR" "/app/osm-3s" --meta="$OVERPASS_META" "--compression-method=$OVERPASS_COMPRESSION"
        rm "/app/planet.osm.bz2"
        echo "Database initialization complete."
    fi
}

# Function to fetch and apply updates
fetch_and_apply_updates() {
    echo "Fetching updates..."
    /app/osm-3s/bin/fetch_osc.sh $OVERPASS_UPDATE_FREQUENCY "$OVERPASS_DIFF_URL" "$OVERPASS_DIFF_DIR" 
    
    echo "Applying updates..."
    /app/osm-3s/bin/apply_osc_to_db.sh "$OVERPASS_DIFF_DIR" $OVERPASS_UPDATE_FREQUENCY --meta="$OVERPASS_META"
    
    echo "Updating areas..."
    /app/osm-3s/bin/rules_loop.sh "$OVERPASS_DB_DIR" "$OVERPASS_RULES_LOAD"
}

# Main execution
init_database

# Main execution
fetch_and_apply_updates
echo "Update process completed."