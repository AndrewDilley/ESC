SELECT 
    YEAR(aq.date_active) AS year,
    MONTH(aq.date_active) AS month,
    COUNT(*) AS transaction_count,
    SUM(aq.amount) AS total_amount
FROM 
    [AQTEST].[dbo].[aq_transaction] AS aq
JOIN 
    [AQTEST].[dbo].[payment_tran] AS pt ON aq.pk = pt.pk_transaction
JOIN 
    [AQTEST].[dbo].[credit_note] AS cn ON pt.fk_credit_note = cn.code
JOIN 
    [AQTEST].[dbo].[transact_type] AS tt ON aq.fk_transact_type = tt.code
JOIN 
    [AQTEST].[dbo].[pay_tran_type] AS ptt ON aq.transact_sub_type = ptt.code
WHERE 
    aq.fk_transact_type = 'P'
    AND aq.transact_sub_type IN ('CN', 'CNR', 'W', 'WR') 
    AND cn.description IN ('Guaranteed Service Level Rebate')
    AND aq.date_active BETWEEN '2024-07-01' AND '2025-06-30'
GROUP BY 
    YEAR(aq.date_active), 
    MONTH(aq.date_active)
ORDER BY 
    YEAR(aq.date_active), 
    MONTH(aq.date_active);
