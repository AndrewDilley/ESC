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

    ev.peak_hours AS [Peak Hours?]
FROM
    [src].[vw_Maximo_WorkOrder_Event_MultiAssets] ma
JOIN
    [src].[vw_Maximo_WaterEvents_Interruptions] ev
    ON ma.recordkey = ev.eventnum
JOIN
    [src].[vw_Maximo_WorkOrders] wo
    ON ev.originating_workorder_num = wo.wonum
WHERE
 ev.actstart >= '2023-06-01'
 AND ev.actstart < '2024-07-01'
 and ev.event_type <> 'PLANNED'
 and ma.serviceaddress_addresscode is not null
 and ma.isprimary = 0
-- and ev.eventnum = 'EV22930'
-- and ma.serviceaddress_addresscode = 43087
 and ma.wwsourceasset is not null
 and ma.serviceaddress_addresscode = 43087



ORDER BY
    ev.actstart;
