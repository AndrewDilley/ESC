USE [AQTEST];
GO

/* ------------------------------------------------------------
   City/Town water consumption summary
   - Residential, Non-Residential, Rural: count (No.) + volume (ML)
   - Totals: customers + volume
   ------------------------------------------------------------ */
SELECT
    district_desc                                         AS [City/Town],

    /* ───────── Residential ───────── */
    COUNT (DISTINCT CASE WHEN bill_type_desc = 'Residential'
                         THEN full_property_no END)       AS [Residential-No.],

    ROUND( SUM(CASE WHEN bill_type_desc = 'Residential'
                    THEN volume + accrued_volume END) 
          / 1000.0 , 1 )                                  AS [Residential-Volume (ML)],

    /* ───────── Non-Residential ───────── */
    COUNT (DISTINCT CASE WHEN bill_type_desc <> 'Residential'
                          AND bill_type_desc <> 'Rural'
                         THEN full_property_no END)       AS [Non Residential-No.],

    ROUND( SUM(CASE WHEN bill_type_desc <> 'Residential'
                     AND bill_type_desc <> 'Rural'
                    THEN volume + accrued_volume END) 
          / 1000.0 , 1 )                                  AS [Non Residential-Volume (ML)],

    /* ───────── Rural ───────── */
    COUNT (DISTINCT CASE WHEN bill_type_desc = 'Rural'
                         THEN full_property_no END)       AS [Rural-No.],

    ROUND( SUM(CASE WHEN bill_type_desc = 'Rural'
                    THEN volume + accrued_volume END) 
          / 1000.0 , 1 )                                  AS [Rural-Volume (ML)],

    /* ───────── Totals ───────── */
    COUNT (DISTINCT full_property_no)                     AS [Total-No.],

    ROUND( SUM(volume + accrued_volume) / 1000.0 , 1 )    AS [Total-Volume (ML)]

FROM dbo.v_sts_prop_fin_year_volume_full
WHERE pk_sts_result_run = 10817
  AND pk_product_type   in ('W','RW')
  AND district_desc NOT LIKE '%Water Works%'
  AND district_desc <> 'Warrnambool Pipeline'
GROUP BY
    district_desc
ORDER BY
    district_desc;
