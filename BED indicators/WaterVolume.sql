/*
This query provides water volumes for 23/24  

--------
table: sts_result_run

pk_sts_result_run = 10817

pk	    fk_sts_result	fk_financial_year	fk_sts_result_run_parent	month	superseded_flag	result_locked_flag	cycle	result_datetime	        result_rowcount	archive_flag	accrual_flag
10817	1	            202324	            10795	                    0	     Y	            N	                 0	    2024-06-30 00:00:00.000	50886	        N	             Y

--------------
table: sts_result

fk_sts_result = 1

pk	fk_sts_result_type	fk_sts_result_frequency	result_name	next_run_date	last_run_date	result_view_name
1	VOLUME	MONTHLY	Fin Year Volume	NULL	2025-05-04 11:26:01.407	dbo.v_sts_prop_fin_year_volume_latest_full

-------------

table: product_type

pk_product_type = 'W'

code	description
MTW	Major Trade Waste
RCW	Recycled Water
RVS	Rural Volume Surcharge
RW	Raw Water
S	Sewerage
W	Water
WVS	Water Volume Surcharge

-------------


*/







SELECT 
    fk_district,
    fk_bill_type,
    COUNT(*) AS record_count,
    SUM(volume) AS total_volume,
    AVG(no_of_days) AS average_no_of_days
FROM 
    [AQTEST].[dbo].[v_sts_prop_fin_year_volume_full]
WHERE 
    pk_sts_result_run = 10817
    AND pk_product_type = 'W'
GROUP BY 
    fk_district,
    fk_bill_type
ORDER BY 
    fk_district,
    fk_bill_type;
