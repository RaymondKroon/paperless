#!/usr/bin/env bash

exec 2> >(logger -s -t clean)
set -e

log() {
  echo "$@"
  logger -p user.notice -t clean "$@"
}

err() {
  echo "$@" >&2
  logger -p user.error -t clean "$@"
}

OUT_DIR=${OUT_DIR:-/scans/cleaned}
FILE=$1

NO_PATH=$(basename $FILE)
FILE_NAME=${NO_PATH%.*}
TMP_DIR=`mktemp -d`

log "Processing $FILE"

tar -xf $FILE -C $TMP_DIR

cd $TMP_DIR

log "Cutting borders..."
for f in scan_*.pnm; do
   log $f
   mogrify -gravity West -chop 50x0 -gravity East -chop 50x0 $f
done

log "Checking for blank pages..."
for f in scan_*.pnm; do
    log "$f"
    histogram=`convert "$f" -threshold 50% -format %c histogram:info:-`
    white=`echo "${histogram}" | grep "#FFFFFF" | sed -n 's/^ *\(.*\):.*$/\1/p'`
    black=`echo "${histogram}" | grep "#000000" | sed -n 's/^ *\(.*\):.*$/\1/p'`
    blank=`echo "scale=4; ${black}/${white} < 0.005" | bc`

    if [ ${blank} -eq "1" ]; then
        log "$f seems to be blank - removing it..."
        rm "$f"
    fi
done

log "Unpaper..."
for f in scan_*.pnm; do
   log $f
   unpaper –size a4 –overwrite "$f" "$f"
done

log "Cleaning pages + png..."
for f in scan_*.pnm; do
   log $f
   convert "$f" -contrast-stretch 1% -level 29%,76% "$f.png"
done

tar cf $FILE_NAME.tar $(ls *.png)
mv $FILE_NAME.tar $OUT_DIR
log "Output saved in $OUT_DIR/$FILE_NAME.tar"

rm -rf $TMP_DIR

log "Done"