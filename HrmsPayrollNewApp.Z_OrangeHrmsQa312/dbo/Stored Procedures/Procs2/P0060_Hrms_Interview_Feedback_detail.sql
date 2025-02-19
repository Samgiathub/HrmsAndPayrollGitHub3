


--zalak 06012011
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_Hrms_Interview_Feedback_detail]  
   @Feedback_detail_id		numeric(18,0) output  
  ,@Interview_Schedule_Id	numeric(18,0)  
  ,@Login_id				numeric(18,0) 
  ,@Emp_id					numeric(18, 0)	 
  ,@Cmp_id					numeric(18,0)  
  ,@Rec_Post_Id				numeric(18,0)  
  ,@Process_Q_ID			numeric(18,0)  
  ,@Description				varchar(1000)
  ,@Rating					numeric(18,2)
  ,@Resume_id				numeric(18,0)
  ,@process_detail_id		numeric(18,0)
  ,@total_rating		    numeric(18,2)
  ,@comments		        varchar(1000)
  ,@status			        int
  ,@Trans_Type				char(1)
  ,@BypassInterview         int
  
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 

  if @Login_id=0
	set @Login_id=null				
  if @Emp_id=0
	set @Emp_id=null					
  if @Cmp_id=0	
	set @Cmp_id=null				
  if @Rec_Post_Id=0		
	set @Rec_Post_Id=null		
  		
   
    
  declare @for_date as datetime
  set @for_date=cast(GETDATE() as varchar(11))
  
	declare @emp_id_staus as int
	if not exists(select Interview_Schedule_Id from t0055_hrms_interview_schedule WITH (NOLOCK) where  rec_post_id=@Rec_Post_Id and resume_id=@Resume_id and Interview_Process_Detail_Id=@process_detail_id)
		begin
			declare @time as varchar(10)
			set @time= dbo.F_GET_AMPM(GETDATE())
			declare @s_emp_id numeric(18,0)
			declare @s_emp_id2 numeric(18,0)
			declare @s_emp_id3 numeric(18,0)
			declare @s_emp_id4 numeric(18,0)
			select @s_emp_id=s_emp_id,@s_emp_id2=s_emp_id2,@s_emp_id3=s_emp_id3,@s_emp_id4=s_emp_id4 from t0055_Interview_Process_Detail WITH (NOLOCK) where  rec_post_id=@Rec_Post_Id and Interview_Process_Detail_Id=@process_detail_id 
			exec P0055_HRMS_Interview_Schedule @Interview_Schedule_Id,@process_detail_id,@Rec_Post_Id,@cmp_id,@s_emp_id,@s_emp_id2,@s_emp_id3,@s_emp_id4,@for_date,@for_date,@time,@time,@resume_id,0,0,0,0,'',@for_date,0,0,'I',''
		end
		--print 'm'
	if isnull(@Emp_id,0)<>0 
		select @Interview_Schedule_Id=Interview_Schedule_Id,@emp_id_staus=case when s_emp_id=@emp_id then 1 when s_emp_id2=@emp_id then 2 when s_emp_id3=@emp_id then 3 when s_emp_id4=@emp_id then 4 end from t0055_hrms_interview_schedule WITH (NOLOCK) where  rec_post_id=@Rec_Post_Id and resume_id=@Resume_id and Interview_Process_Detail_Id=@process_detail_id 
	else
		begin	
			select @Emp_id=s_emp_id from t0055_Interview_Process_Detail WITH (NOLOCK) where  rec_post_id=@Rec_Post_Id and Interview_Process_Detail_Id=@process_detail_id 
			select @Interview_Schedule_Id=Interview_Schedule_Id,@emp_id_staus=1 from t0055_hrms_interview_schedule WITH (NOLOCK) where  rec_post_id=@Rec_Post_Id and resume_id=@Resume_id and Interview_Process_Detail_Id=@process_detail_id 
		end
		if  @Interview_Schedule_Id=0
			BEGIN
				set @Interview_Schedule_Id=null
			END
		ELSE
			BEGIN	
				if @emp_id_staus=1
				   begin
						update t0055_hrms_interview_schedule set comments=@comments,rating=@total_rating,status=@status,system_date=@for_date,BypassInterview=@BypassInterview where Interview_Schedule_Id=@Interview_Schedule_Id
						update t0055_resume_master set resume_status=@status where resume_id=@resume_id
					end
				else if @emp_id_staus=2
					update t0055_hrms_interview_schedule set comments2=@comments,rating2=@total_rating,BypassInterview=@BypassInterview where Interview_Schedule_Id=@Interview_Schedule_Id
				else if @emp_id_staus=3
					update t0055_hrms_interview_schedule set comments3=@comments,rating3=@total_rating,BypassInterview=@BypassInterview where Interview_Schedule_Id=@Interview_Schedule_Id
				else if @emp_id_staus=4
					update t0055_hrms_interview_schedule set comments4=@comments,rating4=@total_rating,BypassInterview=@BypassInterview where Interview_Schedule_Id=@Interview_Schedule_Id
			END
			
  If @Trans_Type ='I'   
   BEGIN  
     if isnull(@Process_Q_ID,0) <> 0
     BEGIN 
		If EXISTS(SELECT Feedback_detail_id FROM T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK) Where Rec_Post_Id=@Rec_Post_Id and Process_Q_ID=@Process_Q_ID and Interview_Schedule_Id = @Interview_Schedule_Id   
         and emp_id = @emp_id)  
		 Begin  		  
			Select @Feedback_detail_id=Feedback_detail_id From T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK) Where Rec_Post_Id=@Rec_Post_Id and Process_Q_ID=@Process_Q_ID and Interview_Schedule_Id = @Interview_Schedule_Id   
			and emp_id = @emp_id
			update T0060_Hrms_Interview_Feedback_detail set Description=@Description,Rating=@Rating where Feedback_detail_id=@Feedback_detail_id
			Return        
        End   
        
        DECLARE @INDUCTION_FEEDBACK AS INT
        SET @INDUCTION_FEEDBACK = 0
        
        SELECT @INDUCTION_FEEDBACK=HM.Process_ID 
		FROM T0045_HRMS_R_PROCESS_TEMPLATE HI WITH (NOLOCK)
			INNER JOIN T0040_HRMS_R_PROCESS_MASTER HM WITH (NOLOCK) ON HI.Cmp_id=HM.Cmp_id and HI.Process_ID=hm.Process_ID
        WHERE UPPER(Process_Name)='INDUCTION FEEDBACK' AND HI.Process_Q_ID=@Process_Q_ID and HI.Cmp_ID=@cmp_id
		--PRINT @INDUCTION_FEEDBACK
		
		IF @INDUCTION_FEEDBACK >0
		BEGIN
			SET	@Interview_Schedule_Id=NULL
			
			If EXISTS(SELECT Feedback_detail_id FROM T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK) Where Cmp_id=@cmp_id and Rec_Post_Id=@Rec_Post_Id and Process_Q_ID=@Process_Q_ID and Interview_Schedule_Id IS NULL)  
			 Begin  		  
				SELECT @Feedback_detail_id=Feedback_detail_id From T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK) Where Cmp_id=@cmp_id and Rec_Post_Id=@Rec_Post_Id and Process_Q_ID=@Process_Q_ID and Interview_Schedule_Id IS NULL
				UPDATE T0060_Hrms_Interview_Feedback_detail set Description=@Description,Rating=@Rating WHERE Cmp_id=@cmp_id and Feedback_detail_id=@Feedback_detail_id
				RETURN  
			END
		END	
			--PRINT @INDUCTION_FEEDBACK
			--PRINT  @Interview_Schedule_Id
		SELECT @Feedback_detail_id = ISNULL(MAX(Feedback_detail_id),0) + 1  FROM T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK) 
      
		INSERT INTO T0060_Hrms_Interview_Feedback_detail  
                           (Feedback_detail_id, 
                           Interview_Schedule_Id,
                           Login_id,
                           Cmp_id,
                           Emp_id,
                           Rec_Post_Id,
                           Process_Q_ID,
                           Description,
                           Rating
                           )  
                           
						VALUES     
						(
							@Feedback_detail_id,
							@Interview_Schedule_Id,
							@Login_id,
							@Cmp_id,
							@Emp_id,
							@Rec_Post_Id,
							@Process_Q_ID,
							@Description,
							@Rating
							)   
							
    		 END  
    	ELSE	
    		BEGIN
    			SET @Feedback_detail_id=1 
			END	 
	END 
	 IF ISNULL(@Process_Q_ID,0) <> 0
		SET @Feedback_detail_id=1 
	
		
 RETURN  
  
  


