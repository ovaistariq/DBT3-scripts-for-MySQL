-- @(#)22.sql	2.1.8.1
-- TPC-H/TPC-R Global Sales Opportunity Query (Q22)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
SELECT 
	CNTRYCODE, 
	COUNT(*) AS NUMCUST, 
	SUM(C_ACCTBAL) AS TOTACCTBAL
FROM (
	SELECT 
		SUBSTRING(C_PHONE,1,2) AS CNTRYCODE, 
		C_ACCTBAL
	FROM 
		CUSTOMER 
	WHERE 
		SUBSTRING(C_PHONE,1,2) IN (':1', ':2', ':3', ':4', ':5', ':6', ':7') 
		AND C_ACCTBAL > (
			SELECT 
				AVG(C_ACCTBAL) 
			FROM 
				CUSTOMER 
			WHERE 
				C_ACCTBAL > 0.00 
				AND SUBSTRING(C_PHONE,1,2) IN (':1', ':2', ':3', ':4', ':5', ':6', ':7')
		) 
		AND NOT EXISTS ( 
			SELECT * 
			FROM 
				ORDERS 
			WHERE 
				O_CUSTKEY = C_CUSTKEY
		)
	) AS CUSTSALE
GROUP BY 
	CNTRYCODE
ORDER BY 
	CNTRYCODE
:e