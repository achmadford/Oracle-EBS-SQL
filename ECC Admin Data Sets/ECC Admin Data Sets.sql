/*************************************************************************/
/*                                                                       */
/*                       (c) 2010-2020 Enginatics GmbH                   */
/*                              www.enginatics.com                       */
/*                                                                       */
/*************************************************************************/
-- Report Name: ECC Admin - Data Sets
-- Description: Enterprise Command Centers applications with data sets and load rule DB procedure names for incremental, full and metadata load.
For description of the load process, see ECC Concurrent Programs https://www.enginatics.com/reports/ecc-concurrent-programs/
-- Excel Examle Output: https://www.enginatics.com/example/ecc-admin-data-sets/
-- Library Link: https://www.enginatics.com/reports/ecc-admin-data-sets/
-- Run Report: https://demo.enginatics.com/

select
ess.system_name,
(
select distinct
listagg(eat.application_name,', ') within group (order by eat.application_name) over (partition by eadr.dataset_id) application 
from
ecc.ecc_app_ds_relationships eadr,
ecc.ecc_application_tl eat
where
edb.dataset_id=eadr.dataset_id and
eadr.application_id=eat.application_id and
eat.language='en'
) application,
edb.dataset_key data_set_key,
edt.display_name data_set,
decode(edt.dataset_description,'null',null,edt.dataset_description) description,
xxen_util.meaning(decode(edb.enabled_flag,'Y','Y'),'YES_NO',0) enabled,
x.*
from
ecc.ecc_source_system ess,
ecc.ecc_dataset_b edb,
ecc.ecc_dataset_tl edt,
(
select
edlr.dataset_id,
xxen_util.meaning(edlr.load_type,'ECC_LOAD_TYPE_LKUP',0) load_type,
edlr.package_name||nvl2(edlr.procedure_name,'.'||edlr.procedure_name,null) procedure_name
from
ecc.ecc_dataset_load_rules edlr
)
pivot (
max(procedure_name) proc
for
load_type in (
'Incremental data load' incremental_load,
'Full data load' full_load,
'Metadata load' metadata_load
)
) x
where
1=1 and
ess.system_id=edb.system_id and
edb.dataset_id=edt.dataset_id and
edt.language='en' and
edt.dataset_id=x.dataset_id(+)
order by
ess.system_name,
edb.dataset_key