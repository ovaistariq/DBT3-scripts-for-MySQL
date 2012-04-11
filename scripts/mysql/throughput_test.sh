#!/bin/bash
# 
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003-2006 Jenny Zhang & Open Source Development Labs, Inc.
# Copyright (c) 2008 Ingres Corp.

# 15 July 2004: Reworked by Mark Wong

# stops timeout script if test is interrupted
trap 'if [ ${TIMEOUT} -ne 0 ]; then kill $TIMEOUTPID; fi; exit 1' TERM INT

DBSCRIPTDIR=`pwd`
SCRIPTDIR=${DBSCRIPTDIR}/..
SRCDIR=${SCRIPTDIR}/..

source ../dbt3_profile || exit 1

clearprof () {
	readprofile -m /boot/System.map-`uname -r` -r
}

getprof () {
	readprofile -n -m /boot/System.map-`uname -r` -v | sort -grk3,4 > $OUTPUT_DIR/readprofile.txt
}

clearoprof () {
	opcontrol --vmlinux=${KERNEL_IMAGE}
	sleep 2
	opcontrol --start-daemon
	sleep 2
	opcontrol --start
	sleep 2
	# If opcontrol ever gets stuck here, sometimes it helps to remove
	# everything in this dir:
	# /var/lib/oprofile
	opcontrol --reset
}

getoprof () {
	mkdir -p $OUTPUT_DIR/oprofile/annotate
	opcontrol --dump
	opreport -l -o $OUTPUT_DIR/oprofile/oprofile.txt
	opcontrol --stop
	opcontrol --shutdown
#	opannotate --source --assembly > $OUTPUT_DIR/oprofile/assembly.txt 2>&1
	opannotate --source --output-dir=$OUTPUT_DIR/oprofile/annotate
	opreport -l -c -p /lib/modules/`uname -r` -o ${OUTPUT_DIR}/oprofile/call-graph.txt > /dev/null 2>&1
}

CNF=
SID=
USE_OPROFILE=0
REFRESH=0
DBDATA=${DSS_PATH}
RESTART=1
OPTIMIZE_DB=1
PLANS=0
OUTPUT_DIR=output
SEED_FILE=seed
SCALE_FACTOR=1
NUM_STREAMS=2
STATS=0
QUERIES=NO
QUERIES_RESTART=0
QUERIES_N_RUN=1
QUERIES_N_OPTMZ=0
PREFIX_FILE=0
POSTFIX_FILE=0
KERNEL_IMAGE=/boot/vmlinux
WRAPPER=0
TIMEOUT=0

# process the command line parameters
while [ $# -ne 0 ]
do
    case $1 in
    -pre)   shift;
	    PREFIX_FILE=$1
	;;
    -pos)   shift;
	    POSTFIX_FILE=$1
	;;
    -r)     RESTART=1
        ;;
    -nr)    RESTART=0
        ;;
    -cnf)   shift;
            CNF=$1
        ;;
    -d)     shift;
            SID=$1
        ;;
    -df)    shift;
            DBDATA=$1
        ;;
    -f)     shift;
            SCALE_FACTOR=$1
        ;;
    -k)
            shift;
            KERNEL_IMAGE=$1
	;;
    -n)     shift;
            NUM_STREAMS=$1
        ;;
    -p)     PLANS=1
        ;;
    -np)    PLANS=0
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
    -qno)   shift;
	    QUERIES_N_OPTMZ=$1
	;;
    -m)     OPTIMIZE_DB=1
        ;;
    -nm)    OPTIMIZE_DB=0
        ;;    
    -o)     shift;
            OUTPUT_DIR=$1
        ;;
    -s)     shift;
            SEED_FILE=$1        
        ;;
    -st)    STATS=1
        ;;
    -nst)   STATS=0
	;;
    -y)     USE_OPROFILE=1
        ;;
    -ny)    USE_OPROFILE=0
        ;; 
    -rf)    REFRESH=1
        ;;
    -nrf)   REFRESH=0
        ;;
    -time)  shift;
	    	TIMEOUT=$1
		;;
    -wrap)  WRAPPER=1	    
		;;        
    *)      echo "Usage: $0"
            echo "  Required options:"
            echo "     -d     <database name>"
            echo "     -cnf   <cnf file>"
            echo "  Default options:"
            echo "     -f     <scale factor> (default=1)"
            echo "     -r     restart DBMS"
            echo "     -df    <data dir>  (default=${DSS_PATH})"
            echo "     -np    do not generate QEPs"
            echo "     -m     run optimizedb"
            echo "     -o     <output dir>  (default=output)"
            echo "     -s     <seed file>   (default=seed)"
            echo "            if not exists, the file will be created and initialized"
            echo "     -ny    do not use oprofile"
            echo "     -nrf   do not run refresh functions"
	    echo "     -nst   do not collect system statistics"           
	    echo "     -n     number of streams (default=$NUM_STREAMS)"
            echo "  Other options:"
	    echo "     -q     list of queries # to run. e.g.: 1,5,9"
	    echo "     -qrst  restart DBMS between batches"
	    echo "     -nqrst do not restart DBMS between batches (default)"
	    echo "     -qnr   number of times to run each query (default=1)"
	    echo "     -qno   number fo times to optimize_only each query (default=0)"
            echo "     -nr    do not restart DBMS"
	    echo "     -nm    do no run optimizedb"
            echo "     -p     generate QEPs"
            echo "     -y     use oprofile"
            echo "     -rf    run refresh functions"
            echo "     -st    collect system statistics"
	    echo "     -pre   prefix sql file"
	    echo "     -pos   postfix sql file"
            echo "     -k     kernel image file (default=/boot/vmlinux)"
	    echo "     -wrap  generate output for demo wrapper"
	    echo "     -time  time out in seconds"            
            exit 1
            ;;
    esac
    shift
done

if [ -z ${SID} ]; then
   echo "database name is required."
   exit 1
fi        

if [ -z ${CNF} ]; then
   er "CNF file is required."
fi

echo '============================================'
echo '=     DBT-3 - MySQL - Throughput Test      ='
echo '============================================'
echo `date`
echo

# Determine a unique identifer for this test run.
if test -f run_number; then
        read RUN_NUMBER < run_number
else
        RUN_NUMBER=1
fi
TAG=$RUN_NUMBER

RUN_NUMBER=`expr $RUN_NUMBER + 1`
echo $RUN_NUMBER > run_number

#appending TAG into OUTPUT_DIR
OUTPUT_DIR="$OUTPUT_DIR/$TAG"
mkdir -p $OUTPUT_DIR/results

echo Creating ${OUTPUT_DIR}/run subdirectory to store files used during the test.
RUNDIR=$OUTPUT_DIR/run
mkdir -p $RUNDIR

MYSQL_SOCK=`socket $CNF`

param_file="$RUNDIR/power_plan.para"
query_file="$RUNDIR/power_plan.sql"
tmp_query_file="$RUNDIR/tmp_power_plan.sql"

if [ ! -f $SEED_FILE ]; then
	echo "creating seed file $SEED_FILE, you can change the seed by "
	echo "modifying this file."
	$SRCDIR/scripts/init_seed.sh > $SEED_FILE
fi

SEED=`cat $SEED_FILE`
echo "Seed : $SEED" > $OUTPUT_DIR/readme.txt

if [ ${RESTART} -eq 1 ]; then
    echo "Stopping database."
    $DBSCRIPTDIR/stop_db.sh ${CNF} || er "could not stop db"
    echo "Starting database."
    $DBSCRIPTDIR/start_db.sh ${CNF} || er "coudl not start db"
fi

if [ ${OPTIMIZE_DB} -eq 1 ]; then
    echo "Running optimizedb."
    $DBSCRIPTDIR/update_statistics.sh $SID $CNF || er "could not update statistics"
fi

if [ ${STATS} -eq 1 ]; then
    # Start collecting system statistics.
    echo "Start collecting system statistics."
    $SCRIPTDIR/start_sysstats.sh -o $OUTPUT_DIR || er "could not start sysstats"
fi

# Clear the read profile counters.
if [ -f /proc/profile ]; then
	clearprof
fi

# Clear the oprofile counters.
if [ $USE_OPROFILE -eq 1 ]; then
	clearoprof
fi

if [ ${TIMEOUT} -ne 0 ]; then
	./timeout.sh ${CNF} ${SID} ${TIMEOUT} &
	TIMEOUTPID=$!
fi

s_time_thru=`$GTIME`

# Start the streams
i=1
while [ $i -le $NUM_STREAMS ]
do
	${DBSCRIPTDIR}/run_throughput_stream.sh -cnf ${CNF} -s ${SCALE_FACTOR} -t ${TAG} -o ${OUTPUT_DIR} -rd ${RUNDIR} -n ${i} \
        	-seed ${SEED_FILE} -d ${SID} -q ${QUERIES} -qno ${QUERIES_N_OPTMZ} -qnr ${QUERIES_N_RUN} \
	        -qrst ${QUERIES_RESTART} -pre ${PREFIX_FILE} -pos ${POSTFIX_FILE} -p ${PLANS} -time ${TIMEOUT} \
			-wrap ${WRAPPER} || er "could not run run_throughput_stream.sh script" &
        let "i=$i+1"
done

if [ ${REFRESH} -eq 1 ]; then
        # Start the refresh stream.  The throughput tests runs a streams
        # consecutively per throughput streams, also consecutively.
        stream_num=1
        while [ $stream_num -le $NUM_STREAMS ]
        do
#               ${DBSCRIPTDIR}/record_start.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}"

                echo "`date`: Throughput Stream $stream_num : Starting Refresh Stream 1..."
                s_time_rf1=`$GTIME`

#               ${DBSCRIPTDIR}/record_start.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}.RF1"
		${DBSCRIPTDIR}/run_rf1.sh -s ${SCALE_FACTOR} -r ${RUNDIR} -f ${DBDATA} -c ${CNF} -d ${SID} -t ${TAG} > $OUTPUT_DIR/results/thruput.perf${TAG}.stream${stream_num}.rf1.result 2>&1 || er "could not run RF1"
#               ${DBSCRIPTDIR}/record_end.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}.RF1"

                e_time_rf1=`$GTIME`
                echo "`date`: Throughput Stream $stream_num : Refresh Stream 1 completed."
                let "diff_time_rf1=$e_time_rf1-$s_time_rf1"
                echo "Throughput Stream $stream_num : Elapsed time for Refresh Stream 1 : $diff_time_rf1 seconds"

                echo "`date`: Throughput Stream $stream_num : Starting Refresh Stream 2..."
                s_time_rf2=`$GTIME`

#               ${DBSCRIPTDIR}/record_start.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}.RF2"
		${DBSCRIPTDIR}/run_rf2.sh -r ${RUNDIR} -d ${SID} -c ${CNF} -f ${DBDATA} -t ${TAG} > ${OUTPUT_DIR}/results/thruput.perf${TAG}.stream${stream_num}.rf2.result 2>&1 || er "could not run RF2"
#               ${DBSCRIPTDIR}/record_end.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}.RF2"

                e_time_rf2=`$GTIME`
                echo "`date`: Throughput Stream $stream_num : Refresh Stream 2 completed."
                let "diff_time_rf2=$e_time_rf2-$s_time_rf2"
                echo "Throughput Stream $stream_num : Elapsed time for Refresh Stream 2 : $diff_time_rf2 seconds"

#               ${DBSCRIPTDIR}/record_end.sh -l ${DBPORT} -n "PERF${TAG}.THRUPUT.RFST${stream_num}"

                let "stream_num=$stream_num+1"
        done
fi

wait

e_time_thru=`$GTIME`

echo '======================================='
echo '=    Throughput Test Completed        ='
echo '======================================='
diff_time=$(echo "$e_time_thru-$s_time_thru" | bc)

if [ ${TIMEOUT} -ne 0 ]; then 
	echo "kill timeout"
	kill $TIMEOUTPID
fi

if [ ${STATS} -eq 1 ]; then
	# Stop collecting system statistics.
	echo "Stop collecting system statistics."
	$SCRIPTDIR/stop_sysstats.sh $OUTPUT_DIR
fi

# Store test results
echo "Test Results" >> ${OUTPUT_DIR}/Results
echo "" >> ${OUTPUT_DIR}/Results

echo "Measurement Interval: $diff_time seconds" >> ${OUTPUT_DIR}/Results
echo "" >> ${OUTPUT_DIR}/Results

echo "Duration of Stream Execution:" >> ${OUTPUT_DIR}/Results
echo "select stream, sum(e_time - s_time) as duration from time_statistics where tag='${TAG}' group by stream order by stream;" | mysql -S ${MYSQL_SOCK} $SID >> ${OUTPUT_DIR}/Results
echo "" >> ${OUTPUT_DIR}/Results

echo "Timing Intervals:" >> ${OUTPUT_DIR}/Results
echo "select stream, task_name as query, (e_time - s_time) as duration, run_optimize as operation, run_id as run_number from time_statistics where tag='${TAG}' order by stream, mid(task_name, 13, 1), run_optimize, run_id;" | mysql -S ${MYSQL_SOCK} $SID >> ${OUTPUT_DIR}/Results
echo "" >> ${OUTPUT_DIR}/Results

# calculate the throughput metric

if [ ${QUERIES} == "NO" ]; then
	num_q=22
else
	QUERIES=`echo ${QUERIES} | sed 's/,/ /g'`
	num_q=0

	for q in ${QUERIES}
	do
		let "num_q=$num_q+1"
	done
fi

echo "num_q = $num_q"
echo "num_streams = ${NUM_STREAMS}"
echo "diff_time = ${diff_time}"
echo "scale factor=${SCALE_FACTOR}"

THRU_METRIC=$(echo "scale=2; ((${NUM_STREAMS} * ${num_q} * 3600) / ${diff_time}) * ${SCALE_FACTOR}" | bc -l)

echo "================================" >> ${OUTPUT_DIR}/Results
echo "Throughput Metric@${SCALE_FACTOR} = $THRU_METRIC" >> ${OUTPUT_DIR}/Results
echo "================================" >> ${OUTPUT_DIR}/Results

# Show test results
cat ${OUTPUT_DIR}/Results

if [ -f /proc/profile ]; then
	profname="Throughput_Test_$TAG"
	getprof
fi

if [ $USE_OPROFILE -eq 1 ]; then
	profname="Throughput_Test_$TAG"
	getoprof
fi

exit 0
