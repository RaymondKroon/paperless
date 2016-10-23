#!/usr/bin/env bash

exec 2> >(logger -s -t pdf)
set -e

log() {
  echo "$@"
  logger -p user.notice -t pdf "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t pdf "$@"
}

LANGUAGE="nld"
OUT_DIR=/scans/pdf

FILE=$1

NO_PATH=$(basename $FILE)
FILE_NAME=${NO_PATH%.*}
TMP_DIR=`mktemp -d`

log "Processing $FILE"

tar -xf $FILE -C $TMP_DIR

cd $TMP_DIR

log "Doing OCR..."
for f in scan_*.png; do
  log $f
  tesseract "$f" "$f" -l $LANGUAGE pdf
done

log "Converting PDF..."
pdftk *.png.pdf cat output "$FILE_NAME.pdf"
mv $FILE_NAME.pdf $OUT_DIR/

log "Output saved in $OUT_DIR/$FILE_NAME.pdf"

rm -rf $TMP_DIR

log "Done"