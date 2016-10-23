#!/usr/bin/env bash

exec 2> >(logger -s -t transfer)
set -e

log() {
  echo "$@"
  logger -p user.notice -t transfer "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t transfer "$@"
}

source /etc/default/paperless-transfer

OUT_DIR=/scans/sent

FILE=$1

NO_PATH=$(basename $FILE)
FILE_NAME=${NO_PATH%.*}

log "Transferring $FILE to $WEBDAV_SERVER/$NO_PATH"
curl -L --user "$WEBDAV_USER:$WEBDAV_PASS" -T $FILE $WEBDAV_SERVER/$NO_PATH --anyauth -sw '%{http_code}\n'

cp $FILE $OUT_DIR/

log "Done"