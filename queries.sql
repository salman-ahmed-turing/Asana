
#type C Jobs
select j.id, job_id,j.company, CONCAT('https://matching.turing.com/job/',j.id) as matching_link,
j.created_date, j.role, j.customer_category, j.opportunity_status, js.status as matching_status,
j.max_acceptable_rate,j.public_description
from devdb_mirror.ms2_job j
LEFT JOIN devdb_mirror.ms2_job_status js on js.id = j.job_status_id
inner JOIN devdb_mirror.ms2_job_type jt
on j.id = jt.job_id and jt.job_type_catalog_id = 4
where j.is_deleted = 0

#Consultant assigned
with last_updated_row as
(SELECT DISTINCT
dch.developer_id as dev_id, 
max(dch.time_changed) over(partition by dch.developer_id) as career_consultant_assigned_at,
nth_value(users.full_name,1) over(partition by dch.developer_id order by dch.time_changed desc)  as assigned_career_consultant
FROM devdb_mirror.developer_changes_history dch
LEFT JOIN devdb_mirror.tpm_user users ON users.id = cast(dch.new_value as int64)
WHERE dch.time_changed > '2021-06-30' and dch.column = "careerConsultantId" AND users.user_name IN
( SELECT email FROM custom_dashboards.sourcers_data))
Select lur.*,
dd.status,
CONCAT('https://matching.turing.com/developer/',lur.dev_id) as matching_link
from last_updated_row lur
inner join devdb_mirror.developer_detail dd on dd.user_id=lur.dev_id