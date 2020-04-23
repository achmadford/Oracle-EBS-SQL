/*************************************************************************/
/*                                                                       */
/*                       (c) 2010-2020 Enginatics GmbH                   */
/*                              www.enginatics.com                       */
/*                                                                       */
/*************************************************************************/
-- Report Name: OKC Contract Lines Summary
-- Description: Summary of okc line style hierarchies, the jtf objects linked to each line level and the active and overall count of contract lines by status for each line type.
This is useful for developers to see how the oracle contracts line data is structured and how the link to external objects, e.g. installed base or counters for service contracts works
-- Excel Examle Output: https://www.enginatics.com/example/okc-contract-lines-summary
-- Library Link: https://www.enginatics.com/reports/okc-contract-lines-summary
-- Run Report: https://demo.enginatics.com/


select
ocv.meaning class,
osv.meaning category,
osv.code category_code,
lpad(' ',2*(olsv.level_-1))||olsv.level_ level_,
lpad(' ',2*(olsv.level_-1))||olsv.lty_code lty_code,
oklb.usage_type,
xxen_util.meaning(oklb.usage_type,'OKS_USAGE_TYPES',0) description,
lpad(' ',2*(olsv.level_-1))||olsv.id lse_id,
oklb.jtot_object1_code,
jov.name object_name,
jov.from_table,
jov.where_clause,
olsv.path,
oklb.active,
oklb.total,
&status_columns
from
(
select
level level_,
olsv.name,
olsv.lty_code,
olsv.id,
sys_connect_by_path (olsv.id,'->') path,
connect_by_root olsv.id root_id
from
okc_line_styles_v olsv
connect by
prior olsv.id=olsv.lse_parent_id
start with
olsv.lse_parent_id is null
) olsv,
okc_subclass_top_line ostl,
okc_subclasses_v osv,
okc_classes_v ocv,
(select olss.* from okc_line_style_sources olss where sysdate between olss.start_date and nvl(olss.end_date,sysdate)) olss,
jtf_objects_vl jov,
(
select distinct
okhab.scs_code,
oklb.lse_id,
okslb.usage_type,
oki.jtot_object1_code,
count(case when sysdate between nvl(oklb.start_date,sysdate) and nvl(oklb.end_date,sysdate) then 1 end) over (partition by okhab.scs_code, oklb.lse_id, okslb.usage_type, oki.jtot_object1_code) active,
count(*) over (partition by okhab.scs_code, oklb.lse_id, okslb.usage_type, oki.jtot_object1_code) total
from
okc_k_lines_b oklb,
oks_k_lines_b okslb,
okc_k_items oki,
okc_k_headers_all_b okhab
where
oklb.id=okslb.cle_id(+) and
oklb.id=oki.cle_id(+) and
oklb.dnz_chr_id=okhab.id
) oklb,
(
select
y.*
from
(
select
count(*) count,
oklb.lse_id,
okslb.usage_type,
osv.meaning
from
okc_k_lines_b oklb,
okc_statuses_b osb,
okc_statuses_v osv,
oks_k_lines_b okslb
where
oklb.sts_code=osb.code and
osb.ste_code=osv.code and
oklb.id=okslb.cle_id(+)
group by
oklb.lse_id,
osv.meaning,
okslb.usage_type
order by
count(*) desc
) x
pivot (
sum(x.count)
for meaning in (
&status_pivot
)
) y
) z
where
olsv.root_id=ostl.lse_id(+) and
ostl.scs_code=osv.code(+) and
osv.cls_code=ocv.code(+) and
olsv.id=olss.lse_id(+) and
ostl.scs_code=oklb.scs_code and
olsv.id=oklb.lse_id and
oklb.jtot_object1_code=jov.object_code(+) and
oklb.lse_id=z.lse_id(+) and
oklb.usage_type=z.usage_type(+)
order by
osv.code,
olsv.path