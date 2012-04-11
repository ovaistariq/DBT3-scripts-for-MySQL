-- @(#)6.sql	2.1.8.1
-- TPC-H/TPC-R Forecasting Revenue Change Query (Q6)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	SUM(L_EXTENDEDPRICE*L_DISCOUNT) AS REVENUE
FROM 
	LINEITEM
WHERE 
	L_SHIPDATE >= ':1' 
	AND L_SHIPDATE < dateadd (yy, 1, ':1') 
	AND L_DISCOUNT BETWEEN :2 - 0.01 AND :2 + 0.01 
	AND L_QUANTITY < :3
:e	