/*
This query provides the Number of Water Customers 
grouped by district

    
	v.pk_sts_result_run = 10818


    v.pk_sts_prop_count_type in ('WBA', 'WP')



*/

SELECT 
    v.fk_district,
    d.description AS district,
    v.fk_bill_type,
    COUNT(*) AS record_count
FROM 
    [AQTEST].[dbo].[v_sts_prop_annual_count_base] AS v
JOIN 
    [AQTEST].[dbo].[district] AS d ON v.fk_district = d.code
WHERE 
    v.pk_sts_result_run = 10818
    AND v.pk_sts_prop_count_type in ('WBA', 'WP')
GROUP BY 
    v.fk_district,
    d.description,
    v.fk_bill_type
ORDER BY 
    v.fk_district,
    v.fk_bill_type;

