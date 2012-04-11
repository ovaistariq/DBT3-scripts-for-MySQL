#!/bin/bash

DIR=`dirname $0`
while [ 1 ];do
            echo `date`
	    grep -i huge /proc/meminfo
            sleep $1
done

