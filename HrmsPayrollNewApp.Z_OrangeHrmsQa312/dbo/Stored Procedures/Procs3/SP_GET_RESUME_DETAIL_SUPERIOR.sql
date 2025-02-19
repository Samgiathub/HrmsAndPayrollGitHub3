

-- exec [SP_GET_RESUME_DETAIL_SUPERIOR] 9,14,16,4,2035


--zalak 22122010 for resume search base on all craiteria of admin passing
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RESUME_DETAIL_SUPERIOR]  
   @Cmp_ID  Numeric (18,0) 
   ,@rec_post_id Numeric (18,0) 
   ,@Interview_Process_detail_ID Numeric (18,0) 
   ,@status  int  
   ,@emp_id   Numeric (18,0) 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

 if @status=4
  set @status = null
  
  --if @status=0
  --set @status = 1
 --if @status=4
 -- set @status = 4
  
   
   
 
 declare @Resume_MAster table
 (
	resume_id numeric(18,0)
 )   
 
 declare @skill table
 (
	resume_id numeric(18,0)
	,SKill_detail varchar(500)
 ) 
 declare @QUALIFICATION table
 (
	resume_id numeric(18,0)
	,Qual_Name varchar(100)
	,Specialization varchar(100)
	,education_detail varchar(500)
 ) 
  declare @skill_d table
 (
	resume_id numeric(18,0)
	) 
 declare @key table
 (
	kew_detail varchar(50)
 ) 
 declare @location_data table
 (
	location_detail varchar(50)
 ) 
 
	declare @Resume_ID as numeric(18,0)
	declare @Education_detail as varchar(500)
	declare @SKill_name as varchar(500)
	
	declare @total as numeric(18,0)
	select @total=count(*) from t0055_HRMS_Interview_Schedule WITH (NOLOCK) where Interview_Process_detail_ID=@Interview_Process_detail_ID and status=isnull(@status,status) and (isnull(s_emp_id,0)=@emp_id or isnull(s_emp_id2,0)=@emp_id or isnull(s_emp_id3,0)=@emp_id or isnull(s_emp_id4,0)=@emp_id)
	if @total> 0
		insert into @Resume_MAster(Resume_ID)
		select Resume_id from t0055_HRMS_Interview_Schedule WITH (NOLOCK) where Interview_Process_detail_ID=@Interview_Process_detail_ID and status=isnull(@status,status) and (isnull(s_emp_id,0)=@emp_id or isnull(s_emp_id2,0)=@emp_id or isnull(s_emp_id3,0)=@emp_id or isnull(s_emp_id4,0)=@emp_id) order by resume_id asc   --isnull(@status,status)
	else
		insert into @Resume_MAster(Resume_ID)
		select Resume_ID from t0055_resume_master WITH (NOLOCK) where cmp_id=@cmp_id and rec_post_id=@rec_post_id order by resume_code asc
		
	Declare curUser cursor Local for 
	select skill_name,Resume_ID from v0090_HRMS_RESUME_SKILL where resume_id in (select resume_id from @Resume_MAster)
	open curUser
	Fetch next from curUser Into @SKill_name,@Resume_ID
	   while @@Fetch_Status = 0
				begin
					if exists (select resume_id from @skill where resume_id=@Resume_ID)
						update @skill set SKill_detail = SKill_detail + ' , ' +@SKill_name where resume_id=@Resume_ID  
						else
						insert into @skill(resume_id,SKill_detail)values(@Resume_ID,@SKill_name)
						Fetch next from curUser Into @SKill_name,@Resume_ID
					 end
		Close curUser
	declare @Qual_Name varchar(50)
	declare @Specialization  varchar(50)
	Declare curUser1 cursor Local for 
	select Qual_Name,Specialization ,Resume_ID  from V0090_HRMS_RESUME_EDU where resume_id in (select resume_id from @Resume_MAster)
	open curUser1
	Fetch next from curUser1 Into @Qual_Name,@Specialization,@Resume_ID
	   while @@Fetch_Status = 0
				begin
					set @Education_detail = @Qual_Name + '-' + @Specialization
					if exists (select resume_id from @QUALIFICATION where resume_id=@Resume_ID)
						update @QUALIFICATION set Qual_Name = @Qual_Name
								,Specialization=@Specialization
								,education_detail = education_detail + ' / ' + @Education_detail
						 where resume_id=@Resume_ID  
					else
						insert into @QUALIFICATION(resume_id,Qual_Name,Specialization)values(@Resume_ID,@Qual_Name,@Specialization)
					Fetch next from curUser1 Into @Qual_Name,@Specialization,@Resume_ID
				End
			Close curUser1	
	

		select isnull(SK.SKill_detail,'#') as SKill_detail,isnull(ETM.Education_detail,'#')as Education_detail,isnull(PS.Rec_Post_Code,'#') as job_code,Q.Resume_ID,Q.Rec_post_ID,Ps.job_title,q.Resume_Posted_date as posted_date,q.emp_first_name + ' ' + isnull(q.emp_last_name,'') as App_Full_name,datediff(yy,Date_Of_Birth,getdate()) as age,isnull(mobile_no,'#') as mobile_no,case when gender='M' then 'Male' else 'Female' end as gender,isnull(Primary_email,'#') as Primary_email,Total_Exp as Experiance_detail,case when isnull(Present_City,'') + '>' + isnull(Present_State,'')='>' then '#' else isnull(Present_City,'') + ' > ' + isnull(Present_State,'') end as Location,case when isnull(Resume_name,'#')='' then 'not define' else isnull(Resume_name,'#') end as Resume_name, case when Resume_status=0 then 'Pending' when Resume_status=1 then 'Approved' when Resume_status=2 then 'Rejected' else 'Hold' end as status,
		Resume_status,file_name,isnull(Resume_code,'R' +  cast(Q.cmp_id as varchar(50)) + ':' + cast(10000 + Q.resume_id as varchar(50))) as  Resume_code  
		from t0055_resume_master Q WITH (NOLOCK) inner join
		T0052_HRMS_Posted_Recruitment PS WITH (NOLOCK) on Ps.Rec_Post_Id=Q.Rec_Post_Id LEFT OUTER JOIN      
		(select * from @skill)SK ON SK.Resume_ID=Q.Resume_ID LEFT OUTER JOIN      
		(select * from @QUALIFICATION) ETM ON ETM.Resume_ID=Q.Resume_ID 
		where Q.cmp_id=@cmp_id and Q.resume_id in (select resume_id from @Resume_MAster) and Resume_status<>0
		and Resume_Status= isnull(@status,Resume_Status)--resume status condition added by sneha on 12 sep 2013 to search by condition
		order by q.Resume_Posted_date desc
		
		select Process_name, job_title, from_date, to_date, from_time, to_time, process_id from v0055_Interview_Process_Detail where rec_post_id=@rec_post_id and interview_process_detail_id=@Interview_Process_detail_ID and cmp_id =@cmp_id 
	
	 RETURN   
  
  
  

