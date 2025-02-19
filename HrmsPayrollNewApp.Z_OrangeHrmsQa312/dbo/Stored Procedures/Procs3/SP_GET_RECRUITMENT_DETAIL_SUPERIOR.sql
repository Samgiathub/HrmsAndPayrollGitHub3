




--zalak 05122011 for resume search base on all craiteria of admin passing


--ALTER PROCEDURE [dbo].[SP_GET_RECRUITMENT_DETAIL_SUPERIOR]  
--   @Cmp_ID  Numeric (18,0) 
--  ,@emp_id   Numeric (18,0)
--  ,@search_name  varchar(50)
--AS  
   
-- set nocount on  
-- 		declare @for_date as datetime
--		set @for_date=cast(getdate() as varchar(11))
		
-- if @search_name = ''
   
--		Select  case when IP.s_emp_id =@emp_id then 'Superior' else 'Member' end emp_role,case when isnull(Q.total_p_resume,0)>0 then Q.total_p_resume else M.total_resume end total_resume,case when dateadd(dd,5,IP.to_date)>@for_date then 1 else 0 end as status ,IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,Process_Name,Job_title,rec_post_code,case when isnull(from_p_date,'') <> '' and from_p_date>from_date then from_p_date else from_date end as from_date,case when isnull(to_p_date,'')<>'' and to_p_date>to_date then to_p_date else to_date end to_date,from_time,to_time  from V0055_HRMS_Interview_Schedule IP
--		left outer join  (select count(*)as total_P_resume,min(from_date) as from_p_date,max(to_date) as to_p_date,Interview_Process_detail_ID,rec_post_id from t0055_HRMS_Interview_Schedule where (s_emp_id=@emp_id or s_emp_id2=@emp_id or s_emp_id3=@emp_id or s_emp_id4=@emp_id)  group by Interview_Process_detail_ID,rec_post_id) Q 
--		on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID 
--		left outer join  (select count(*)as total_resume,rec_post_id from t0055_resume_master group by rec_post_id)M on m.rec_post_id=IP.rec_post_id
--		where IP.cmp_id=@cmp_id and (IP.s_emp_id =@emp_id or IP.s_emp_id2 = @emp_id or IP.s_emp_id3 = @emp_id or IP.s_emp_id4 = @emp_id) 
		
--	else
		
--		Select  case when IP.s_emp_id =@emp_id then 'Superior' else 'Member' end emp_role,case when isnull(Q.total_p_resume,0)>0 then Q.total_p_resume else M.total_resume end total_resume,case when dateadd(dd,5,IP.to_date)>@for_date then 1 else 0 end as status ,IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,Process_Name,Job_title,rec_post_code,case when isnull(from_p_date,'') <> '' and from_p_date>from_date then from_p_date else from_date end as from_date,case when isnull(to_p_date,'')<>'' and to_p_date>to_date then to_p_date else to_date end to_date,from_time,to_time  from V0055_HRMS_Interview_Schedule IP
--		left outer join  (select count(*)as total_P_resume,min(from_date) as from_p_date,max(to_date) as to_p_date,Interview_Process_detail_ID,rec_post_id from t0055_HRMS_Interview_Schedule where (s_emp_id=@emp_id or s_emp_id2=@emp_id or s_emp_id3=@emp_id or s_emp_id4=@emp_id)  group by Interview_Process_detail_ID,rec_post_id) Q 
--		on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID 
--		left outer join  (select count(*)as total_resume,rec_post_id from t0055_resume_master group by rec_post_id)M on m.rec_post_id=IP.rec_post_id
--		where IP.cmp_id=@cmp_id and (IP.s_emp_id =@emp_id or IP.s_emp_id2 = @emp_id or IP.s_emp_id3 = @emp_id or IP.s_emp_id4 = @emp_id) and (ip.job_title like '%' + @search_name + '%' or ip.rec_post_code like '%' + @search_name + '%' or ip.Process_name  like '%' + @search_name + '%')
		
--		--v0055_Interview_Process_Detail
--	 RETURN   
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RECRUITMENT_DETAIL_SUPERIOR]  
   @Cmp_ID  Numeric (18,0) 
  ,@emp_id   Numeric (18,0)
  ,@search_name  varchar(50)=''
 -- ,@order_by varchar(500)='' 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
 
 	DECLARE  @Query  VARCHAR(6000)
	declare @for_date as datetime

	set @for_date=cast(getdate() as varchar(11))
	

	create table #Total_Resume 
	(  
	  rec_post_id numeric , 
	  Interview_Process_detail_ID numeric,
	  total_P_resume numeric,
	  from_p_date date,
	  to_p_date date
	)  
 
  Insert Into #Total_Resume(rec_post_id,Interview_Process_detail_ID,total_P_resume,from_p_date,to_p_date) 
 (select distinct rec_post_id,Interview_Process_detail_ID,count(*)as total_P_resume,min(from_date) as from_p_date,max(to_date) as to_p_date
  from t0055_HRMS_Interview_Schedule WITH (NOLOCK)
  where  Interview_Process_Detail_Id is not null and (s_emp_id=@emp_id or s_emp_id2=@emp_id or s_emp_id3=@emp_id or s_emp_id4=@emp_id)
  group by Interview_Process_detail_ID,rec_post_id,From_Date)
  
  --select * from #Total_Resume
 IF @search_name = ''
		BEGIN
	--	select * from #Total_Resume
			set @Query = 'Select distinct  case when IP.s_emp_id =' + cast(@emp_id as varchar(10)) +' then ''Superior'' else ''Member'' end emp_role,case when isnull(Q.total_p_resume,0)>0 then Q.total_p_resume
			else M.total_resume end total_resume,
			case when dateadd(dd,5,IP.to_date)> getdate() then 1 else 0 end as status ,IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,Process_Name,Job_title,
			rec_post_code,case when isnull(Q.from_p_date,'''') <> '''' and from_p_date>from_date then from_p_date else from_date end as from_date,case when isnull(to_p_date,'''')<>''''
			and to_p_date>to_date then to_p_date else to_date end to_date,from_time,to_time  from V0055_HRMS_Interview_Schedule IP
			inner join #Total_Resume as Q on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID  and q.from_p_date=ip.From_Date and q.to_p_date=ip.To_Date
			inner join  (select count(*)as total_resume,rec_post_id from t0055_resume_master group by rec_post_id) as M on m.rec_post_id=IP.rec_post_id
			where IP.cmp_id=' + cast(@cmp_id as varchar(10))+'  and (IP.s_emp_id =' + cast(@emp_id as varchar(10)) +' or IP.s_emp_id2 = ' + cast(@emp_id as varchar(10)) +'
			or IP.s_emp_id3 = ' + cast(@emp_id as varchar(10)) +' or IP.s_emp_id4 = ' + cast(@emp_id as varchar(10)) + ')'
		END
	ELSE
		BEGIN

			set @Query = 'Select distinct  case when IP.s_emp_id =' + cast(@emp_id as varchar(10)) +' then ''Superior'' else ''Member'' end emp_role,case when isnull(Q.total_p_resume,0)>0 then Q.total_p_resume
			else M.total_resume end total_resume,
			case when dateadd(dd,5,IP.to_date)> getdate() then 1 else 0 end as status ,IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,Process_Name,Job_title,
			rec_post_code,case when isnull(Q.from_p_date,'''') <> '''' and from_p_date>from_date then from_p_date else from_date end as from_date,case when isnull(to_p_date,'''')<>''''
			and to_p_date>to_date then to_p_date else to_date end to_date,from_time,to_time  from V0055_HRMS_Interview_Schedule IP
			inner join #Total_Resume as Q on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID  and q.from_p_date=ip.From_Date and q.to_p_date=ip.To_Date
			inner join  (select count(*)as total_resume,rec_post_id from t0055_resume_master group by rec_post_id) as M on m.rec_post_id=IP.rec_post_id
			where IP.cmp_id=' + cast(@cmp_id as varchar(10))+' and (ip.job_title like ''%' + @search_name + '%'' or ip.rec_post_code like ''%' + @search_name + '%'' 
			or ip.Process_name  like ''%' + @search_name + '%'') and 
			(IP.s_emp_id =' + cast(@emp_id as varchar(10)) +' or IP.s_emp_id2 = ' + cast(@emp_id as varchar(10)) +'
			or IP.s_emp_id3 = ' + cast(@emp_id as varchar(10)) +' or IP.s_emp_id4 = ' + cast(@emp_id as varchar(10)) + '' +')'
		END
		
	EXEC(@Query) 
	 
	  --print @Query
	  --print @order_by
drop table #Total_Resume
	--end  
  
  


