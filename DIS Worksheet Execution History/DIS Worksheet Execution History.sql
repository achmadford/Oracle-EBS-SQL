/*************************************************************************/
/*                                                                       */
/*                       (c) 2010-2020 Enginatics GmbH                   */
/*                              www.enginatics.com                       */
/*                                                                       */
/*************************************************************************/
-- Report Name: DIS Worksheet Execution History
-- Description: Discoverer worksheet access statistics from table eul5_qpp_stats, including folder objects used.
Parameter 'Show Folder Details' switches between aggregate and list view of used folder objects.
-- Excel Examle Output: https://www.enginatics.com/example/dis-worksheet-execution-history/
-- Library Link: https://www.enginatics.com/reports/dis-worksheet-execution-history/
-- Run Report: https://demo.enginatics.com/

select distinct
eqs.qs_id id,
xxen_util.dis_user_name(eqs.qs_created_by) user_name,
eqs.qs_doc_name workbook,
ed.doc_developer_key workbook_identifier,
eqs.qs_doc_details sheet,
xxen_util.client_time(eqs.qs_created_date) start_date,
xxen_util.time(eqs.seconds) time,
eqs.seconds,
eqs.qs_num_rows row_count,
&object_columns
length(eqs.qs_object_use_key)-length(translate(eqs.qs_object_use_key,'x.','x'))+1 folder_count,
xxen_util.meaning(case when eqs.qs_object_use_key like '%.%' then 'Y' end,'YES_NO',0) multiple_flag,
eqs.qs_object_use_key use_key
from
(
select
trim(regexp_substr(eqs.qs_object_use_key,'[^\.]+',1,rowgen.column_value)) obj_id,
greatest(nvl(eqs.qs_act_cpu_time,0),nvl(eqs.qs_act_elap_time,0)) seconds,
eqs.*
from
&eul.eul5_qpp_stats eqs,
table(xxen_util.rowgen(regexp_count(eqs.qs_object_use_key,'\.')+1)) rowgen
where
1=1
) eqs,
&eul.eul5_objs eo,
(
select
ed.doc_name,
fu.user_name,
ed.doc_developer_key
from
&eul.eul5_documents ed,
&eul.eul5_eul_users eeu,
fnd_user fu
where
ed.doc_eu_id=eeu.eu_id and
case when eeu.eu_username like '#%' and eeu.eu_username not like '#%#%' then to_number(substr(eeu.eu_username,2)) end=fu.user_id
) ed
where
2=2 and
translate(eqs.obj_id,'x0123456789','x') is null and
eqs.obj_id=eo.obj_id(+) and
eqs.qs_doc_name=ed.doc_name(+) and
eqs.qs_doc_owner=ed.user_name(+)
order by
eqs.qs_id desc