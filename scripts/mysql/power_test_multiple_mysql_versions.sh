#!/bin/bash

## Change the path here according to your environment
output_dir_main="/mnt/data/benchmarks/dbt3_output"

## No particular changes needed here
while [ $# -ne 0 ]
do
    case $1 in
    -s)    shift;
           scale_factor=$1
        ;;
    -q)    shift;
           QUERY_NUM=$1
        ;;
    -d)    shift;
           SID=$1
	;;
    *)     echo "Usage: -s SCALE_FACTOR -d DB_NAME -q QUERY_NUM"
           exit 1
            ;;
    esac
    shift
done

export DATABASE="mysql55"
source ../dbt3_profile || exit 1

if [ -z "${scale_factor}" ]; then
        echo "-s is required"
	exit
fi

if [ -z "${SID}" ]; then
        echo "-d is required"
	exit
fi

if [ -z "${QUERY_NUM}" ]; then
        echo "-q is required"
fi

# create the output directory
output_dir_mysql55="${output_dir_main}/mysql_55/sf_${scale_factor}/q${QUERY_NUM}"
output_dir_mysql56="${output_dir_main}/mysql_56/sf_${scale_factor}/q${QUERY_NUM}"
output_dir_mariadb55="${output_dir_main}/mariadb_55/sf_${scale_factor}/q${QUERY_NUM}"

mkdir -p $output_dir_mysql55
mkdir -p $output_dir_mysql56
mkdir -p $output_dir_mariadb55

# generate the query
explain_query_file="/tmp/explain_q${QUERY_NUM}.txt"
query_file="/tmp/q${QUERY_NUM}.txt"

${QGEN} ${QGEN_PARAM} -s ${scale_factor} ${QUERY_NUM} > ${query_file}
cat ${query_file} | sed "s/^select/EXPLAIN EXTENDED select/" > ${explain_query_file}

echo "===== Benchmarking MySQL 5.5"
echo
./power_test.sh -dbver mysql55 -d $SID -f $scale_factor -o $output_dir_mysql55 -q $QUERY_NUM -qnr 5 -qcold 5 -qno 1
echo

echo "===== Benchmarking MySQL 5.6"
echo
./power_test.sh -dbver mysql56 -d $SID -f $scale_factor -o $output_dir_mysql56 -q $QUERY_NUM -qnr 5 -qcold 5 -qno 1
echo

echo "===== Benchmarking MariaDB 5.5"
echo
./power_test.sh -dbver mariadb55 -d $SID -f $scale_factor -o $output_dir_mariadb55 -q $QUERY_NUM -qnr 5 -qcold 5 -qno 1

