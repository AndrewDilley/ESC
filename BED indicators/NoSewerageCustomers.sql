/*
This query provides the most recent Number of Sewerage Customers 

pk_sts_prop_count_type IN ('SP')

table: sts_prop_count_type

code	description
ES	EQT Based Sewer Assessments
PA	Property Assessments
SA	Sewer Assessments
SC	Sewer Connections
SP	Sewer Properties
TW	Trade Waste
US	Unconnected Sewer
UW	Unconnected Water
WA	Water Assessments
WBA	Water By Agreement
WC	Water Connections
WP	Water Properties


grouped by bill_type

table: bill_type

code	description
M	Major
N	Non-Residential
R	Residential
RU	Rural


[fk_sts_result] = 4

table: sts_result

pk	fk_sts_result_type	fk_sts_result_frequency	result_name
4	ANNUAL	MONTHLY	Annual Property Count

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
    AND pk_sts_prop_count_type IN ('SP')
GROUP BY 
    fk_bill_type,
    CASE 
        WHEN fk_bill_type = 'R' THEN 'Residential'
        ELSE 'Non Residential'
    END
ORDER BY 
    fk_bill_type;
