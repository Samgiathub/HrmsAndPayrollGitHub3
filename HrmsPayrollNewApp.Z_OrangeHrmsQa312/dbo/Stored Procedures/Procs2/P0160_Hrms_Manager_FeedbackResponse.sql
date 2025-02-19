
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_Hrms_Manager_FeedbackResponse]
	 @Tran_ManagerFeedback_Id	numeric(18,0) OUTPUT
	,@Cmp_Id					numeric(18,0)
    ,@Training_Apr_Id			numeric(18,0)
    ,@Training_Id				numeric(18,0)
    ,@Emp_Id					numeric(18,0)
    ,@Tran_Question_Id			numeric(18,0)
    ,@Manager_Answer			varchar(800)	
    ,@Ans_Date					datetime
    ,@Feedback_By				numeric(18,0)
    ,@Tran_Type					varchar(1) 
    ,@User_Id					numeric(18,0) = 0 -- added By Mukti 19082015
    ,@IP_Address				varchar(30)= '' -- added By Mukti 19082015
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If UPPER(@Tran_Type) ='I'
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM T0160_Hrms_Manager_FeedbackResponse WITH (NOLOCK) WHERE Training_Apr_Id=@Training_Apr_Id and Tran_Question_Id=@Tran_Question_Id and emp_id=@emp_id and Feedback_By=@Feedback_By)
				BEGIN
					select @Tran_ManagerFeedback_Id = isnull(max(Tran_ManagerFeedback_Id),0)+1 from T0160_Hrms_Manager_FeedbackResponse WITH (NOLOCK)
					Insert INTO T0160_Hrms_Manager_FeedbackResponse
					(
						 Tran_ManagerFeedback_Id
						,Cmp_Id
						,Training_Apr_Id
						,Training_Id
						,Emp_Id
						,Tran_Question_Id
						,Manager_Answer
						,Ans_Date
						,Feedback_By
						
					)
					VALUES(
						 @Tran_ManagerFeedback_Id
						,@Cmp_Id
						,@Training_Apr_Id
						,@Training_Id
						,@Emp_Id
						,@Tran_Question_Id
						,@Manager_Answer
						,@Ans_Date
						,@Feedback_By
					)
				END
			ELSE
				BEGIN
					UPDATE T0160_Hrms_Manager_FeedbackResponse
					SET Manager_Answer = @Manager_Answer
						,Ans_Date = @Ans_Date	
					WHERE Training_Apr_Id=@Training_Apr_Id and Tran_Question_Id=@Tran_Question_Id and emp_id=@emp_id
				END
		END
	Else If UPPER(@Tran_Type) ='U'
		BEGIN
			update T0160_Hrms_Manager_FeedbackResponse
			set Tran_Question_Id = @Tran_Question_Id
			    ,Manager_Answer = @Manager_Answer
			    ,Ans_Date = @Ans_Date	
			Where Tran_ManagerFeedback_Id=@Tran_ManagerFeedback_Id
		END
	Else If UPPER(@Tran_Type) ='D'
		BEGIN
			Delete from T0160_Hrms_Manager_FeedbackResponse where Training_Apr_Id=@Training_Apr_Id and Emp_Id=@emp_id
		END
END


