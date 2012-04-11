#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002-2006 Open Source Development Labs, Inc.
# Copyright (c) 2008 Ingres Corp.

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

FORCE=0
RESTART=0
while getopts "d:f:" opt; do
	case $opt in
	d)
		SID=$OPTARG
		;;
	f)
		FORCE=$OPTARG
		;;
	?)
		echo "Usage: $0"	
		echo "     -d  <database name> (required)"
		echo "     -f  force database recreation"
		exit 1
	esac
done

./drop_db.sh $SID $FORCE || er "could not drop the database"

echo "Creating database $SID..."
echo "create database $SID;" | $MYSQL_CLIENT
echo "Database $SID created."

exit 0
