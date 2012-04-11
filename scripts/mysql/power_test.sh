#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003-2006 Jenny Zhang & Open Source Development Labs, Inc.
# Copyright (c) 2008 Ingres Corp.

# 15 July 2004: Reworked by Mark Wong

SID=
REFRESH=0
DBDATA=${DSS_PATH}
RESTART=1
OPTIMIZE_DB=1
OUTPUT_DIR=output
SEED_FILE=seed
SCALE_FACTOR=1
QUERIES=NO
QUERIES_RESTART=0
QUERIES_COLD_RUN=1
QUERIES_N_RUN=1
QUERIES_N_EXPLAIN=0
TIMEOUT=0
DATABASE=mysql55

# process the command line parameters
while [ $# -ne 0 ]
do
    case $1 in
    -dbver)     shift;
            DATABASE=$1
        ;;
    -r)     RESTART=1
        ;;
    -nr)    RESTART=0
        ;;
    -d)     shift;
            SID=$1
        ;;
    -f)     shift;
            SCALE_FACTOR=$1
        ;;
    -q)     shift;
            QUERIES=$1
        ;;
    -qrst)  QUERIES_RESTART=1
        ;;
    -nqrst) QUERIES_RESTART=0
        ;;
    -qnr)   shift;
            QUERIES_N_RUN=$1
        ;;
    -qcold)   shift;
            QUERIES_COLD_RUN=$1
        ;;
    -qno)   shift;
            QUERIES_N_EXPLAIN=$1
        ;;
    -o)     shift;
            OUTPUT_DIR=$1
        ;;
    -rf)    REFRESH=1
        ;;
    -nrf)   REFRESH=0
        ;;
    -time)  shift;
	    TIMEOUT=$1
	;;
    *)      echo "Usage: $0"
            echo "  Required options:"
            echo "     -dbver <database version (mysql55|mysql56|mariadb53|mariadb55)>"
            echo "     -d     <database name>"
            echo "  Default options:"
            echo "     -f     <scale factor> (default=1)"
            echo "     -r     restart DBMS"
            echo "     -o     <output dir>  (default=output)"
            echo "  Other options:"
            echo "     -q     list of queries # to run. e.g.: 1,5,9"
            echo "     -qrst  restart DBMS between batches"
            echo "     -nqrst do not restart DBMS between batches (default)"
            echo "     -qnr   number of times to run each query (default=1)"
            echo "     -qcold number of times to do cold runs of each query (default=1)"
            echo "     -qno   number fo times to get query plans (default=0)"
            echo "     -nr    do not restart DBMS"
            echo "     -rf    run refresh functions"
	    echo "     -time  time out in seconds"
            exit 1
            ;;
    esac
    shift
done

export DATABASE
source ../dbt3_profile || exit 1

if [ -z ${SID} ]; then
   er "database name is required."   
fi

if [ -z ${OUTPUT_DIR} ]; then
   er "database name is required."
fi

# Determine a unique identifer for this test run.
if test -f run_number; then
        read RUN_NUMBER < run_number
else
        RUN_NUMBER=1
fi
TAG=$RUN_NUMBER

echo "======================================================="
echo "=  DBT-3 - MySQL - Power Test - SF $SCALE_FACTOR - Run $RUN_NUMBER "
echo "======================================================="
echo `date`
echo


RUN_NUMBER=`expr $RUN_NUMBER + 1`
echo $RUN_NUMBER > run_number

#appending TAG into OUTPUT_DIR
OUTPUT_DIR="$OUTPUT_DIR/$TAG"
mkdir -p $OUTPUT_DIR/results

echo Creating ${OUTPUT_DIR}/run subdirectory to store files used during the test.
RUNDIR=$OUTPUT_DIR/run
mkdir -p $RUNDIR

param_file="$RUNDIR/power_plan.para"
query_file="$RUNDIR/power_plan.sql"
tmp_query_file="$RUNDIR/tmp_power_plan.sql"

echo "creating seed file $SEED_FILE, you can change the seed by modifying this file."
../init_seed.sh > $SEED_FILE

echo "Scale Factor : $SCALE_FACTOR" > $OUTPUT_DIR/readme.txt

SEED=`cat $SEED_FILE`
echo "Seed : $SEED" >> $OUTPUT_DIR/readme.txt

echo "Stopping database."
./stop_db.sh || er "could not stop db"
echo "Starting database."
./start_db.sh || er "coudl not start db"

if [ ${OPTIMIZE_DB} -eq 1 ]; then
    echo "Running optimizedb."
    ./update_statistics.sh $SID || er "could not update statistics"
fi

#s_time_power=$(date +%s)
s_time_power=$($GTIME)


# Execute the queries.
./run_power_query.sh -dbver ${DATABASE} -s ${SCALE_FACTOR} -t ${TAG} -o ${OUTPUT_DIR} -rd ${RUNDIR} \
        -seed ${SEED_FILE} -d ${SID} -q ${QUERIES} -qno ${QUERIES_N_EXPLAIN} -qnr ${QUERIES_N_RUN} \
	-qcold ${QUERIES_COLD_RUN} -qrst ${QUERIES_RESTART} -time ${TIMEOUT} || er "could not run run_power_query.sh script"

#e_time_power=$(date +%s)
e_time_power=$($GTIME)

echo '======================================='
echo '=    Power Test Completed             ='
echo '======================================='
#diff_time=$(expr $e_time_power - $s_time_power)
diff_time=$(echo "$e_time_power - $s_time_power" | bc)
echo "Elapsed time for Power Test : $diff_time seconds"


# stop the db
./stop_db.sh

# store test results
#sort -k2 -k4 -k3 -n ${OUTPUT_DIR}/run/power_input | awk -f show_power_test_results.awk -v field5=${FIELD5} -v sf=${SCALE_FACTOR} >> ${OUTPUT_DIR}/Results

exit 0
