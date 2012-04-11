#!/bin/bash

# stops timeout script if test is interrupted
trap 'if [ ${TIMEOUT} -ne 0 ]; then kill $TIMEOUTPID; fi; exit 1' TERM INT

DBSCRIPTDIR=`pwd`
SRCDIR=${DBSCRIPTDIR}/..

# process the command line parameters
TIMEOUT=0
DATABASE=

while [ $# -ne 0 ]
do
    case $1 in 
    -dbver) shift;
	   DATABASE=$1
	;; 
    -s)    shift;
           scale_factor=$1
        ;;
    -t)    shift;
           perf_run_number=$1    
        ;;    
    -o)    shift;
           OUTPUT_DIR=$1
        ;;    
    -rd)   shift;
           RUNDIR=$1
        ;;    
    -seed) shift;
           SEED_FILE=$1
        ;;    
    -d)    shift;
           SID=$1
        ;;    
    -q)    shift;
           QUERIES=$1
        ;;    
    -qno)  shift;
           N_EXPLAIN=$1    
        ;;    
    -qnr)  shift;
           N_RUN=$1	# run the query this no of times    
        ;;    
    -qcold)  shift;
           N_COLD=$1	# run the query with cold caches this no of times
        ;;
    -qrst) shift;
           RESTART=$1	# restart the db btw batches of the different queries
        ;;    
    -time) shift;
	   TIMEOUT=$1
	;;
    *)     echo "Usage: -s SCALE_FACTOR -t TAG -o OUTPUT_DIR -rd RUNDIR -seed SEED_FILE -d SID -q QUERIES -qno QUERIES_N_EXPLAIN -qnr QUERIES_N_RUN -qrst QUERIES_RESTART -qcold QUERIES_N_COLD_RUN"
           exit 1
            ;;
    esac
    shift
done

export DATABASE
source ../dbt3_profile || exit 1

if [ -z "${scale_factor}" ]; then
        echo "-s is required"
fi

if [ -z "${perf_run_number}" ]; then
        echo "-t is required"
fi
             
if [ -z "${OUTPUT_DIR}" ]; then
        echo "-o is required"
fi

if [ -z "${RUNDIR}" ]; then
        echo "-rd is required"
fi

if [ -z "${SEED_FILE}" ]; then
        echo "-seed is required"
fi

if [ -z "${SID}" ]; then
        echo "-d is required"
fi

# QGEN uses default substituion parameters (-d) if query validation enabled
# otherwise a seed is passed
QGEN_PARAM="-r `cat ${SEED_FILE}` "

# replace comma(s) with space(s)
QUERIES=`echo ${QUERIES} | sed 's/,/ /g'`

if [ "${QUERIES}" = "NO" ]; then
	# Power Test queries set
	QUERIES="14 2 9 20 6 17 18 8 21 13 3 22 16 4 11 15 1 10 19 5 7 12"
fi

query_file="$RUNDIR/power_query"
tmp_query_file="$RUNDIR/tmp_query.sql"
param_file="$RUNDIR/power_param"

# setup system data collection
COLLECT_DIR="${OUTPUT_DIR}/collected"
mkdir -p ${COLLECT_DIR}

echo ">>> Starting Power Test <<<"
# run batches
for q in ${QUERIES}
do
	query_result_file="${OUTPUT_DIR}/results/query${q}.result"
	query_times_file="${OUTPUT_DIR}/results/query${q}.times"
	#query_collect_dir="${COLLECT_DIR}/q${q}"

	#mkdir -p $query_collect_dir
	#mkdir -p $query_collect_dir/explain
	#mkdir -p $query_collect_dir/cold
	#mkdir -p $query_collect_dir/warm

	#rm -f /tmp/percona-toolkit-collect-lockfile

	cat /tmp/explain_q${q}.txt > ${OUTPUT_DIR}/explain_q${q}.txt
	cat /tmp/q${q}.txt > ${OUTPUT_DIR}/q${q}.txt

	echo "---- Query ${q}"

	# fetch the query execution plan and time it too
        for ((i=1; i <= N_EXPLAIN ; i++))
        do
		#pt-stalk --no-stalk --run-time 86400 --dest ${query_collect_dir}/explain -- --defaults-file=$SANDBOX_CNF > ${query_collect_dir}/explain/stalk.out 2>&1 &
		#sleep 1
                #collect_pid=$(awk '/Collector PID/ {print $4}' ${query_collect_dir}/explain/stalk.out)
	
		echo "-- Query EXPLAIN #${i}" >> ${query_result_file}

		${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_explain_${i}.status
		stime=$($GTIME)
		# ${QGEN} ${QGEN_PARAM} -s ${scale_factor} -l ${param_file} ${q} | sed "s/^select/EXPLAIN EXTENDED select/" | ${MYSQL_CLIENT} ${SID} >> ${query_result_file}
		cat ${OUTPUT_DIR}/explain_q${q}.txt | ${MYSQL_CLIENT} ${SID} >> ${query_result_file}
		etime=$($GTIME)

		echo >> ${OUTPUT_DIR}/results/query${q}_explain_${i}.status
		${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_explain_${i}.status
		
		total_time=$(echo "$etime - $stime" | bc)

		#kill $collect_pid
		echo "EXPLAIN #${i}: $total_time seconds" | tee -a ${query_times_file}
		echo >> ${query_result_file}
        done

	# run the query with cold caches
	for ((i=1; i <= N_COLD; i++))
	do
		$DBSCRIPTDIR/stop_db.sh > /dev/null 2>&1 || er "could not stop db after query ${q}"
		sleep 4s
            	$DBSCRIPTDIR/start_db.sh > /dev/nul 2>&1 || er "could not start db after query ${q}"
	
                #pt-stalk --no-stalk --run-time 86400 --dest ${query_collect_dir}/cold -- --defaults-file=$SANDBOX_CNF > ${query_collect_dir}/cold/stalk.out 2>&1 &
		#sleep 1
		#collect_pid=$(awk '/Collector PID/ {print $4}' ${query_collect_dir}/cold/stalk.out)

		echo "-- COLD Run #${i}" >> ${query_result_file}

		cat ${OUTPUT_DIR}/explain_q${q}.txt | ${MYSQL_CLIENT} ${SID} >> ${query_result_file}
		
		${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_cold_${i}.status
		stime=$($GTIME)
		# ${QGEN} ${QGEN_PARAM} -s ${scale_factor} -l ${param_file} ${q} | ${MYSQL_CLIENT} ${SID} > /dev/null
		cat ${OUTPUT_DIR}/q${q}.txt | ${MYSQL_CLIENT} ${SID} > /dev/null
		etime=$($GTIME)

                echo >> ${OUTPUT_DIR}/results/query${q}_cold_${i}.status
                ${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_cold_${i}.status

		total_time=$(echo "$etime - $stime" | bc)

                #kill $collect_pid
		echo "COLD Run #${i}: $total_time seconds" | tee -a ${query_times_file}
		echo >> ${query_result_file}
	done

	# run the query with warm caches
        for ((i=1; i <= N_RUN ; i++))
        do
                #pt-stalk --no-stalk --run-time 86400 --dest ${query_collect_dir}/warm -- --defaults-file=$SANDBOX_CNF > ${query_collect_dir}/warm/stalk.out 2>&1 &
		#sleep 1
                #collect_pid=$(awk '/Collector PID/ {print $4}' ${query_collect_dir}/warm/stalk.out)

                echo "-- WARM Run #${i}" >> ${query_result_file}

		cat ${OUTPUT_DIR}/explain_q${q}.txt | ${MYSQL_CLIENT} ${SID} >> ${query_result_file}

		${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_warm_${i}.status                
                stime=$($GTIME)
		# ${QGEN} ${QGEN_PARAM} -s ${scale_factor} -l ${param_file} ${q} | ${MYSQL_CLIENT} ${SID} > /dev/null
                cat ${OUTPUT_DIR}/q${q}.txt | ${MYSQL_CLIENT} ${SID} > /dev/null
		etime=$($GTIME)

                echo >> ${OUTPUT_DIR}/results/query${q}_warm_${i}.status
                ${MYSQL_CLIENT} -e "SHOW GLOBAL STATUS" >> ${OUTPUT_DIR}/results/query${q}_warm_${i}.status

                total_time=$(echo "$etime - $stime" | bc)               
 
                #kill $collect_pid
                echo "WARM Run #${i}: $total_time seconds" | tee -a ${query_times_file}
                echo >> ${query_result_file}
        done

	# if restart db btw batches of different queries
	if [ ${RESTART} -eq 1 ]; then
            echo "Restarting DBMS"
            $DBSCRIPTDIR/stop_db.sh > /dev/null 2>&1 || er "could not stop db after query ${q}"
            sleep 4s
            $DBSCRIPTDIR/start_db.sh > /dev/nul 2>&1 || er "could not start db after query ${q}"
        fi
done


exit 0

