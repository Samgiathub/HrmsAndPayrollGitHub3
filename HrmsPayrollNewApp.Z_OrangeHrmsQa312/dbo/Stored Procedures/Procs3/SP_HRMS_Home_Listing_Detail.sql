




CREATE PROCEDURE [DBO].[SP_HRMS_Home_Listing_Detail]   
   @Cmp_ID numeric(18,0),  
   @Branch_ID numeric(18,0)
   
AS  
	if @Branch_ID=0
	set @Branch_ID=null
	
	declare @for_date as datetime
	set @for_date=cast(getdate() as varchar(11))
	declare @data table
		(
			rec_post_id numeric(18,0)
			,job_title varchar(100)
			,job_code varchar(50)
		)
	
	SELECT  top 1 rec_post_code,job_title,rec_end_date,total_resume,rec_post_id from V0052_HRMS_Recruitment_Posted  where rec_end_date >=@for_date and cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id)order by newid()
	
	insert into @data(rec_post_id)
	SELECT distinct rec_post_id from v0055_HRMS_Interview_Schedule group by status,prcoess_name,rec_post_id having rec_post_id in(SELECT  rec_post_id from V0052_HRMS_Recruitment_Posted  where dateadd(dd,10,rec_end_date)>=@for_date and cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id))--order by newid())
	 
	 update @data
	 set job_title =LT.job_title
		,job_code =LT.Rec_post_code
	 from @data AM 
	 left outer join V0052_HRMS_Recruitment_Posted LT
	 ON AM.rec_post_id = LT.rec_post_id
	 where dateadd(dd,10,lt.rec_end_date)>=@for_date and lt.cmp_id=@cmp_id
		
	declare @rec_post_id1 as numeric(18,0)	
	select top 1 @rec_post_id1=rec_post_id from @data  order by newid()
	select top 1 * from @data  where rec_post_id=@rec_post_id1
	SELECT distinct cmp_id,rec_post_id,count(resume_id) as total_count,prcoess_name,status from v0055_HRMS_Interview_Schedule group by cmp_id,status,prcoess_name,rec_post_id having rec_post_id=@rec_post_id1
	
	
	RETURN  
  



