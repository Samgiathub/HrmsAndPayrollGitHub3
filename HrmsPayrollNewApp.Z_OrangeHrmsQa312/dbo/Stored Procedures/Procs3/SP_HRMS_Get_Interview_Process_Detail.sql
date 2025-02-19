
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_Get_Interview_Process_Detail]  
 @Cmp_ID  numeric(18,0) , 
 @rec_post_id numeric(18,0),  
 @Process_data varchar(100),
 @status Integer = 6,
 @order_by varchar(500)=''
 
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE  @Query  VARCHAR(6000)

	if @rec_post_id=0
		set @rec_post_id=null
	create table #data 
	(
		dis_no  int,
		next_dis_no  int,
		next_process  varchar(100),
		max_process  int,
		next_status  varchar(100),
		P_status int,
		process varchar(100),
		status  varchar(100),
		rec_post_code  varchar(100),
		job_title  varchar(100),
		App_full_name  varchar(100),
		resume_code  varchar(100),
		resume_id  numeric(18,0),
		Interview_Schedule_Id  numeric(18,0),
		Interview_Process_Detail_Id  numeric(18,0),
		rec_post_id  numeric(18,0),
		cmp_id   numeric(18,0),
		next_process_id numeric(18,0),
		bypass numeric (18,0)      --added by sneha on 5th july 2013 to bypass interview
		
	)
	
    declare @max as int
    declare @Process as varchar(50)
	select @max=max(dis_no),@Process=Process_name from v0055_Interview_Process_Detail group by Process_name,cmp_id,rec_post_id having cmp_id=@cmp_id and rec_post_id=isnull(@rec_post_id,rec_post_id)
	
     
     insert into #data (dis_no,max_process,P_status,process,status ,rec_post_code,job_title,App_full_name,resume_code,resume_id,Interview_Schedule_Id,Interview_Process_Detail_Id ,rec_post_id,cmp_id,bypass )
     Select is1.dis_no,@max,r.status,r.Process_name,case when r.status<>0 then 'Process ' + cast(is1.dis_no as varchar(10)) + ' (' + r.Process_name + ') Completed' else 'Process ' + cast(is1.dis_no as varchar(10)) + ' ('+ r.Process_name +') Incomplete' end as status,RM.rec_post_code,Rm.job_title,rm.App_full_name,rm.resume_code,rm.resume_id,r.Interview_Schedule_Id,r.Interview_Process_Detail_Id,is1.rec_post_id,@Cmp_ID,R.BypassInterview from   --r.cmp_id removed by sneha on 5th july to get cmpid--
	(SELECT rec_post_id,Resume_ID,Max(Dis_no) as Dis_no from v0055_HRMS_Interview_Schedule group by Resume_ID,rec_post_id,cmp_id having rec_post_id=isnull(@rec_post_id,rec_post_id) and cmp_id=@Cmp_ID) IS1 
	left outer join  v0055_resume_View RM on IS1.Resume_ID =RM.Resume_ID and IS1.rec_post_id=RM.rec_post_id
	left outer join  v0055_HRMS_Interview_Schedule R on IS1.Resume_ID =R.Resume_ID and IS1.rec_post_id =R.rec_post_id and IS1.Dis_no =R.Dis_no where isnull(rm.Resume_ID,0)<>0 and isnull(IS1.rec_post_id,0)<>0
	
	
  declare @dis_no as int
  declare @Interview_Schedule_Id as numeric(18,0)
  declare curP cursor for  
	select dis_no,Interview_Schedule_Id,Rec_post_id from #data 
  open curP  
  fetch next from curP into @dis_no,@Interview_Schedule_Id,@rec_post_id
  while @@Fetch_Status = 0  
	 begin  
	 
		update #data
		set next_dis_no = (select top 1 dis_no from v0055_interview_Process_detail where dis_no>@dis_no and rec_post_id=isnull(@rec_post_id,rec_post_id) and cmp_id=@cmp_id order by dis_no asc)
  		,next_process_id =(select top 1 Interview_Process_Detail_Id from v0055_interview_Process_detail where dis_no>@dis_no and rec_post_id=isnull(@rec_post_id,rec_post_id) and cmp_id=@cmp_id order by dis_no asc)
  		,next_process  =(select top 1 process_name from v0055_interview_Process_detail where dis_no>@dis_no and rec_post_id=isnull(@rec_post_id,rec_post_id) and cmp_id=@cmp_id order by dis_no asc)
  		,cmp_id=@Cmp_ID
  		where Interview_Schedule_Id=@Interview_Schedule_Id
  		  		
  		update #data
  		set next_status = case when P_status=1 and isnull(next_process,'')<>'' and ISNULL(bypass,0)=0 then 'Schedule for next (' + next_process + ') Process' when P_status=1 and isnull(next_process,'')<>'' and ISNULL(bypass,0)<>0 then 'All Interview Process Completed' when P_status=1 and isnull(next_process,'')='' then 'All Interview Process Completed' else '' end        --case2 added by sneha on 5 july 2013 to check whether bypass interview
  			,next_process = case when P_status=1 and isnull(next_process,'')<>'' then next_process else '' end 
  			,cmp_id=@Cmp_ID
  		where Interview_Schedule_Id=@Interview_Schedule_Id
  		
  		fetch next from curP into @dis_no,@Interview_Schedule_Id,@rec_post_id
	 end
  close curP  
  deallocate curP  
  --select @Process_data
	--if @Process_data <> '' 
	--    select *, isnull(Q.resume_status,0) as resume_status,case When isnull(RM.lock,0)=0 then 'No' else 'Yes' end as Lock_Status from @data QA
	--	left outer join T0060_RESUME_FINAL Q	on QA.resume_id=Q.resume_id
	--	left join T0055_Resume_Master RM on QA.resume_id = RM.Resume_Id
	--	where Process like + '%' + @Process_data + '%' or next_process like + '%' + @Process_data + '%' or Job_title like + '%' + @Process_data + '%' or rec_post_code like + '%' + @Process_data + '%'
	--	or app_full_name like + '%' + @Process_data + '%' or QA.resume_code like + '%' + @Process_data + '%' or status like + '%' + @Process_data + '%'
	--	order by rec_post_code,QA.resume_code asc 
	--else
	--    select *,isnull(Q.resume_status,0)as resume_status,case When isnull(RM.lock,0)=0 then 'No' else 'Yes' end as Lock_Status from @data QA
	--	left outer join T0060_RESUME_FINAL Q	on QA.resume_id=Q.resume_id 
	--	left join T0055_Resume_Master RM on QA.resume_id = RM.Resume_Id
	--	order by rec_post_code,QA.resume_code asc
		
		--SELECT 111, @status
		if @Process_data <> '' 
			set @Query = 'select *, isnull(Q.resume_status,0) as resume_status,case  when  Q.Resume_Status  in(2)  then isnull(Q.latterfile_Name,'''') else Q.latterfile_Name end as latterfile_Name1 from #data QA
			left outer join T0060_RESUME_FINAL Q	WITH (NOLOCK) on QA.resume_id=Q.resume_id
			left join T0055_Resume_Master RM WITH (NOLOCK) on QA.resume_id = RM.Resume_Id and QA.CMP_ID=RM.CMP_ID
			where (Process like + ''%' + @Process_data + '%'' or next_process like + ''%' + @Process_data + '%'' or Job_title like + ''%' + @Process_data + '%'' or
			rec_post_code like + ''%' + @Process_data + '%'' or app_full_name like + ''%' + @Process_data + '%'' or QA.resume_code like + ''%' + @Process_data + '%''
			or status like + ''%' + @Process_data + '%'') and isnull(Transfer_RecPostId,0)=0 and QA.Cmp_ID=' + cast(@Cmp_ID as varchar(5)) +''		
			
		else
			begin
				if @status = 1 or @status = 2 or @status = 0
					begin
						set @Query = 'select *,isnull(Q.resume_status,0)as resume_status,case  when  Q.Resume_Status  in(2)  then isnull(Q.latterfile_Name,'''') else Q.latterfile_Name end as latterfile_Name1 from #data QA
						left outer join T0060_RESUME_FINAL Q WITH (NOLOCK) on QA.resume_id=Q.resume_id 
						left join T0055_Resume_Master RM WITH (NOLOCK) on QA.resume_id = RM.Resume_Id and QA.CMP_ID=RM.CMP_ID
						where isnull(Transfer_RecPostId,0)=0 and QA.Cmp_ID=' + cast(@Cmp_ID as varchar(5)) +' and Q.acceptance = ' + cast(@status as varchar(5)) 
					end
				Else if @status = 4 
					Begin						
						set @Query = 'select *,isnull(Q.resume_status,0)as resume_status,case  when  Q.Resume_Status  in(2)  then isnull(Q.latterfile_Name,'''') else Q.latterfile_Name end as latterfile_Name1   from #data QA
						left outer join T0060_RESUME_FINAL Q WITH (NOLOCK) on QA.resume_id=Q.resume_id 
						left join T0055_Resume_Master RM WITH (NOLOCK) on QA.resume_id = RM.Resume_Id 
						where RM.resume_status = 2 and QA.Cmp_ID=' + cast(@Cmp_ID as varchar(5)) +' and isnull(Transfer_RecPostId,0)=0'
					End
				Else if  @status = 5
					Begin						
						set @Query = 'select *,isnull(Q.resume_status,0)as resume_status ,case  when  Q.Resume_Status  in(2)  then isnull(Q.latterfile_Name,'''') else Q.latterfile_Name end as latterfile_Name1   from #data QA
						left outer join T0060_RESUME_FINAL Q WITH (NOLOCK) on QA.resume_id=Q.resume_id 
						left join T0055_Resume_Master RM WITH (NOLOCK) on QA.resume_id = RM.Resume_Id 
						where RM.resume_status = 3 and QA.Cmp_ID=' + cast(@Cmp_ID as varchar(5)) +' and isnull(Transfer_RecPostId,0)=0'
					End
				else
					begin
						set @Query = 'select *,isnull(Q.resume_status,0)as resume_status,case  when  Q.Resume_Status  in(2)  then isnull(Q.latterfile_Name,'''') else Q.latterfile_Name end as latterfile_Name1      from #data QA
						left outer join T0060_RESUME_FINAL Q WITH (NOLOCK) on QA.resume_id=Q.resume_id  
						left join T0055_Resume_Master RM WITH (NOLOCK) on QA.resume_id = RM.Resume_Id 
						WHERE QA.Cmp_ID=' + cast(@Cmp_ID as varchar(5)) +' and isnull(Transfer_RecPostId,0)=0'
					end
			  End
			  
			  print @Query
		EXEC(@Query + @order_by)   --added By Mukti 2182014
		
 RETURN  
  
  


