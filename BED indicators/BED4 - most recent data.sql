
/*

This query returns the most recent BED 4 data

---------------------
table: sts_result

fk_sts_result = 5

pk	fk_sts_result_type	fk_sts_result_frequency	result_name
5	ESC	MONTHLY	        ESC Property Count


--------------------

table: sts_result

pk_sts_prop_count_type IN ('TW')

code	description
TW	    Trade Waste
---------------------

*/




USE [AQTEST];
GO

;WITH base AS (            -- step 1: count distinct properties per bill type
    SELECT
        bill_type_desc,
        COUNT(DISTINCT full_property_no) AS uniq_cnt
    FROM dbo.v_sts_prop_esc_count_full
    WHERE pk_sts_result_run        = 
		(SELECT max(PK)
			FROM [sts_result_run]
			where fk_sts_result = 5)
      AND pk_sts_prop_count_type IN ('TW')
    GROUP BY bill_type_desc
)
SELECT                      -- step 2: roll them up into the two ESC_Split buckets
    CASE
        WHEN bill_type_desc = 'Major' THEN 'Industrial'
        ELSE 'Commercial'
    END AS ESC_Split,
    SUM(uniq_cnt) AS unique_property_count
FROM base
GROUP BY
    CASE
        WHEN bill_type_desc = 'Major' THEN 'Industrial'
        ELSE 'Commercial'
    END
ORDER BY
    ESC_Split desc;

