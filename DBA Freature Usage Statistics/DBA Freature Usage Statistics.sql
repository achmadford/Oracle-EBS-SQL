/*************************************************************************/
/*                                                                       */
/*                       (c) 2010-2020 Enginatics GmbH                   */
/*                              www.enginatics.com                       */
/*                                                                       */
/*************************************************************************/
-- Report Name: DBA Freature Usage Statistics
-- Description: Database license feature usage statistics, such as the number of times that an AWR HTML report was run
-- Excel Examle Output: https://www.enginatics.com/example/dba-freature-usage-statistics/
-- Library Link: https://www.enginatics.com/reports/dba-freature-usage-statistics/
-- Run Report: https://demo.enginatics.com/

select
dfus.*
from
dba_feature_usage_statistics dfus
where
dfus.dbid in (select vd.dbid from v$database vd)
order by
dfus.name