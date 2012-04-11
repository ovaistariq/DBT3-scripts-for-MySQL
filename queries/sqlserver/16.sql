-- @(#)16.sql	2.1.8.1
-- TPC-H/TPC-R Parts/Supplier Relationship Query (Q16)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	P_BRAND, 
	P_TYPE, 
	P_SIZE, 
	COUNT(DISTINCT PS_SUPPKEY) AS SUPPLIER_CNT
FROM 
	PARTSUPP, 
	PART
WHERE 
	P_PARTKEY = PS_PARTKEY 
	AND P_BRAND <> ':1' 
	AND P_TYPE NOT LIKE ':2%%'
	AND P_SIZE IN (:3, :4, :5, :6, :7, :8, :9, :10) 
	AND PS_SUPPKEY NOT IN (
		SELECT 
			S_SUPPKEY 
		FROM 
			SUPPLIER
		WHERE S_COMMENT LIKE '%%Customer%%Complaints%%'
	)
GROUP BY 
	P_BRAND, 
	P_TYPE, 
	P_SIZE
ORDER BY 
	SUPPLIER_CNT DESC, 
	P_BRAND, 
	P_TYPE, 
	P_SIZE
:e	