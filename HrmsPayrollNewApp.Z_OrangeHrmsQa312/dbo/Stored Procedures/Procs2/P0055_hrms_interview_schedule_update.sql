



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_hrms_interview_schedule_update]


	@Interview_Schedule_Id			numeric(18,0) output
	,@Interview_Process_Detail_Id	numeric(18,0)
	,@Rec_Post_Id					numeric(18,0)
	,@Cmp_Id						numeric(18,0)
	,@S_Emp_Id						numeric(18,0)
	,@Resume_Id						numeric(18,0)
	,@Rating                        numeric(18,0)
	,@Comments                      varchar(50) 
		

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 if @Rating = 0
		set @Rating = null
	
	if @Comments = ''
		set @Comments = null

	if @Interview_Schedule_Id > 0
		begin
		
			update T0055_HRMS_Interview_Schedule 
			set 
				Rating = @Rating
				,S_Emp_Id	= @S_Emp_Id
					where Interview_Schedule_Id = @Interview_Schedule_Id
		end

/*	 else

		select @Interview_Schedule_Id = isnull(max(Interview_Schedule_Id),0) +1 from T0055_HRMS_Interview_Schedule  
     
     						
		insert into T0055_HRMS_Interview_Schedule(
											Interview_Schedule_Id
											,Interview_Process_Detail_Id
											,cmp_id
											,Rec_Post_ID																				
											,S_Emp_ID
											,From_Date 
											,To_Date
											,From_Time                
											,To_Time 
											,Resume_Id
											,Rating
											,Schedule_Time
											,Schedule_Date
											,Process_Dis_No
											,status
											,System_Date
											,Comments
					) 
											
								values(      @Interview_Schedule_Id
											,@Interview_Process_Detail_Id
											,@cmp_id
											,@Rec_Post_ID											
											,@S_Emp_ID
											,getdate()
											,getdate()
											,select convert(varchar, getdate(), 8)                
											,select convert(varchar, getdate(), 8) 
											,@Resume_Id
											,@Rating
											,''
											,''
											,@Process_Dis_No
											,@status
											,getdate()
											,''
					)
		update t0055_resume_master set Rec_Post_ID=@Rec_Post_ID , resume_code =('R' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(@Resume_id,0) as varchar(20)) ) where cmp_id=@cmp_id and resume_id =@resume_id
	
		end  */
	
	
	 
RETURN




