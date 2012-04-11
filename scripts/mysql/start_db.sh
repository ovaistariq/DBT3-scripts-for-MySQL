#!/bin/bash

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2005 Mark Wong & Open Source Development Lab, Inc.
# Copyright (c) 2008 Ingres Corp.

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

$MYSQL_START
sleep 3

