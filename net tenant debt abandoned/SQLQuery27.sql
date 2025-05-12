SELECT 
    YEAR(aq.date_active) AS year,
    MONTH(aq.date_active) AS month,
    SUM(aq.amount) AS total_amount,
    COUNT(CASE WHEN LTRIM(RTRIM(aq.transact_sub_type)) = 'W' THEN 1 END) AS w_count,
    COUNT(CASE WHEN LTRIM(RTRIM(aq.transact_sub_type)) = 'WR' THEN 1 END) AS wr_count,
    COUNT(CASE WHEN LTRIM(RTRIM(aq.transact_sub_type)) = 'W' THEN 1 END)
      - COUNT(CASE WHEN LTRIM(RTRIM(aq.transact_sub_type)) = 'WR' THEN 1 END) 
      AS accounts_abandoned_no
FROM 
    [AQTEST].[dbo].[aq_transaction] AS aq
JOIN 
    [AQTEST].[dbo].[payment_tran] AS pt ON aq.pk = pt.pk_transaction
JOIN 
    [AQTEST].[dbo].[transact_type] AS tt ON aq.fk_transact_type = tt.code
WHERE 
    aq.fk_transact_type = 'P'
    AND LTRIM(RTRIM(aq.transact_sub_type)) IN ('W', 'WR')
    AND aq.date_active BETWEEN '2024-07-01' AND '2025-06-30'
GROUP BY 
    YEAR(aq.date_active),
    MONTH(aq.date_active)
ORDER BY 
    YEAR(aq.date_active),
    MONTH(aq.date_active);
