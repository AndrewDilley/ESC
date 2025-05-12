/* water for community
validation query
*/


WITH ranked_transactions AS (
    SELECT 
        aq.[pk],
        aq.[account_no],
        tt.description AS transaction_type,
        ptt.description AS transaction_sub_type,
        aq.[transact_sub_type],
        cn.description AS credit_note,
        aq.fk_transact_status as status,
        aq.fk_account,
        aq.amount,
        aq.date_active AS date_raised,
        aq.date_applied,
        aq.date_voided,
        aq.comments,
        YEAR(aq.date_active) AS year,
        MONTH(aq.date_active) AS month,
        ROW_NUMBER() OVER (PARTITION BY aq.account_no ORDER BY aq.date_active, aq.pk) AS rn
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
        AND cn.description IN ('Community Rebate')
        AND aq.date_active BETWEEN '2024-07-01' AND '2025-06-30'
)

SELECT 
    year,
    month,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN rn = 1 THEN 1 ELSE 0 END) AS new_account_count
FROM ranked_transactions
GROUP BY 
    year,
    month
ORDER BY 
    year,
    month;
