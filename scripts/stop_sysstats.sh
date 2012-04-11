#!/bin/bash

# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2010 Ingres Corp.
#

er()
{
    echo "ERROR: $1"
}

PIDDIR=`dirname $0`
SELF=`basename $0`

while getopts "o:" opt; do
    case $opt in
        o)
            OUTPUT_DIR=$OPTARG
            COLLECT_DIR="$OUTPUT_DIR/collected"
            LOG_FILE="$COLLECT_DIR/stalk.log"
            PID_FILE="$COLLECT_DIR/stalk.pid"
            ;;
    esac
done

if [ -z ${OUTPUT_DIR} ]; then
    echo "output_dir is required (-o)"
    usage
fi

PID=`cat $PID_FILE`

kill $PID || kill -9 $PID
# do this manually as we do not want to exist on error
if [ $? -ne 0 ]; then
    echo "$0 ERROR: could not kill pid: $PID"
else
    echo "$0 pid: $PID killed"
fi

rm -f $PID_FILE

