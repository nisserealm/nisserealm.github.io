#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT/assets/map-tiles"
DEST_DIR="$ROOT/assets/map-tiles-web"
MAX_SIZE="${1:-256}"

mkdir -p "$DEST_DIR"

find "$DEST_DIR" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -delete

find "$SRC_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | while read -r src; do
  filename="${src:t}"
  dest="$DEST_DIR/$filename"
  sips -Z "$MAX_SIZE" "$src" --out "$dest" >/dev/null
done

echo "Built web map tiles in $DEST_DIR at max size ${MAX_SIZE}px."
