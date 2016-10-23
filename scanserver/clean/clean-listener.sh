#!/usr/bin/env bash

exec 2> >(logger -s -t clean-listener)
set -e

log() {
  echo "$@"
  logger -p user.notice -t clean-listener "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t clean-listener "$@"
}

IN_DIR=/scans/raw

cat <(ls $IN_DIR) <(inotifywait -t 0 -m $IN_DIR -e move,create --format "%f" 2>/dev/null) |
while read file; do
  log "Found $file, running script"
  clean.sh $IN_DIR/$file
  log "Cleanup $file"
  rm -f $IN_DIR/$file
  log "Done"
done