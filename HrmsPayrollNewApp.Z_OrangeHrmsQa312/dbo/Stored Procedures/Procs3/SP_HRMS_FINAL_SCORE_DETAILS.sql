




--'==========================================='
--''ALTER By : Falak
--''ALTER Date: 29-apr-2010
--''Description: 
--''Review By:
--''Last Modified By: 
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--'==========================================='
CREATE PROCEDURE [dbo].[SP_HRMS_FINAL_SCORE_DETAILS]
	
	@Cmp_ID numeric(18,0)
   ,@Resume_ID numeric(18,0) 
   ,@Rec_Post_ID numeric(18,0) 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

------------------------------------------------------------------------------------------------------------
------------------------------------- Created By : Falak on 29-apr-2010 ------------------------------------
------------------------------------------------------------------------------------------------------------

	Declare @temp Table
	(
	   Interview_Process_Detail_ID numeric(18,0),
	   Interview_Schedule_ID numeric(18,0),
	   Rec_Post_Id  numeric(18,0),
	   cmp_id numeric(18,0),
	   Resume_ID numeric(18,0),
	   Schedule_Date DateTime,
	   schedule_time varchar(50),
	   S_Emp_ID numeric(18,0),	   
	   Rating  numeric(18,2)  null,
	   Status numeric(18,0),
	   Process_Dis_No numeric(18,0)
	)
	
	
	    Declare @intr_Sch_Id AS numeric
	    Declare @intr_prc_ID as numeric
	    Declare @dis_no as numeric
	    declare @S_Emp_Id as numeric
	    --declare @prc_date as datetime
	   -- Declare
		
		Insert into @Temp Select interview_process_detail_id,0,@rec_post_id,@cmp_id,@resume_id,null
							,null,S_emp_id,null,0,Dis_No from 
			T0055_interview_process_Detail WITH (NOLOCK) where cmp_id = @cmp_id and rec_post_id = @rec_post_id
		      
		      
		declare SCh_cur cursor for
			select interview_process_detail_id,dis_no from
				T0055_Interview_Process_Detail WITH (NOLOCK) where rec_post_Id = @rec_post_id and cmp_id = @cmp_id
		open Sch_cur
		fetch next from sch_cur into @intr_prc_id,@dis_no
		while @@Fetch_Status = 0
		begin
		  
			if exists (select interview_schedule_Id from T0055_hrms_interview_schedule WITH (NOLOCK) where cmp_id = @cmp_id and 
						rec_post_id = @rec_post_id and
						interview_process_Detail_id = @intr_prc_id and process_dis_no = @dis_no and resume_id = @resume_id)
			begin
				--select @intr_prc_id,@dis_no					
				Update @temp  set interview_process_detail_id = I.interview_process_detail_id,
									interview_Schedule_id = I.interview_Schedule_id, 
									rec_post_id = I.rec_post_id,									
									schedule_date = I.schedule_date,schedule_time = I.schedule_time,
									S_Emp_Id = I.S_Emp_Id,Rating = I.Rating,
									Status = I.Status from
									T0055_hrms_interview_Schedule as I ,@temp T where I.cmp_id = @cmp_id and
									I.interview_process_detail_id= @intr_prc_id and I.process_dis_no = @dis_no
									and I.resume_id = @resume_id and I.rec_post_id = @rec_post_id and
							 T.process_dis_no = @dis_no and T.interview_process_detail_id = @intr_prc_id
							 
			    
									
			end
			
			fetch next from sch_cur into @intr_prc_id,@dis_no
		end
		
		close sch_cur
		deallocate sch_cur
	     
	 Select T.*,E.Emp_Full_Name,A.Process_Name from @Temp as T
			inner join T0080_Emp_Master as E WITH (NOLOCK) on T.S_Emp_Id = E.Emp_Id inner join 
			T0055_Interview_Process_Detail as D WITH (NOLOCK) on 
			D.interview_process_detail_id = T.interview_process_detail_Id 
			inner join dbo.T0040_HRMS_R_Process_MAster as A WITH (NOLOCK) on
			A.process_ID = D.process_Id order by T.process_dis_no asc
        

	
	RETURN




