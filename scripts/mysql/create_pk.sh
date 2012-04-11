#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2008 Ingres Corp.

# Parallel index creation with an alter table per table
 
DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit

if [ -z $1 ]; then
        echo "database name is required."
        exit 1
fi

SID=$1

$MYSQL_CLIENT $SID < ddl/create_pk.sql || er "could not create PK(s)"

exit 0
