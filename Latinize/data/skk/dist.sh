#!/bin/sh -v

DATE=`LANG=C date +%Y%m%d`
DIST=../dist

[ -d $DIST ] || mkdir $DIST

rm -f $DIST/japanese.sqlite.20*.x*

split -b 256000 japanese.sqlite $DIST/japanese.sqlite.$DATE.x || exit 1

(
cd $DIST
for file in japanese.sqlite.$DATE.x??; do
    zip -um9 $file.zip $file || exit 2
done
ls japanese.sqlite.$DATE.x??.zip > japanese.sqlite.list || exit 3
)

ls -l $DIST/japanese.sqlite.list $DIST/japanese.sqlite.$DATE.x??.zip
