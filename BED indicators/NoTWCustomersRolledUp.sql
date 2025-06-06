/*

pk_sts_prop_count_type IN ('TW')

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


table: bill_type

code	description
M	Major
N	Non-Residential
R	Residential
RU	Rural



*/






SELECT 
    CASE 
        WHEN fk_bill_type = 'M' THEN 'Industrial'
        ELSE 'Commercial'
    END AS ESC_reporting_classification,
    COUNT(DISTINCT pk_property) AS unique_property_count
FROM 
    [AQTEST].[dbo].[v_sts_prop_esc_count_base]
WHERE 
    pk_sts_result_run = (
        SELECT MAX([pk])
        FROM [AQTEST].[dbo].[sts_result_run]
        WHERE fk_sts_result = 5 
          AND superseded_flag = 'N'
    )
    AND pk_sts_prop_count_type = 'TW'
GROUP BY 
    CASE 
        WHEN fk_bill_type = 'M' THEN 'Industrial'
        ELSE 'Commercial'
    END
ORDER BY 
    ESC_reporting_classification;
