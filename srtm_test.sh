#!/bin/bash

CMDNAME=`basename $0`
if [ $# -ne 2 ]; then
	echo "Usage: $CMDNAME file.vrt filelist.txt" 1>&2
	exit 1
fi

src=$1
FILE_LIST=$2
OUTPUT_DIR=./output
res=`echo 1/3600/2 |bc -l`

[ ! -f "$src" ] && { echo "error: $src not found." 1>&2; exit 1; }
[ ! -f "$FILE_LIST" ] && { echo "error: $FILE_LIST not found." 1>&2; exit 1; }
[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR "     1>&2; exit 1; }

while read srtm
do
	[ -f "${OUTPUT_DIR}/${srtm}" ] && { echo "skip ${srtm}" 1>&2; continue; }
	echo -e "\nprocess ${srtm}..."

        xmin=`echo ${srtm} | awk -F / 'substr($NF,4,1)=="E"{print substr($NF,5,3)*1}'`
        ymin=`echo ${srtm} | awk -F / 'substr($NF,1,1)=="N"{print substr($NF,2,2)*1}'`
        xmax=`echo ${xmin}+1 | bc`
        ymax=`echo ${ymin}+1 | bc`
        xmin=`echo ${xmin}-${res} | bc`
        ymin=`echo ${ymin}-${res} | bc`
        xmax=`echo ${xmax}+${res} | bc`
        ymax=`echo ${ymax}+${res} | bc`

#	echo "xmin:${xmin}, ymin:${ymin}, xmax:${xmax}, ymax:${ymax}"

        gdalwarp -te ${xmin} ${ymin} ${xmax} ${ymax} -ts 3601 3601 -r bilinear ${src} ${OUTPUT_DIR}/${srtm}.tif
	gdal_translate -of SRTMHGT ${OUTPUT_DIR}/${srtm}.tif ${OUTPUT_DIR}/${srtm}
        rm -f ${OUTPUT_DIR}/${srtm}.tif

done < $FILE_LIST

echo "done."

