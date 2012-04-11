#!/bin/bash
#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (c) 2008 Ingres Corp.

# Parallel index creation with an alter table per table
 
DIR=`dirname $0`
. ${DIR}/${DATABASE}_profile || exit

if [ -z $1 ]; then
        echo "database name is required."
        exit 1
fi

SID=$1

# lineitem (changed)
# add index i_l_partkey (l_partkey),
echo "alter table lineitem 
  add index i_l_shipdate (l_shipdate),
  add index i_l_suppkey_partkey (l_partkey, l_suppkey), 
  add index i_l_partkey(l_partkey, l_quantity, l_shipmode, l_shipinstruct),
  add index i_l_suppkey (l_suppkey),
  add index i_l_receiptdate (l_receiptdate),
  add index i_l_orderkey (l_orderkey),
  add index i_l_orderkey_quantity (l_orderkey, l_quantity), 
  add index i_l_commitdate (l_commitdate);"  | $MYSQL_CLIENT $SID &

# orders
echo "alter table orders
  add index i_o_orderdate (o_orderdate), 
  add index i_o_custkey (o_custkey);"  | $MYSQL_CLIENT $SID &

# part (added by me)
echo "alter table part
  add index i_p_size(p_size, p_brand, p_partkey);"  | $MYSQL_CLIENT $SID &

# partsupp
echo "alter table partsupp
  add index i_ps_partkey (ps_partkey),
  add index i_ps_suppkey (ps_suppkey);"  | $MYSQL_CLIENT $SID &

# supplier
echo "alter table supplier
  add index i_s_nationkey (s_nationkey);"  | $MYSQL_CLIENT $SID &

# customer
echo "alter table customer
  add index i_c_nationkey (c_nationkey);" | $MYSQL_CLIENT $SID &

# nation
echo "alter table nation
  add index i_n_regionkey (n_regionkey);" | $MYSQL_CLIENT $SID &

wait

exit 0
