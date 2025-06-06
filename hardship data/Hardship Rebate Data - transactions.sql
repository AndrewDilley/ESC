/*
This query:
- returns the hardship rebate data which is currently copied and pasted from Aquarate
- into the Hardship Rebates tab of the FC2024/11363 spreadsheet
- developed and tested by Andrew Dilley on 12/5/25
*/


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
    aq.date_active date_raised,
    aq.date_applied,
    aq.date_voided,
    aq.comments
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
/* P =  Payment */
    aq.fk_transact_type = 'P'

/* CN = Credit Note, CNR = Credit Note Reversal , W Write Off = , WR =  Write Off Reversal*/
    AND aq.transact_sub_type IN ('CN', 'CNR', 'W', 'WR') 

    AND cn.description IN ('Hardship Long Term Debt Write Off', 'Hardship Bonus Credits')
    AND aq.date_active BETWEEN '2024-07-01' AND '2025-06-30'
ORDER BY 
    aq.date_active,
    aq.account_no;
