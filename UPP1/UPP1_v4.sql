
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



/*
stage 1 - create a temp table #combined_data that contains the combined totals of credits and debits
(run the queries from here until stage 2)
*/


SELECT 
    tb.bill_type_desc,
    tb.pay_arr_desc,
    pt.description AS pension_type,
    tb.pk_account
INTO #combined_data
FROM [AQTEST].[dbo].[v_sts_act_tb_full] tb
LEFT JOIN [AQTEST].[dbo].[v_sts_act_porg_count_full] porg
    ON tb.pk_account = porg.pk_account
    AND porg.pk_sts_result_run = 10857
LEFT JOIN [AQTEST].[dbo].[pension_type] pt
    ON porg.fk_pension_type = pt.code
WHERE tb.pk_sts_result_run = 10816
    AND (
        tb.amt_credit < 0 
        OR tb.amt_debit > 0
    );

SELECT
    bill_type_desc AS [Bill Type],
    pay_arr_desc AS [Pay Arr. Type],
    pension_type AS [Pension],
    COUNT(DISTINCT pk_account) AS [TotalCount]
FROM #combined_data
WHERE bill_type_desc IS NOT NULL
  AND pay_arr_desc IS NOT NULL
GROUP BY 
    bill_type_desc,
    pay_arr_desc,
    pension_type
ORDER BY 
    bill_type_desc,
    pay_arr_desc,
    pension_type;


/*
stage 2 -  create another temp table #final_results that has the summed UPP1 totals that go into the ESC report
(run from here to stage 3)

*/


-- Create the final results table
CREATE TABLE #final_results (
    Indicator NVARCHAR(100),
    Split INT
);


INSERT INTO #final_results (Indicator, Split)
SELECT 
    'Non-residential',
    SUM(TotalCount)
FROM (
    SELECT
        bill_type_desc AS [Bill Type],
        pay_arr_desc AS [Pay Arr. Type],
        pension_type AS [Pension],
        COUNT(DISTINCT pk_account) AS [TotalCount]
    FROM #combined_data
    WHERE bill_type_desc IS NOT NULL
      AND pay_arr_desc IS NOT NULL
    GROUP BY 
        bill_type_desc,
        pay_arr_desc,
        pension_type
) AS grouped
WHERE [Bill Type] IN ('Non-Residential', 'Rural');



INSERT INTO #final_results (Indicator, Split)
SELECT 
    'Residential Concession',
    SUM(TotalCount)
FROM (
    SELECT
        bill_type_desc AS [Bill Type],
        pay_arr_desc AS [Pay Arr. Type],
        pension_type AS [Pension],
        COUNT(DISTINCT pk_account) AS [TotalCount]
    FROM #combined_data
    WHERE bill_type_desc IS NOT NULL
      AND pay_arr_desc IS NOT NULL
    GROUP BY 
        bill_type_desc,
        pay_arr_desc,
        pension_type
) AS grouped
WHERE [Bill Type] = 'Residential'
  AND [Pension] IS NOT NULL;

INSERT INTO #final_results (Indicator, Split)
SELECT 
    'Residential non-concession',
    SUM(TotalCount)
FROM (
    SELECT
        bill_type_desc AS [Bill Type],
        pay_arr_desc AS [Pay Arr. Type],
        pension_type AS [Pension],
        COUNT(DISTINCT pk_account) AS [TotalCount]
    FROM #combined_data
    WHERE bill_type_desc IS NOT NULL
      AND pay_arr_desc IS NOT NULL
    GROUP BY 
        bill_type_desc,
        pay_arr_desc,
        pension_type
) AS grouped
WHERE [Bill Type] = 'Residential'
  AND [Pension] IS NULL;


select * from #final_results 
order by Indicator desc;


/*
stage 3 - cleanup - run the statements below
*/

DROP TABLE #combined_data;

DROP TABLE #final_results;
