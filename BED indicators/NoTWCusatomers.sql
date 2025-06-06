SELECT max([pk])
  FROM [AQTEST].[dbo].[sts_result_run]
  where [fk_sts_result] = 5 and superseded_flag = 'N'

 SELECT 
    fk_district,
    COUNT(DISTINCT pk_property) AS unique_property_count
FROM 
    [AQTEST].[dbo].[v_sts_prop_esc_count_base]
WHERE 
    pk_sts_result_run = 
	
	(SELECT max([pk])
	FROM [AQTEST].[dbo].[sts_result_run]
	where [fk_sts_result] = 5 and superseded_flag = 'N')

	and pk_sts_prop_count_type = 'TW'
GROUP BY 
    fk_district
ORDER BY 
    fk_district;




