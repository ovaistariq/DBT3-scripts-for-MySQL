-- @(#)13.sql	2.1.8.1
-- TPC-H/TPC-R Customer Distribution Query (Q13)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	C_COUNT, 
	COUNT(*) AS CUSTDIST
FROM 
	(SELECT 
		C_CUSTKEY, 
		COUNT(O_ORDERKEY)
	FROM 
		CUSTOMER left outer join ORDERS 
			on C_CUSTKEY = O_CUSTKEY
			AND O_COMMENT not like '%%:1%%:2%%'
	GROUP BY 
		C_CUSTKEY
	) AS C_ORDERS (C_CUSTKEY, C_COUNT)
GROUP BY 
	C_COUNT
ORDER BY 
	CUSTDIST DESC,
	C_COUNT DESC
:e