#!/bin/bash

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

echo "Updating optimizer statistics..."

host=`uname -n`

if [ -z $1 ]; then
        echo "database name is required."
        exit 1
fi

SID=$1

for table in "customer" "supplier" "part" "lineitem" "orders" "partsupp" "supplier" "region" "nation"; do
	if [ $? -ne 0 ]; then
		break
	fi
	echo "Optimizing table ${table}"
	$MYSQL_CLIENT -D $SID -e "analyze table $table" &
done
wait

