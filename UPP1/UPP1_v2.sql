/* notes
        porg.pk_sts_result_run = 10857 
		
			reflects the results run record where

				pk	    fk_sts_result	fk_financial_year	fk_sts_result_run_parent	month	superseded_flag	result_locked_flag	cycle	result_datetime
				10857	9	            202324	            10795	                    6	    N	            N	                0	2024-06-30 00:00:00.000

			fk_sts_result = 9

			pk	fk_sts_result_type						result_view_name
			9	ESC	MONTHLY	Pension and Rebate Count	dbo.v_sts_act_porg_count_latest_full


		tb.pk_sts_result_run = 10816
  
			reflects the results run record where

				pk		fk_sts_result	fk_financial_year	fk_sts_result_run_parent	month	superseded_flag	result_locked_flag	cycle	result_datetime
				10816	7				202324				10795						6		N				N					4		2024-06-30 00:00:00.000

			fk_sts_result = 7 

				pk	fk_sts_result_type	fk_sts_result_frequency	result_name	   result_view_name
				7	FINANCE	            MONTHLY	                Trial Balance	dbo.v_sts_act_tb_latest_full

*/




SELECT *
FROM (
    -- Credits
    SELECT 
        tb.bill_type_desc,
        tb.pay_arr_desc,
        porg.fk_pension_type,
        SUM(tb.amt_credit) AS amount,
        COUNT(*) AS record_count,
        'CREDIT' AS record_type
    FROM 
        [AQTEST].[dbo].[v_sts_act_tb_full] tb
    LEFT JOIN 
        [AQTEST].[dbo].[v_sts_act_porg_count_full] porg
        ON tb.pk_account = porg.pk_account
        AND porg.pk_sts_result_run = 10857
    WHERE 
        tb.pk_sts_result_run = 10816
        AND tb.amt_credit < 0
    GROUP BY 
        tb.bill_type_desc,
        tb.pay_arr_desc,
        porg.fk_pension_type

    UNION ALL

    -- Debits
    SELECT 
        tb.bill_type_desc,
        tb.pay_arr_desc,
        porg.fk_pension_type,
        SUM(tb.amt_debit) AS amount,
        COUNT(*) AS record_count,
        'DEBIT' AS record_type
    FROM 
        [AQTEST].[dbo].[v_sts_act_tb_full] tb
    LEFT JOIN 
        [AQTEST].[dbo].[v_sts_act_porg_count_full] porg
        ON tb.pk_account = porg.pk_account
        AND porg.pk_sts_result_run = 10857
    WHERE 
        tb.pk_sts_result_run = 10816
        AND tb.amt_debit >= 0
    GROUP BY 
        tb.bill_type_desc,
        tb.pay_arr_desc,
        porg.fk_pension_type
) AS combined
ORDER BY 
    -- Force CREDIT before DEBIT
    CASE record_type 
        WHEN 'CREDIT' THEN 1 
        WHEN 'DEBIT' THEN 2 
        ELSE 3 
    END,
    bill_type_desc,
    pay_arr_desc,
    fk_pension_type;
