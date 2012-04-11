-- @(#)4.sql	2.1.8.1
-- TPC-H/TPC-R Order Priority Checking Query (Q4)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	O_ORDERPRIORITY, 
	COUNT(*) AS ORDER_COUNT 
FROM 
	ORDERS
WHERE 
	O_ORDERDATE >= ':1' 
	AND O_ORDERDATE < dateadd (mm, 3, ':1') 
	AND EXISTS (
		SELECT * 
		FROM 
			LINEITEM 
		WHERE 
			L_ORDERKEY = O_ORDERKEY 
			AND L_COMMITDATE < L_RECEIPTDATE
	)
GROUP BY 
	O_ORDERPRIORITY
ORDER BY 
	O_ORDERPRIORITY
:e	