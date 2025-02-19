



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_Get_App_Summary]  
   
 @Cmp_ID  numeric(18,0)  
 ,@rec_id numeric(18,0)  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
  
------------------------------------------------------------------------------------------------------------------  
------------------------------------ Created By : Falak on 08-07-2010 --------------------------------------------  
------------------------------------------------------------------------------------------------------------------  
   
    
    declare @Resume table  
    (  
       Resume_ID numeric(18,0),  
       Status    numeric(18,0),  
       Rec_Post_ID  numeric(18,0),  
       Process_dis_no numeric(18,0),  
       Schedule   varchar(50),  
       Schedule_Prev varchar(50),      
       comments varchar(1000),    
       Cmp_ID numeric(18,0)  
       
      
    )  
      
    declare @Resume_Id as numeric(18,0)  
    declare @P_dis_no as numeric(18,0)  
    declare @max_dis_no as numeric(18,0)  
    declare @rec_post_id as numeric(18,0)  
    declare @stat as numeric(18,0)  
    declare @rate as numeric(18,0)  
      
      
    insert into @Resume(Resume_ID,Status,Rec_Post_ID,Process_dis_no,Schedule,Schedule_Prev,Comments,Cmp_ID)  
        
    Select IS1.resume_Id,FS.status,RM.rec_post_Id,is1.process_dis_no,'','',isnull(FS.Notes,''),RM.Cmp_ID  from   
     
    (SELECT Resume_ID,Max(Process_dis_No) as Process_dis_no  
  
    from T0055_HRMS_Interview_Schedule WITH (NOLOCK) group by Resume_ID) IS1 Inner join  
    T0055_Resume_Master  RM WITH (NOLOCK) on IS1.Resume_ID =RM.Resume_ID   
    Left outer join T0090_HRMS_Recruitment_final_Score FS  WITH (NOLOCK)
    on IS1.Resume_ID =FS.REsume_ID where rm.cmp_id = @cmp_id  
      
  declare curP cursor for  
   select resume_id,process_dis_no,rec_post_id from @resume  
    
  open curP  
  fetch next from curP into @Resume_Id,@P_dis_no,@rec_post_id  
  while @@Fetch_Status = 0  
  begin  
     
   select @max_dis_no = max(dis_no) from T0055_interview_process_detail WITH (NOLOCK) where rec_post_Id = @rec_post_id  
     
   if @p_dis_no = @max_dis_no  
   begin  
    update @resume set schedule = 'Completed',  
         schedule_prev = 'process ' + cast(@p_dis_no as varchar) + ' completed'  
      where resume_id = @resume_id  
   end  
   else  
   begin  
    select @stat = status,@rate = rating from T0055_hrms_interview_schedule WITH (NOLOCK) where resume_id = @resume_id and   
           process_dis_no = @p_dis_no  
      
    if  @stat = 0 or @rate is null  
    begin  
     update @resume set schedule = 'Not Completed',  
         schedule_prev = 'process ' + cast(@p_dis_no as varchar) + ' incompleted'  
      where resume_id = @resume_id  
    end  
    else  
    begin  
     update @resume set schedule = 'Scheduled for next process',  
          schedule_prev = 'process ' + cast(@p_dis_no as varchar) + ' completed'  
       where resume_id = @resume_id  
    end  
   end  
     
    update @resume set schedule = 'All Process completed',  
         schedule_prev = 'Waiting final for Approval' where status is null and   
         schedule = 'Completed'  
     
   fetch next from curP into @resume_id,@p_dis_no,@rec_post_id  
  end    
    
  close curP  
  deallocate curP  
  
 if @rec_id <> 0  
 begin  
   
  select Re.*,Rm.App_full_name,Rm.Job_title, 
  --Case added on 06-aug-2010 by falak
  case Re.Status
  when 0 then 'Pending'
  when 1 then 'Approve'
  when 2 then 'Hold'
  when 3 then 'Reject'
  end as App_Status
  from @resume as Re inner join   
   V0055_resume_view as Rm on Re.resume_Id = Rm.resume_id where re.rec_post_id = @rec_id order by re.rec_post_id  
   
 -- falak 15-JUL-2010  
  select re.cmp_id,re.resume_id,rs.rating,pd.process_id,pd.dis_no,gs.actual_rate,pm.process_name   
   ,isnull(rs.comments,'') as comments from  
   T0055_hrms_interview_schedule as rs WITH (NOLOCK) inner join  
   T0055_resume_master as re WITH (NOLOCK) on rs.resume_id = re.resume_id inner join  
   T0055_interview_process_detail as pd WITH (NOLOCK)  
   on rs.interview_Process_detail_id = pd.interview_process_detail_id  
   left outer join T0040_hrms_general_setting as gs WITH (NOLOCK)  
   on gs.rec_post_id = pd.rec_post_id and gs.process_id = pd.process_id  
   inner join T0040_hrms_R_Process_MAster as pm WITH (NOLOCK) on  
   pm.process_id = pd.process_id  
   where re.rec_post_id = @rec_id and re.cmp_id = @cmp_id order by re.rec_post_id  
 end  
 else  
 begin  
  select Re.*,Rm.App_full_name,Rm.Job_title,
--Case added on 06-aug-2010 by falak
  case Re.Status
  when 0 then 'Pending'
  when 1 then 'Approve'
  when 2 then 'Hold'
  when 3 then 'Reject'
  end as App_Status
  from @resume as Re inner join   
   V0055_resume_view as Rm on Re.resume_Id = Rm.resume_id order by re.rec_post_id  
   
 -- falak 15-JUL-2010  
  select re.cmp_id,re.resume_id,rs.rating,pd.process_id,pd.dis_no,gs.actual_rate,pm.process_name   
   ,isnull(rs.comments,'') as comments from  
   T0055_hrms_interview_schedule as rs WITH (NOLOCK) inner join  
   T0055_resume_master as re WITH (NOLOCK) on rs.resume_id = re.resume_id inner join  
   T0055_interview_process_detail as pd  WITH (NOLOCK)
   on rs.interview_Process_detail_id = pd.interview_process_detail_id  
   left outer join T0040_hrms_general_setting as gs WITH (NOLOCK)  
   on gs.rec_post_id = pd.rec_post_id and gs.process_id = pd.process_id  
   inner join T0040_hrms_R_Process_MAster as pm WITH (NOLOCK) on  
   pm.process_id = pd.process_id where re.cmp_id = @cmp_id order by re.rec_post_id  
   --where re.rec_post_id = 11  
 end  
  
return  




