-- @(#)17.sql	2.1.8.1
-- TPC-H/TPC-R Small-Quantity-Order Revenue Query (Q17)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	SUM(L_EXTENDEDPRICE)/7.0 AS AVG_YEARLY 
FROM 
	LINEITEM, 
	PART
WHERE 
	P_PARTKEY = L_PARTKEY 
	AND P_BRAND = ':1' 
	AND P_CONTAINER = ':2'
	AND L_QUANTITY < (
		SELECT 
			0.2 * AVG(L_QUANTITY) 
		FROM 
			LINEITEM 
		WHERE L_PARTKEY = P_PARTKEY
	)
:e