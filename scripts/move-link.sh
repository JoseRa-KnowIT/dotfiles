#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
  echo "Error: Invalid number of arguments" >&2
  echo "  move-link.sh <file_path> <target_dir>" >&2
  exit 1
fi

FILE="$1"
DESTDIR="$(realpath "$2")"

mkdir -p "$DESTDIR"
cp -p "$FILE" "$DESTDIR/"
ln -sf "$DESTDIR/$(basename "$FILE")" "$FILE"

echo "$FILE --> $DESTDIR"