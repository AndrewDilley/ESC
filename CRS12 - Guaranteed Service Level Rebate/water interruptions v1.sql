
-- Step 1: Precompute prior 12-month counts for each Address Code and Reported Date
WITH EventData AS (
    SELECT
        ma.serviceaddress_addresscode AS AddressCode,
        ev.actstart AS [Water Off Time]
    FROM
        [src].[vw_Maximo_WorkOrder_Event_MultiAssets] ma
    JOIN
        [src].[vw_Maximo_WaterEvents_Interruptions] ev
        ON ma.recordkey = ev.eventnum
    JOIN
        [src].[vw_Maximo_WorkOrders] wo
        ON ev.originating_workorder_num = wo.wonum
	WHERE
	ev.event_type <> 'PLANNED'
	and ma.wwsourceasset is not null
	and ma.serviceaddress_addresscode = 42011

),
EventCounts AS (
    SELECT
        curr.AddressCode,
        curr.[Water Off Time],
        COUNT(prev.AddressCode) AS Count
    FROM
        EventData curr
    LEFT JOIN EventData prev
        ON curr.AddressCode = prev.AddressCode
        AND prev.[Water Off Time] <= curr.[Water Off Time]
        AND prev.[Water Off Time] >= DATEADD(MONTH, -13, curr.[Water Off Time])
    GROUP BY
        curr.AddressCode,
        curr.[Water Off Time]
),



GSLFlagged AS (
    SELECT
        ma.serviceaddress_addresscode AS [Address Code],
        ma.serviceaddress_description AS [Address],
        ma.wwbilltype AS [Bill Type],
        ma.wwpropertynumber AS [Property Number],
        wo.wonum AS [WO],
        wo.workorder_description AS [Description],
        wo.workorder_completion_date AS [Completed Date],
        wo.workclassification_id AS [Classification],
        ev.eventnum AS [Event],
        wo.reportdate AS [Reported Date],
        ev.event_type AS [Planned?],
        ev.wo_esc_datetime_service_restored AS [Service Restored],
        ev.actstart AS [Water Off Time],
        ev.actfinish AS [Water On Time],
        DATEDIFF(MINUTE, ev.actstart, ev.actfinish) AS [Interruption Time (mins)],
        DATEDIFF(MINUTE, wo.reportdate, ev.actfinish) AS [Restoration Time (mins)],
        ev.peak_hours AS [Peak Hours?],
        ISNULL(ec.Count, 0) AS [Count],
        CASE WHEN ISNULL(ec.Count, 0) = 3 THEN 'Yes' ELSE 'No' END AS [GSL?]
    FROM
        [src].[vw_Maximo_WorkOrder_Event_MultiAssets] ma
    JOIN
        [src].[vw_Maximo_WaterEvents_Interruptions] ev
        ON ma.recordkey = ev.eventnum
    JOIN
        [src].[vw_Maximo_WorkOrders] wo
        ON ev.originating_workorder_num = wo.wonum
    LEFT JOIN
        EventCounts ec
        ON ma.serviceaddress_addresscode = ec.AddressCode
        AND wo.reportdate = ec.[Water Off Time]
    WHERE
        ev.event_type <> 'PLANNED'
		AND ev.actstart >= '2023-06-01'
		AND ev.actstart < '2024-07-01'
 		and ma.wwsourceasset is not null
--		and ma.serviceaddress_addresscode = 42011

)

-- Step 2: Count the number of rows where GSL? = 'Yes'
SELECT COUNT(*) AS [GSL Count]
FROM GSLFlagged
WHERE [GSL?] = 'Yes';
