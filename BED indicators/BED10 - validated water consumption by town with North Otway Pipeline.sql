USE [AQTEST];
GO

/* ──────────────────────────
   CTE #1 — “regular” districts
   ────────────────────────── */
WITH q1 AS (
    SELECT
        district_desc                                                 AS [City/Town],

        /* Residential */
        COUNT(DISTINCT CASE WHEN bill_type_desc = 'Residential'
                             THEN full_property_no END)               AS [Residential-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc = 'Residential'
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Residential-Volume (ML)],

        /* Non-Residential (everything except Residential & Rural) */
        COUNT(DISTINCT CASE WHEN bill_type_desc NOT IN ('Residential', 'Rural')
                             THEN full_property_no END)              AS [Non Residential-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc NOT IN ('Residential', 'Rural')
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Non Residential-Volume (ML)],

        /* Rural */
        COUNT(DISTINCT CASE WHEN bill_type_desc = 'Rural'
                             THEN full_property_no END)              AS [Rural-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc = 'Rural'
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Rural-Volume (ML)],

        /* Totals */
        COUNT(DISTINCT full_property_no)                              AS [Total-No.],
        ROUND(SUM(volume + accrued_volume) / 1000.0 , 1)              AS [Total-Volume (ML)]
    FROM dbo.v_sts_prop_fin_year_volume_full
    WHERE pk_sts_result_run = 10817
      AND pk_product_type   IN ('W', 'RW')
      AND district_desc NOT LIKE '%Water Works%'      -- exclude Water Works…
      AND district_desc <> 'Warrnambool Pipeline'     -- …and Warrnambool Pipeline
    GROUP BY district_desc
),

/* ──────────────────────────
   CTE #2 — North Otway Pipeline
   ────────────────────────── */
q2 AS (
    SELECT
        'North Otway Pipeline'                                        AS [City/Town],

        /* Residential */
        COUNT(DISTINCT CASE WHEN bill_type_desc = 'Residential'
                             THEN full_property_no END)              AS [Residential-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc = 'Residential'
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Residential-Volume (ML)],

        /* Non-Residential */
        COUNT(DISTINCT CASE WHEN bill_type_desc NOT IN ('Residential', 'Rural')
                             THEN full_property_no END)              AS [Non Residential-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc NOT IN ('Residential', 'Rural')
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Non Residential-Volume (ML)],

        /* Rural */
        COUNT(DISTINCT CASE WHEN bill_type_desc = 'Rural'
                             THEN full_property_no END)              AS [Rural-No.],
        ROUND(
            SUM(CASE WHEN bill_type_desc = 'Rural'
                     THEN volume + accrued_volume END) / 1000.0 , 1) AS [Rural-Volume (ML)],

        /* Totals */
        COUNT(DISTINCT full_property_no)                              AS [Total-No.],
        ROUND(SUM(volume + accrued_volume) / 1000.0 , 1)              AS [Total-Volume (ML)]
    FROM dbo.v_sts_prop_fin_year_volume_full
    WHERE pk_sts_result_run = 10817
      AND pk_product_type   IN ('W', 'RW')
      AND (
            district_desc = 'Warrnambool Pipeline'
            OR district_desc LIKE '%Water Works%'
          )
)

/* ──────────────────────────
   UNION and final ordering
   ────────────────────────── */
SELECT *
FROM q1
UNION ALL
SELECT *
FROM q2
ORDER BY [City/Town];   -- alphabetical list, North Otway Pipeline in place
