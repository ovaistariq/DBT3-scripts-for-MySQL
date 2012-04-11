#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#

source ../dbt3_profile || exit 1
./lockfile.sh

while getopts "c:d:f:r:s:t:" OPT; do
	case ${OPT} in
	c)      CNF=${OPTARG}
		;;
	d)      SID=${OPTARG}
		;;
	f)      DBDATA=${OPTARG}
	        ;;
	r)	RUNDIR=${OPTARG}
		;;
	s)      SF=${OPTARG}
	        ;;
	t)      TAG=${OPTARG}
	        ;;
	esac
done
MYSQL_SOCK=`socket $CNF`

curr_set_file_rf1="$RUNDIR/curr_set_num_rf1"
lock_file_rf1="$RUNDIR/rf1.lock"
min_set_file="$RUNDIR/min_set_num"
max_set_file="$RUNDIR/max_set_num"

# if curr_set_file does not exist, we generate 12 update sets
# create a semaphore file so that only one process can access
# $curr_set_file_rf1 
lockfile-create $lock_file_rf1
if [ ! -f $curr_set_file_rf1 ];
then
	echo "generating update set 1 - 12"
	$DBGEN -s ${SF} -U 12
	echo "1" > ${min_set_file}
	echo "12" > ${max_set_file}
	echo "0" > ${curr_set_file_rf1}
fi
lockfile_remove $lock_file_rf1

lockfile_create $lock_file_rf1
read set_num < $curr_set_file_rf1
read min_set < $min_set_file
read max_set < $max_set_file

set_num=`expr $set_num + 1`
echo $set_num > $curr_set_file_rf1

# if the current set number is larger than max_set, we need to generate new set
if [ $set_num -gt $max_set ]
then
	min_set=`expr $min_set + 12`
	max_set=`expr $max_set + 12`
	echo "Stream ${set_num} : Generating update set $min_set - $max_set..."
	$DBGEN -s ${SF} -U $max_set
	echo "$min_set" > ${min_set_file}
	echo "$max_set" > ${max_set_file}
fi
lockfile_remove $lock_file_rf1

echo "`date`: Stream ${set_num} : Starting Refresh Stream 1..."
s_time=`$GTIME`
echo "insert into time_statistics (tag, task_name, s_time, run_optimize, run_id) values ('${TAG}','PERF.POWER.RF1',`$GTIME`,'F',1)\g COMMIT\g" | mysql -S ${MYSQL_SOCK} $SID

# generate load .sql
mysql -S ${MYSQL_SOCK} -D $SID -e "create table tmp_lineitem$set_num like lineitem;" || er "could not create table tmp_lineitem$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e  "load data infile '${DBDATA}/lineitem.tbl.u$set_num' into table tmp_lineitem$set_num fields terminated by  '|';" || er "could not load data ${DBDATA}/lineitem.tbl.u$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "insert into lineitem select * from tmp_lineitem$set_num;" || er "could not insert into lineitem$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "create table tmp_orders$set_num like orders;" || er "could not create table tmp_orders$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e  "load data infile '${DBDATA}/orders.tbl.u$set_num' into table tmp_orders$set_num fields terminated by '|';" || er "could not load data ${DBDATA}/orders.tbl.u$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "insert into orders select * from tmp_orders$set_num;" || er "could not insert into orders"

# clean up
mysql -S ${MYSQL_SOCK} -D $SID -e "drop table tmp_lineitem$set_num;" || er "could not drop table tmp_lineitem$set_num"
mysql -S ${MYSQL_SOCK} -D $SID -e "drop table tmp_orders$set_num;" || er "could not drop table tmp_orders$set_num"

e_time=`$GTIME`
echo "update time_statistics set e_time=`$GTIME` where tag='${TAG}' and task_name='PERF.POWER.RF1' and run_optimize = 'F' and run_id=1\g COMMIT\g" | mysql -S ${MYSQL_SOCK} $SID

echo "`date`: Stream ${set_num} : Refresh Stream 1 completed."
diff_time=$(echo "scale=0; $e_time_power - $s_time_power" | bc)
echo "Stream ${set_num} : Elapsed time for Refresh Stream 1 : $diff_time seconds"

exit 0
