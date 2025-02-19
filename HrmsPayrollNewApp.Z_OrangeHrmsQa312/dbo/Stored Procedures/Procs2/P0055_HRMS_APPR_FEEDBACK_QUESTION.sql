
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_HRMS_APPR_FEEDBACK_QUESTION]
 @Que_id			numeric(18,0) output
,@Question			nvarchar(100)  --Changed by Deepali -04Jun22
,@Que_Description	nvarchar(500)  --Changed by Deepali -04Jun22
,@Appr_id			numeric(18,0)
,@Login_id			numeric(18,0)
,@Emp_status		int
,@Cmp_Id			Numeric(18,0)
,@Is_View			int
,@tran_type			char           
           
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Login_id = 0
	set @Login_id = null
	
	if Upper(@tran_type) ='I' 
		begin		
			--if exists (Select Que_id from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WHERE  QUESTION =@QUESTION  and Appr_id=@Appr_id and Emp_status=@Emp_status)
			--If exists (Select Que_ID from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WHERE Question=@Question And Emp_status=@Emp_status And Cmp_Id=@Cmp_ID)
			If exists (Select Que_ID from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WITH (NOLOCK) WHERE Question=@Question And Appr_ID=@Appr_ID And Emp_Status=@Emp_Status) 
				Begin					
					RAISERROR('Duplicate Question',16,2)
					RETURN 
					set @Que_ID=0
					RETURN 
				End
					select @Que_id = isnull(max(Que_id),0) + 1 from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WITH (NOLOCK)
						
					insert into dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION
											(
												Que_id
												,Question
												,Que_Description
												,Posted_Date
												,Appr_id
												,Login_id
												,Emp_status
												,Cmp_Id
												,Is_view
											) 
											
									values(
												@Que_id
												,@Question
												,@Que_Description
												,getdate()
												,@Appr_id
												,@Login_id
												,@Emp_status
												,@Cmp_Id
												,@Is_view
									)

		End 
	Else If Upper(@tran_type) ='U' 
		Begin
		
		--If exists( Select Que_id from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WHERE QUESTION =@QUESTION and que_id <> @Que_Id)
		--		begin
		--			set @Que_ID=0
		--			RETURN 
		--		End
		--If exists (Select Que_ID from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WHERE Question=@Question And Emp_status=@Emp_status And Cmp_Id=@Cmp_ID And Que_Id<>@Que_ID)
		--If exists (Select Que_ID from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WHERE Appr_Id@Appr_Id)
		--		Begin					
		--			RAISERROR('Duplicate Question',16,2)
		--			RETURN 
		--			set @Que_ID=0
		--			RETURN 
		--		End		
					Update dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION					
					Set Question=@Question,Que_Description=@Que_Description
					,Login_id=@Login_id,Emp_status=@Emp_status,Cmp_ID=@Cmp_Id,Is_View=@Is_View where Que_id=@Que_id And Appr_id=@Appr_id
		End
		
	Else If upper(@tran_type) ='D'
		Begin
			delete from dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION where Que_id=@Que_id 
		End			
	RETURN
