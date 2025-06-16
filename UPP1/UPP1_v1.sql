-- CREDIT TRANSACTIONS
SELECT 
    1 AS SortOrder,  -- To force credits to appear first
    'Credit' AS TransactionType,
    a.[fk_financial_year],
    a.[bill_type_desc],
    a.[pay_arr_desc],
    p.[pension_type_desc],
    COUNT(*) AS TransactionCount,
    SUM(a.[amt_credit]) AS TotalAmount
FROM 
    [AQTEST].[dbo].[v_sts_act_tb_full] a
INNER JOIN 
    [AQTEST].[dbo].[v_sts_porg_count_full] p
    ON a.[pk_account] = p.[pk_account]
WHERE 
    a.[pk_sts_result_run] = 10816
    AND p.[pk_sts_result_run] IN (
        SELECT [pk]
        FROM [AQTEST].[dbo].[sts_result_run]
        WHERE 
            [fk_sts_result] = 9
            AND [fk_financial_year] = 202324
            AND [superseded_flag] = 'N'
            AND [month] = 6
    )
    AND a.[amt_credit] <> 0
GROUP BY 
    a.[fk_financial_year],
    a.[bill_type_desc],
    a.[pay_arr_desc],
    p.[pension_type_desc]

UNION ALL

-- DEBIT TRANSACTIONS
SELECT 
    2 AS SortOrder,  -- So debits follow credits
    'Debit' AS TransactionType,
    a.[fk_financial_year],
    a.[bill_type_desc],
    a.[pay_arr_desc],
    p.[pension_type_desc],
    COUNT(*) AS TransactionCount,
    SUM(a.[amt_debit]) AS TotalAmount
FROM 
    [AQTEST].[dbo].[v_sts_act_tb_full] a
INNER JOIN 
    [AQTEST].[dbo].[v_sts_porg_count_full] p
    ON a.[pk_account] = p.[pk_account]
WHERE 
    a.[pk_sts_result_run] = 10816
    AND p.[pk_sts_result_run] IN (
        SELECT [pk]
        FROM [AQTEST].[dbo].[sts_result_run]
        WHERE 
            [fk_sts_result] = 9
            AND [fk_financial_year] = 202324
            AND [superseded_flag] = 'N'
            AND [month] = 6
    )
    AND a.[amt_debit] <> 0
GROUP BY 
    a.[fk_financial_year],
    a.[bill_type_desc],
    a.[pay_arr_desc],
    p.[pension_type_desc]

-- Final sorting
ORDER BY 
    SortOrder,
    [bill_type_desc],
    [pay_arr_desc],
    [pension_type_desc];
