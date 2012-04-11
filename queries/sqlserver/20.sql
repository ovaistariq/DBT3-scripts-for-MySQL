-- @(#)20.sql	2.1.8.1
-- TPC-H/TPC-R Potential Part Promotion Query (Q20)
-- Function Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	S_NAME, 
	S_ADDRESS 
FROM 
	SUPPLIER, 
	NATION
WHERE 
	S_SUPPKEY IN ( 
		SELECT 
			PS_SUPPKEY 
		FROM 
			PARTSUPP 
		WHERE 
			PS_PARTKEY in (
				SELECT 
					P_PARTKEY 
				FROM 
					PART 
				WHERE 
					P_NAME like ':1%%'
			) 
			AND PS_AVAILQTY > (
				SELECT 
					0.5 * sum(L_QUANTITY) 
				FROM 
					LINEITEM 
				WHERE 
					L_PARTKEY = PS_PARTKEY 
					AND L_SUPPKEY = PS_SUPPKEY 
					AND L_SHIPDATE >= ':2'
					AND L_SHIPDATE < dateadd(yy,1,':2')
			)
	) 
	AND S_NATIONKEY = N_NATIONKEY 
	AND N_NAME = ':3'
ORDER BY 
	S_NAME
:e