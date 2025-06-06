/*
This query provides the most recent Number of Water Customers 
grouped by bill type
and classified into an ESC_report_value, either Residential or Non Residential
*/



SELECT 
    fk_bill_type,
    CASE 
        WHEN fk_bill_type = 'R' THEN 'Residential'
        ELSE 'Non Residential'
    END AS ESC_report_value,
    COUNT(*) AS record_count
FROM 
    [AQTEST].[dbo].[v_sts_prop_annual_count_base]
WHERE 
    [pk_sts_result_run] = (
        SELECT MAX([pk])
        FROM [AQTEST].[dbo].[sts_result_run]
        WHERE [fk_sts_result] = 4
          AND [superseded_flag] = 'N'
    )
    AND pk_sts_prop_count_type IN ('WP', 'WBA')
GROUP BY 
    fk_bill_type,
    CASE 
        WHEN fk_bill_type = 'R' THEN 'Residential'
        ELSE 'Non Residential'
    END
ORDER BY 
    fk_bill_type;
