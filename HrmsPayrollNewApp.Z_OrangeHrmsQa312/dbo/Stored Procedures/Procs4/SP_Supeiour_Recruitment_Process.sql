




CREATE PROCEDURE [dbo].[SP_Supeiour_Recruitment_Process]
		@cmp_id		numeric(18,0) 
	, @emp_id	numeric(18,0)
	
	
AS
	 SET NOCOUNT ON 
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	 SET ARITHABORT ON 
	 
		--select  from v0055_Interview_Process_Detail
		
		select Q.job_title,q.Process_Name,q.rec_post_id,q.Interview_Process_detail_ID,q.Process_ID,isnull(Qry.from_date,Q.from_date)as from_date,isnull(Qry.to_date,Q.to_date) as to_date,isnull(Qry.from_time,Q.from_time) as from_time,isnull(Qry.to_time,Q.to_time) as to_time,isnull(Qry.resume_count,Qy.total) as resume_count,isnull(Qry.member1,Q.member1)as member1,isnull(Qry.member2,Q.member2) as member2,isnull(Qry.member3,Q.member3) as member3,isnull(Qry.emp_full_name_new,Q.emp_full_name_new) as Superior,case when isnull(datediff(dd,isnull(Qry.to_date,Q.to_date),getdate()),0)>2 then 1 else 0 end as status from v0055_Interview_Process_Detail Q
		left outer join
		(select distinct interview_process_detail_id,from_date,to_date,from_time,to_time,member1,member2,member3,emp_full_name_new,count(interview_process_detail_id) as resume_count from V0055_HRMS_Interview_Schedule where cmp_id=@cmp_id and (s_emp_id=@emp_id or s_emp_id2=@emp_id  or s_emp_id3=@emp_id  or s_emp_id4=@emp_id)group by interview_process_detail_id,from_date,to_date,from_time,to_time,member1,member2,member3,emp_full_name_new) Qry
		on qry.interview_process_detail_id=Q.interview_process_detail_id
		inner join
		(select count(*) as total,rec_post_id from t0055_resume_master WITH (NOLOCK) group by rec_post_id)QY on QY.rec_post_id=q.rec_post_id
		
		where Q.cmp_id=@cmp_id and (Q.s_emp_id=@emp_id or Q.s_emp_id2=@emp_id  or Q.s_emp_id3=@emp_id  or Q.s_emp_id4=@emp_id)
	
	
	 
	RETURN




