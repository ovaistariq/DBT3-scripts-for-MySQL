#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2008 Ingres Corp.

DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit 1

# $1   defaults file
# $2   database name
# $3   timeout value
CNF=$1
SID=$2
TMOUT=$3

MYSQL_SOCK=`socket $CNF`

while [ 1 ]; do
	id=`echo "show processlist;" | $MYSQL_CLIENT -S ${MYSQL_SOCK} ${SID} | ./timeout.awk -v TMOUT=${TMOUT}`
	if [ $id -ne 0 ]; then
		# id exceeded timeout value
		# mark run_optmize column with A before killing the query
		echo "update time_statistics set run_optimize='A' where e_time is null;" | $MYSQL_CLIENT -S ${MYSQL_SOCK} ${SID}
		
		#kill the query
		echo "kill $id;" | $MYSQL_CLIENT -S ${MYSQL_SOCK} ${SID} > /dev/null 2>&1 
		
#		echo "select task_name as 'Aborted queries so far:' from time_statistics where run_optimize='A'" | $MYSQL_CLIENT -S ${MYSQL_SOCK} ${SID}
	fi
	sleep 10
done	
