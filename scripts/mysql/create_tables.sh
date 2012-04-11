#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2005-2006 Jenny Zhang & Open Source Development Labs, Inc.
# Copyright (c) 2008 Ingres Corp.

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

if [ -z $1 ]; then
	echo "database name is required."
	exit 1
fi

if [ -z $2 ]; then
        echo "engine type is required."
        exit 1
fi

SID=$1
ENGINE=$2

host=`uname -n`

# create the dbt3 benchmark tables
for table in "customer" "supplier" "part" "lineitem" "orders" "partsupp" "region" "nation"; do
	
	if [ -f ddl/${table}.sql ]; then
		echo "drop table if exists ${table};" | $MYSQL_CLIENT $SID
		echo `cat ddl/${table}.sql` " ENGINE=${ENGINE};" | $MYSQL_CLIENT $SID
	fi
done 

# create the table that holds the time stats
if [ -f ddl/time_statistics.sql ]; then
        echo "drop table if exists time_statistics;" | $MYSQL_CLIENT $SID
        echo `cat ddl/time_statistics.sql` ";" | $MYSQL_CLIENT $SID
fi

exit 0
