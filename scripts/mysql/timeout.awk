#!/bin/awk -f
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2008 Ingres Corp.

BEGIN {
}
{
	if ( NR >= 2 && $6 > TMOUT) {
		id=$1;
		time=$6;
	}
}
END {
	printf("%d\n",id);
}
