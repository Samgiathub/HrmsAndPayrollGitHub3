



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[HRMS_TRAINING_APPLICATION_RECORD]
	
	 @Cmp_id numeric(18,0) 
	,@Training_app_ID numeric(18,0) 
	,@Emp_id numeric(18,0) =null
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	  
	   Begin Transaction	
		
		Select Training_App_ID,Training_id,Training_Desc,For_Date,Posted_Emp_ID,
			Skill_ID,App_Status,Cmp_ID,Login_ID
		 from T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK) where Training_App_ID=@Training_app_ID And Cmp_ID =@Cmp_id
		
		Select Emp_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Training_App_ID=@Training_app_ID And Cmp_ID =@Cmp_id

	 COMMIT TRANSACTION

	RETURN




