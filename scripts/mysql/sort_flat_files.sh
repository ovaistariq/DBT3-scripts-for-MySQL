#!/bin/bash

#
# Copyright (C) 2007 Ingres Corp.
#
# sort the flat files using keys read in the sort_param file

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

while getopts "d:" opt; do
	case $opt in
	d)
		DSS_PATH=$OPTARG
		;;
	?)
		echo "Usage: $0"
		echo "     -d  flat files directory"	
		exit 1
	esac
done		

echo "Sorting flat files..."

grep -v '#' sort_param | (while [ 1 ]; do
	read file fields
	if [ $? -ne 0 ]; then
		break
	fi
	
	for i in `echo ${fields} | tr ',' '\n'` ; do
    	keys="${keys} -k${i},${i}"   		
	done
	
	echo ${DSS_PATH}/${file}
	sort -t"|" ${keys} ${DSS_PATH}/${file} -T ${DSS_PATH} > ${DSS_PATH}/${file}_tmp
	mv ${DSS_PATH}/${file}_tmp ${DSS_PATH}/${file}
	keys=""
done
wait )

echo Sort completed.
exit 0
