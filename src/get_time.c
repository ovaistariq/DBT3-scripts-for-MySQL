/*
 * This file is released under the terms of the Artistic License.  Please see
 * the file LICENSE, included in this package, for details.
 *
 * Copyright (C) 2002 Jenny Zhang & Open Source Development Labs, Inc.
 */

#include <stdio.h>
#include <stdlib.h>

#include <sys/time.h>

int main()
{
	struct timeval tp;
	
	gettimeofday(&tp, NULL);
	printf("%.2f\n", (double)tp.tv_sec + tp.tv_usec/1000000.0);
	return 1;
}
