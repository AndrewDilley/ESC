USE [AQTEST];
GO

;WITH base AS (            -- step 1: count distinct properties per bill type
    SELECT
        bill_type_desc,
        COUNT(DISTINCT full_property_no) AS uniq_cnt
    FROM dbo.v_sts_prop_esc_count_full
    WHERE pk_sts_result_run        = 10819
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


	