#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#

DBSCRIPTDIR=`pwd`
SRCDIR=${DBSCRIPTDIR}/..
source ../dbt3_profile || exit 1
. ${DBSCRIPTDIR}/lockfile.sh

while getopts "c:d:f:r:t:" OPT; do
	case ${OPT} in
	c)      CNF=${OPTARG}
		;;
	d)      SID=${OPTARG}
		;;
	f)      DBDATA=${OPTARG}
	        ;;
	r)	RUNDIR=${OPTARG}
		;;
	t)      TAG=${OPTARG}
	        ;;
	esac
done
MYSQL_SOCK=`socket $CNF`

curr_set_file_rf1="$RUNDIR/curr_set_num_rf1"
curr_set_file_rf2="$RUNDIR/curr_set_num_rf2"
lock_file_rf1="$RUNDIR/rf1.lock"
lock_file_rf2="$RUNDIR/rf2.lock"

# if set_num_file_rf1 does not exist, exit since rf1 has to run before rf2
lockfile_create $lock_file_rf1
if [ ! -f $curr_set_file_rf1 ];
then
        echo "Stream ${set_num} : please run run_rf1.sh first"
	exit 1
fi
set_num_rf1=`cat $curr_set_file_rf1`
lockfile_remove $lock_file_rf1

lockfile_create $lock_file_rf2
if [ ! -f $curr_set_file_rf2 ];
then
	echo 0 > $curr_set_file_rf2
fi

read set_num < $curr_set_file_rf2

set_num=`expr $set_num + 1`
if [ $set_num -gt $set_num_rf1 ]
then
	echo "Stream ${set_num} : rf2 set number is greater than rf1 set number"
	echo "Stream ${set_num} : please execute run_rf1.sh first"
	exit 1
fi

echo $set_num > $curr_set_file_rf2
lockfile_remove $lock_file_rf2

echo "`date`: Stream ${set_num} : Starting Refresh Stream 2..."
s_time=`$GTIME`
echo "insert into time_statistics (tag, task_name, s_time, run_optimize, run_id) values ('${TAG}','PERF.POWER.RF2',`$GTIME`,'F',1)\g COMMIT\g" | mysql -S ${MYSQL_SOCK} $SID

# generate load .sql
mysql -S ${MYSQL_SOCK} -D $SID -e "create table tmp_orderkey$set_num (orderkey numeric(10));" || er "could not create table tmp_orderkey$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "load data infile '${DBDATA}/delete.$set_num' into table tmp_orderkey$set_num fields terminated by '|';" || er "could not load data ${DBDATA}/delete.$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "delete from lineitem using lineitem, tmp_orderkey$set_num where l_orderkey=tmp_orderkey$set_num.orderkey;" || er "could not delete from lineitem"
mysql -S ${MYSQL_SOCK} -D $SID -e "delete from orders  using orders, tmp_orderkey$set_num where o_orderkey=tmp_orderkey$set_num.orderkey;" || er "could not delete from orders"

# clean up
mysql -S ${MYSQL_SOCK} -D $SID -e "drop table tmp_orderkey$set_num;" || er "could not drop table tmp_orderkey$set_num"

e_time=`$GTIME`
echo "update time_statistics set e_time=`$GTIME` where tag='${TAG}' and task_name='PERF.POWER.RF2' and run_optimize = 'F' and run_id=1\g COMMIT\g" | mysql -S ${MYSQL_SOCK} $SID

echo "`date`: Stream ${set_num} : Refresh Stream 2 completed."
diff_time=$(echo "scale=0; $e_time_power - $s_time_power" | bc)
echo "Stream ${set_num} : Elapsed time for Refresh Stream 2 : $diff_time seconds"

exit 0
