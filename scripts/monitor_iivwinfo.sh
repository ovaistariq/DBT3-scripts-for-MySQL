#!/bin/bash

DB=$1
DELAY=$2

DIR=`dirname $0`
while [ 1 ];do
	date
	iivwinfo $DB 2>/dev/null | sed 's/|//g' 
	sleep $DELAY
done

