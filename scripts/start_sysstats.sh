#!/bin/bash

# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2010 Ingres Corp.
#

source dbt3_profile

usage()
{
cat << EOF
usage: $0 options

The script starts the programs to collect system statistics (iostat, vmstat).

OPTIONS:
    -d  <name>      database name
    -o  <dir>       output dir
    -s  <integer>   sample length
EOF
exit
}

PIDDIR=`dirname $0`
SAMPLE_LENGTH=60
unset DB

while getopts "d:o:s:" opt; do
    case $opt in
	d)
	    DB=$OPTARG
	    ;;
        o)
            OUTPUT_DIR=$OPTARG
	    COLLECT_DIR="$OUTPUT_DIR/collected"
	    LOG_FILE="$COLLECT_DIR/stalk.log"
	    PID_FILE="$COLLECT_DIR/stalk.pid"
            ;;
	s)
            SAMPLE_LENGTH=$OPTARG
            ;;
    esac
done

if [ -z ${OUTPUT_DIR} ]; then
    echo "output_dir is required (-o)"
    usage
fi


INTERVAL_LENGTH=$(( $SAMPLE_LENGTH * 3 ))

mkdir -p $COLLECT_DIR

echo "Starting stats collection using $COLLECT_DIR"

pt-stalk --dest=$COLLECT_DIR --run-time=$SAMPLE_LENGTH --sleep=$INTERVAL_LENGTH --daemonize --function=status --variable=Threads_running --threshold=0 --log=$LOG_FILE --pid=$PID_FILE -- --defaults-file=$SANDBOX_CNF


