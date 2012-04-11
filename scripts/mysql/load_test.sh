#!/bin/bash

TOPDIR=`pwd`/..
SCRIPTDIR=$TOPDIR/scripts
DBSCRIPTDIR=$TOPDIR/mysql


SF=1
SID=
OUTPUT_DIR=output
OPTIMIZE_DB=1
ENGINE=innodb
DATABASE=mysql55

while [ $# -ne 0 ]
do
    case $1 in
    -dbver)     shift;
            DATABASE=$1
        ;;
    -d)     shift;
            SID=$1
        ;;
    -s)     shift;
            SF=$1
        ;;
    -o)     shift;
            OUTPUT_DIR=$1
        ;;
    *)      echo "Usage: $0"
            echo "  Required options:"
	    echo "     -dbver <database version (mysql55|mysql56|mariadb53|mariadb55)"
            echo "     -d     <database name>"
            echo "     -s     scale factor (default=1)"
            echo "     -o     directory to store the results of the output test"
            exit 1
            ;;
    esac
    shift
done

export DATABASE
source ../dbt3_profile

if [ -z ${SID} ]; then
	er "database name is required"	
fi

if [ -z ${OUTPUT_DIR} ]; then
        er "output dir name is required"
fi

echo '====================================='
echo '=     DBT-3 - MySQL - Load Test     ='
echo '====================================='
echo

# Determine a unique identifer for this run.
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
mkdir -p $OUTPUT_DIR

# Generate data for scale factor $SF
echo "Generating data for scale factor $SF..."
${DBGEN} -vf -s $SF || er "could not generate data"
chmod a+r ${DSS_PATH}/*.tbl

# Start the database server
./start_db.sh ${CNF} || er "could not start db"
		

# Create database
echo "drop database if exists $SID;" | $MYSQL_CLIENT

echo "Creating database $SID..."
echo "create database $SID;" | $MYSQL_CLIENT
echo "Database $SID created."

echo "`date +'%Y-%m-%d %H:%M:%S'` Starting Load Test..."
s_time=$(date +%s)

# Create tables
${DBSCRIPTDIR}/create_tables.sh $SID $ENGINE || er "could not create tables"

# Create Primary Keys
echo Creating PKs
$DBSCRIPTDIR/create_pk.sh $SID || er "could not create PKs"

# Load the data
s_load_time=$(date +%s)

cat ddl/tables | (while [ 1 ]; do
read flatfile table
if [ $? -ne 0 ]; then
	break
fi
	
echo "Loading ${table}..."
$MYSQLIMPORT --fields-terminated-by='|' ${SID} /tmp/${flatfile}.tbl
done)
wait
e_load_time=$(date +%s)

diff_load_time=$(expr $e_load_time - $s_load_time)
echo "Data loading duration.: $diff_load_time seconds" >> $OUTPUT_DIR/readme.txt

# Create indexes
echo Creating indexes.
s_idx_time=$(date +%s)
$DBSCRIPTDIR/create_indexes.sh ${SID} || er "could not create indexes"
e_idx_time=$(date +%s)

diff_idx_time=$(expr $e_idx_time - $s_idx_time)
echo "Indexes creation duration.: $diff_idx_time seconds" >> $OUTPUT_DIR/readme.txt

echo "Create statistics"
time ./update_statistics.sh $SID
e_time=$(date +%s)

# stop the db server
./stop_db.sh

echo '======================================='
echo '=    Load Test Completed             ='
echo '======================================='
diff_time=$(expr $e_time - $s_time)
echo "Total Load duration: $diff_time seconds" >> $OUTPUT_DIR/readme.txt
cat $OUTPUT_DIR/readme.txt


exit 0
