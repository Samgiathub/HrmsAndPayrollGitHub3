



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_Get_Rec_Post_Record]  
 @Cmp_Id numeric(18,0)
 --,@rec_id numeric(18,0)  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
    
  ---------------------------------------------------------------------------------------------------------------  
  --------------------------------------- Created By: Falak on 22-Jun-2010 --------------------------------------  
  ---------------------------------------------------------------------------------------------------------------  
    
  declare @Temp table(  
  cmp_Id numeric(18,0),  
  rec_post_Id numeric(18,0),  
  Job_Title varchar(50),  
  Emp_Full_Name varchar(100),  
  Rec_End_Date Datetime,  
  NO_Of_Vac numeric(18,0),  
  Location varchar(200),  
  Posted_Status numeric(18,0),  
  Total_App numeric(18,0),  
  Total_App_New numeric(18,0),  
  Total_App_Apr numeric(18,0),  
  Total_App_Hld numeric(18,0),  
  Total_App_Rjt numeric(18,0),  
  Total_App_Sel numeric(18,0)  
  )  
    
  insert into @Temp  
    
     select p.cmp_Id,p.rec_post_Id,p.job_Title,e.Emp_full_Name,p.Rec_End_date,r.No_Of_vacancies,  
     isnull(p.Location,'') as Location,  
     case   
     when p.rec_end_date > getdate() then p.Posted_Status  
     else 4 end as Posted_status,  
     0,0,0,0,0,0 from T0052_HRMS_Posted_Recruitment as p WITH (NOLOCK) inner join T0050_HRMS_Recruitment_Request as r  WITH (NOLOCK)
     on p.rec_req_id = r.rec_req_id inner join T0080_Emp_Master as e WITH (NOLOCK) on  
     p.s_emp_id = e.emp_id where p.cmp_Id = @cmp_Id  
    
  -- Changed on 24/06/2010 by falak added emp_full_name  
    
  declare @Total_App as numeric(18,0)  
  declare @Total_App_New as numeric(18,0)  
  declare @Total_App_Apr as numeric(18,0)  
  declare @Total_App_Hld as numeric(18,0)  
  declare @Total_App_Rjt as numeric(18,0)  
  declare @Total_App_Sel as numeric(18,0)  
  declare @rec_post_id as numeric(18,0)  
    
  declare curRec cursor for  
   select rec_post_Id from @Temp  
  open curRec  
  Fetch next from curRec into @rec_post_id  
  while @@Fetch_Status = 0  
  begin  
   --select @rec_post_id  
   select @Total_App = count(resume_Id) from T0055_Resume_Master WITH (NOLOCK) where rec_post_id = @rec_post_id  
   select @Total_App_New = count(resume_Id) from T0055_Resume_Master WITH (NOLOCK) where rec_post_id = @rec_post_id  
               and resume_Status = 0  
   select @Total_App_Apr = count(resume_Id) from T0055_Resume_Master WITH (NOLOCK) where rec_post_id = @rec_post_id  
               and resume_Status = 1  
   select @Total_App_Hld = count(resume_Id) from T0055_Resume_Master WITH (NOLOCK) where rec_post_id = @rec_post_id  
               and resume_status = 2  
   select @Total_App_Rjt = count(resume_Id) from T0055_Resume_Master WITH (NOLOCK) where rec_post_id = @rec_post_id  
               and resume_status = 3  
                 
   select @Total_App_Sel = count(resume_id) from T0090_hrms_recruitment_final_score WITH (NOLOCK) where rec_post_id = @rec_post_id  
               and status = 1  
   --select @Total_app,@total_app_new,@total_app_apr,@total_app_hld,@total_app_rjt  
   update @Temp set Total_App = @Total_App,  
       Total_App_New = @Total_App_New,  
       Total_App_Apr = @Total_App_Apr,  
       Total_App_Hld = @Total_App_Hld,  
       Total_App_Rjt = @Total_App_Rjt,  
       Total_App_Sel = @Total_App_Sel  
    where rec_post_Id = @rec_post_id  
        
   fetch next from curRec into @rec_Post_id  
  end  
    
  close curRec  
  deallocate curRec  
    
  select * from @Temp --where posted_status <> 4  
    
  --falak 08-jul-2010  
  --select * from V0090_HRMS_Rating_Details where rec_post_Id = @rec_id  
    
 RETURN  
  



