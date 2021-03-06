/*************************************************************************/
/*                                                                       */
/*                       (c) 2010-2020 Enginatics GmbH                   */
/*                              www.enginatics.com                       */
/*                                                                       */
/*************************************************************************/
-- Report Name: INV Period Close txn checker
-- Description: ** Queries Used to Display the Counts in the Inventory Account Periods form  (Doc ID 357997.1)**
The following Blitz Report mimicks the counts found in the Inventory Accounting Period close form. 
1. The following parameters are used:
OrgID -- The Organization id.
StartPeriodDate -- The start period date for the period in question.
EndPeriodDate -- The end period date for the period in question.
2. The following SQL can be used to find the organization id:
select a.organization_id, b.organization_code, a.name
from HR_ALL_ORGANIZATION_UNITS_TL a, mtl_parameters_view b
where a.organization_id = b.organization_id
order by organization_id, organization_code **/
-- Excel Examle Output: https://www.enginatics.com/example/inv-period-close-txn-checker/
-- Library Link: https://www.enginatics.com/reports/inv-period-close-txn-checker/
-- Run Report: https://demo.enginatics.com/


SELECT 'UNPROCESSED MATERIAL TXNS TEMP' "TYPE OF ISSUE", 
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
       APPS.MTL_PARAMETERS            MP,
       APPS.GL_PERIODS                GP
 WHERE
 1=1 
   AND NVL(MMTT.TRANSACTION_STATUS, 0) <> 2
   AND MP.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
   AND TRUNC(NVL(MMTT.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE
UNION
SELECT 'UNCOSTED MATERIAL TXNS' "TYPE OF ISSUE",
       COUNT(*),
      GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM MTL_MATERIAL_TRANSACTIONS MMT,
       APPS.MTL_PARAMETERS       MP,
       APPS.GL_PERIODS           GP
 WHERE
 1=1 
   AND COSTED_FLAG IS NOT NULL
   AND MP.ORGANIZATION_ID = MMT.ORGANIZATION_ID
   AND TRUNC(NVL(MMT.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION
SELECT 'PENDING WIP TXNS' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
      GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM WIP_COST_TXN_INTERFACE WCTI,
       APPS.MTL_PARAMETERS    MP,
       APPS.GL_PERIODS        GP
 WHERE
 1=1 
   AND MP.ORGANIZATION_ID = WCTI.ORGANIZATION_ID
   AND TRUNC(NVL(WCTI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'UNCOSTED LOT JOBS' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE

  FROM WSM_SPLIT_MERGE_TRANSACTIONS WSMW, --  PENDING WSM - LOT BASED JOBS UNCOSTED (DOC ID 1967981.1)
       APPS.MTL_PARAMETERS          MP,
       APPS.GL_PERIODS              GP
 WHERE
 1=1 
   AND COSTED <> 4
   AND MP.ORGANIZATION_ID = WSMW.ORGANIZATION_ID
   AND TRUNC(NVL(WSMW.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
--AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'PENDING WSM INTERFACE' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE

  FROM WSM_SPLIT_MERGE_TXN_INTERFACE WSMTI,
       APPS.MTL_PARAMETERS           MP,
       APPS.GL_PERIODS               GP

 WHERE
 1=1 
   AND PROCESS_STATUS <> 4
   AND MP.ORGANIZATION_ID = WSMTI.ORGANIZATION_ID
   AND TRUNC(NVL(WSMTI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'PENDING LCM INTERFACE' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE

  FROM CST_LC_ADJ_INTERFACE CLAI,
       APPS.MTL_PARAMETERS  MP,
       APPS.GL_PERIODS      GP

 WHERE
 1=1 
   AND MP.ORGANIZATION_ID = CLAI.ORGANIZATION_ID
   AND TRUNC(NVL(CLAI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'PENDING RECEIVING RFIX' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM RCV_TRANSACTIONS_INTERFACE RTI,
       APPS.MTL_PARAMETERS        MP,
       APPS.GL_PERIODS            GP
 WHERE
 1=1 
   AND DESTINATION_TYPE_CODE = 'INVENTORY'
   AND MP.ORGANIZATION_ID = RTI.TO_ORGANIZATION_ID
   AND TRUNC(NVL(RTI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION
SELECT 'PENDING MATERIAL' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM MTL_TRANSACTIONS_INTERFACE MTI,
       APPS.MTL_PARAMETERS        MP,
       APPS.GL_PERIODS            GP
 WHERE
 1=1 
   AND PROCESS_FLAG <> 9
   AND MP.ORGANIZATION_ID = MTI.ORGANIZATION_ID
   AND TRUNC(NVL(MTI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION
SELECT 'PENDING SHOP FLOOR MOVE' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM WIP_MOVE_TXN_INTERFACE WMTI,
       APPS.MTL_PARAMETERS    MP,
       APPS.GL_PERIODS        GP

 WHERE
 1=1 
   AND MP.ORGANIZATION_ID = WMTI.ORGANIZATION_ID
   AND TRUNC(NVL(WMTI.TRANSACTION_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'UNPROC SHIPPING TXNS' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM WSH_DELIVERY_DETAILS     WDD,
       WSH_DELIVERY_ASSIGNMENTS WDA,
       WSH_NEW_DELIVERIES       WND,
       WSH_DELIVERY_LEGS        WDL,
       WSH_TRIP_STOPS           WTS,
       APPS.MTL_PARAMETERS      MP,
       APPS.GL_PERIODS          GP
 WHERE 
 1=1
   AND WDD.SOURCE_CODE = 'OE'
   AND WDD.RELEASED_STATUS = 'C'
   AND WDD.INV_INTERFACED_FLAG IN ('N', 'P')
   AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
   AND WND.DELIVERY_ID = WDA.DELIVERY_ID
   AND WND.STATUS_CODE IN ('CL', 'IT')
   AND WDL.DELIVERY_ID = WND.DELIVERY_ID
   AND WTS.PENDING_INTERFACE_FLAG = 'Y'
   AND WDL.PICK_UP_STOP_ID = WTS.STOP_ID
   AND MP.ORGANIZATION_ID = WDD.ORGANIZATION_ID
   AND TRUNC(NVL(WTS.ACTUAL_DEPARTURE_DATE, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE

UNION

SELECT 'INCOMPLETE WORK ORDERS' "TYPE OF ISSUE",
       COUNT(*) "UNPROCESSED COUNT",
       GP.PERIOD_NAME,
       MP.ORGANIZATION_CODE
  FROM WIP_DISCRETE_JOBS   WDJ,
       WIP_ENTITIES        WE,
       APPS.MTL_PARAMETERS MP,
       APPS.GL_PERIODS     GP
 WHERE 
 1=1
   AND WDJ.STATUS_TYPE = 3
   AND WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
   AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
   AND WE.ENTITY_TYPE = 6
   AND MP.ORGANIZATION_ID = WE.ORGANIZATION_ID
   AND TRUNC(NVL(WDJ.DATE_COMPLETED, SYSDATE)) BETWEEN GP.START_DATE AND
       GP.END_DATE
   AND GP.ADJUSTMENT_PERIOD_FLAG = 'N'
 GROUP BY GP.PERIOD_NAME, MP.ORGANIZATION_CODE