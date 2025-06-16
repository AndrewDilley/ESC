SELECT 
    f.fk_financial_year,
	f.[bill_type_desc],
    f.[pay_arr_desc],
    pt.[description] AS pension_type_desc,
    COUNT(*) AS RecordCount,
    SUM(f.[amt_credit]) AS TotalCredit
FROM 
    v_sts_act_tb_full f
LEFT JOIN 
    account acc
    ON acc.pk = f.pk_account
    AND acc.fk_property = f.pk_property
LEFT JOIN 
    porg_property pp
    ON pp.fk_account = f.pk_account
    AND pp.pk_property = f.pk_property
    AND pp.date_disconnected IS NULL
    AND pp.prime_debtor_flag = 'Y'
LEFT JOIN 
    person p
    ON p.pk_porg = pp.pk_porg
LEFT JOIN 
    pension_type pt
    ON pt.code = p.fk_pension_type
WHERE 
    f.pk_sts_result_run = 10816
    AND f.amt_credit < 0
GROUP BY 
    f.fk_financial_year,
	f.[bill_type_desc],
    f.[pay_arr_desc],
    pt.[description]
ORDER BY 
    f.[bill_type_desc],
    f.[pay_arr_desc],
    pt.[description];
