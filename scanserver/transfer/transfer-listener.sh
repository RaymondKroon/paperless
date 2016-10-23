#!/usr/bin/env bash

exec 2> >(logger -s -t transfer-listener)
set -e

log() {
  echo "$@"
  logger -p user.notice -t transfer-listener "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t transfer-listener "$@"
}

IN_DIR=/scans/pdf

cat <(ls $IN_DIR) <(inotifywait -t 0 -m $IN_DIR -e move,create --format "%f" 2>/dev/null) |
while read file; do
  log "Found $file, running script"
  transfer.sh $IN_DIR/$file
  log "Cleanup $file"
  rm -f $IN_DIR/$file
  log "Done"
done