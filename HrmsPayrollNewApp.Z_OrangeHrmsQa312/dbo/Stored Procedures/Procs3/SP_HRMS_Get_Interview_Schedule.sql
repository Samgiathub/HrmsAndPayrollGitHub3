


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_HRMS_Get_Interview_Schedule]  
 @Cmp_ID  numeric(18,0),  
 @search_id numeric(18,0),  
 @Search varchar(50)=null,  
 @f_date datetime = null,  
 @to_date datetime = null,  
 @rec_id numeric(18,0) =null  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
------------------------------------------------------------------------------------------------------------------  
------------------------------------ Created By : Falak on 29-06-2010 --------------------------------------------  
------------------------------------------------------------------------------------------------------------------  
   
    
    declare @Resume table  
    (  
       Resume_ID numeric(18,0),  
       Status    numeric(18,0),  
       Rec_Post_ID  numeric(18,0),  
       Process_dis_no numeric(18,0),  
       Schedule   varchar(50),  
       Schedule_Prev varchar(50),         
       Cmp_ID numeric(18,0)  
       
      
    )  
      
    declare @Resume_Id as numeric(18,0)  
    declare @P_dis_no as numeric(18,0)  
    declare @max_dis_no as numeric(18,0)  
    declare @rec_post_id as numeric(18,0)  
    declare @stat as numeric(18,0)  
    declare @rate as numeric(18,0)  
      
      
    insert into @Resume(Resume_ID,Status,Rec_Post_ID,Process_dis_no,Schedule,Schedule_Prev,Cmp_ID)  
        
    Select IS1.resume_Id,FS.status,RM.rec_post_Id,is1.process_dis_no,'','',RM.Cmp_ID  from   
     
    (SELECT Resume_ID,Max(Process_dis_No) as Process_dis_no  
  
    from T0055_HRMS_Interview_Schedule WITH (NOLOCK) group by Resume_ID) IS1 Inner join  
    V0055_Resume_View  RM on IS1.Resume_ID =RM.Resume_ID   
    Left outer join T0090_HRMS_Recruitment_final_Score FS  WITH (NOLOCK)
    on IS1.Resume_ID =FS.REsume_ID where rm.cmp_id = @cmp_id  
      
  declare curP cursor for  
   select resume_id,process_dis_no,rec_post_id from @resume  
    
  open curP  
  fetch next from curP into @Resume_Id,@P_dis_no,@rec_post_id  
  while @@Fetch_Status = 0  
  begin  
     
   select @max_dis_no = max(dis_no) from T0055_interview_process_detail WITH (NOLOCK) where rec_post_Id = @rec_post_id  
   
   select @stat = status,@rate = rating from T0055_hrms_interview_schedule WITH (NOLOCK) where resume_id = @resume_id and   
           process_dis_no = @p_dis_no
             
   if @p_dis_no = @max_dis_no  
   begin
	  
    if @rate is null
    begin
		update @resume set schedule = 'inCompleted',  
			 schedule_prev = 'process ' + cast(@p_dis_no as varchar) + ' incompleted'  
		where resume_id = @resume_id  
    end
    else
    begin
		update @resume set schedule = 'Completed',  
			 schedule_prev = 'process ' + cast(@p_dis_no as varchar) + ' completed'  
		where resume_id = @resume_id  
	end
   end  
   else  
   begin  
      
      
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
  
  
----------- Searching Logic ---------------------------------------------  
  
 --------------- when dates is null -------------------------------------  
 if @rec_id is null  
 begin  
  if @f_date is null and @To_date is null  
  begin  
   if @search_id = 0  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
      end  
        
      else if @search_id =1  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Emp_First_Name like @Search + '%'  
      end  
        
      else if @search_id =2  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Job_Title like @Search + '%'  
      end  
        
      else if @search_id = 3  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Total_Experience = cast(@search as numeric)  
     end  
       
     else if @search_id = 4  
     begin  
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Exp_CTC = cast(@search as numeric)  
        
      end   
  end  
  ----------------- when records between to dates ----------  
  else  
  begin  
   if @search_id = 0  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
         where R.REsume_posted_Date between @f_date and @To_date  
      end  
        
      else if @search_id =1  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Emp_First_Name like @Search + '%' and  
           R.REsume_posted_Date between @f_date and @To_date  
      end  
        
      else if @search_id =2  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Job_Title like @Search + '%' and  
           R.REsume_posted_Date between @f_date and @To_date  
      end  
        
      else if @search_id = 3  
      begin  
        
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Total_Experience = cast(@search as numeric) and  
           R.REsume_posted_Date between @f_date and @To_date  
     end  
       
     else if @search_id = 4  
     begin  
       select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where R.Exp_CTC = cast(@search as numeric) and  
           R.REsume_posted_Date between @f_date and @To_date  
        
      end  
  end  
 end  
 else  
 begin  
  select Re.*,R.App_Full_Name,R.Job_Title from @Resume as Re inner join   
           V0055_HRMS_Resume_Master as R on R.Resume_ID = Re.Resume_Id  
           where Re.rec_post_id = @rec_id  
 end  
 RETURN  
  
  


