#!/bin/bash
# Script to refresh dependencies in /extra/Develop

TARGET_DIR="/extra/Develop"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR does not exist."
    exit 1
fi

echo "--- Refreshing Dependencies in $TARGET_DIR ---"

# 1. Handle Node.js projects
echo "[Phase 1] Refreshing node_modules..."
find "$TARGET_DIR" -name "node_modules" -type d -prune | while read -r dir; do
    PROJECT_DIR=$(dirname "$dir")
    if [ -f "$PROJECT_DIR/package.json" ]; then
        echo "  -> Refreshing: $PROJECT_DIR"
        rm -rf "$dir"
        (cd "$PROJECT_DIR" && npm install --silent < /dev/null)
    else
        echo "  [Skip] No package.json found in $PROJECT_DIR"
    fi
done

# 2. Handle PHP projects
echo "[Phase 2] Refreshing vendor..."
find "$TARGET_DIR" -name "vendor" -type d -prune | while read -r dir; do
    PROJECT_DIR=$(dirname "$dir")
    if [ -f "$PROJECT_DIR/composer.json" ]; then
        echo "  -> Refreshing: $PROJECT_DIR"
        rm -rf "$dir"
        (cd "$PROJECT_DIR" && composer install --quiet < /dev/null)
    else
        echo "  [Skip] No composer.json found in $PROJECT_DIR"
    fi
done

echo "----------------------------------------"
echo "Refresh complete."
