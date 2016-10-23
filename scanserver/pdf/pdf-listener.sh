#!/usr/bin/env bash

exec 2> >(logger -s -t pdf-listener)
set -e

log() {
  echo "$@"
  logger -p user.notice -t pdf-listener "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t pdf-listener "$@"
}

IN_DIR=/scans/cleaned

cat <(ls $IN_DIR) <(inotifywait -t 0 -m $IN_DIR -e move,create --format "%f" 2>/dev/null) |
while read file; do
  log "Found $file, running script"
  pdf.sh $IN_DIR/$file
  log "Cleanup $file"
  rm -f $IN_DIR/$file
  log "Done"
done