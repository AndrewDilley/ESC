
/* this query returns the total ESC volumes for 2023/2024


pk_sts_result_run = 10817


pk	fk_sts_result_type	fk_sts_result_frequency	result_name
1	VOLUME	            MONTHLY	                Fin Year Volume

*/


USE [AQTEST];
GO

;WITH split AS (
    SELECT
        CASE
            WHEN bill_type_desc = 'Residential'
                 THEN 'Residential'
            ELSE 'Non Residential'           -- catches Rural + every other non-res type
        END                                   AS category,
        SUM(volume + accrued_volume) / 1000.0 AS total_ml_raw
    FROM dbo.v_sts_prop_fin_year_volume_full
    WHERE pk_sts_result_run = 10817
      AND pk_product_type   IN ('W', 'RW')
    GROUP BY
        CASE
            WHEN bill_type_desc = 'Residential' THEN 'Residential'
            ELSE 'Non Residential'
        END
)
SELECT
    category                         AS [ESC_Split],
    ROUND(total_ml_raw, 1)           AS [Total-Volume (ML)]
FROM split
ORDER BY
    CASE WHEN category = 'Residential' THEN 0 ELSE 1 END;   -- puts Residential first
