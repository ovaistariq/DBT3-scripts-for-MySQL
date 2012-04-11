-- @(#)14.sql	2.1.8.1
-- TPC-H/TPC-R Promotion Effect Query (Q14)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	100.00 * SUM (CASE 
		WHEN P_TYPE LIKE 'PROMO%%' 
			THEN L_EXTENDEDPRICE*(1-L_DISCOUNT)
		ELSE 0 
	END) / SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS PROMO_REVENUE
FROM 
	LINEITEM, 
	PART
WHERE 
	L_PARTKEY = P_PARTKEY 
	AND L_SHIPDATE >= ':1' 
	AND L_SHIPDATE < dateadd(mm, 1, ':1')
:e