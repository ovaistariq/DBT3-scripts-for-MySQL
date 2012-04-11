#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002-2006 Open Source Development Labs, Inc.
# Copyright (c) 2008 Ingres Corp.

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

./start_db.sh || er "could not start the dbms"

# $1    database name
# $2    force recreation of existing database (optional)
#       $2 must be 1 to force recreation

if [ -z $1 ]; then
        echo "database name is required."
        exit 1
fi

SID=$1

if [ -z $2 ]; then
        FORCE=0
else
        FORCE=$2
fi

# verify if db exists
CMD=`echo "select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME = '$SID'" | $MYSQL_CLIENT`

if [ -n "$CMD" ]; then
        if [ ${FORCE} -eq 1 ]; then
               echo "drop database $SID;" | $MYSQL_CLIENT
        else
               echo "Database $SID exists. Load aborted"
               exit 1
        fi
else
        echo "Database $SID does not exist."
fi

