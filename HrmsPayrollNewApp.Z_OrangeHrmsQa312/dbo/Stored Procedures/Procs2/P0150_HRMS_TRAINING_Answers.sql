


-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[P0150_HRMS_TRAINING_Answers]
	 @Tran_Answer_ID			NUMERIC(18,0) OUTPUT
	,@Tran_Feedback_Id			NUMERIC(18,0)	=	null
	,@Tran_Emp_Detail_Id		NUMERIC(18,0)	=	null
	,@Tran_Question_Id			NUMERIC(18,0)
	,@Answer					VARCHAR(500)
	,@Cmp_Id					NUMERIC(18,0)
	,@Trans_Type				CHAR(1)
	,@emp_Id					Numeric(18,0)   --added on 31 July 2015
	,@Training_id				Numeric(18,0)	--added on 31 July 2015
	,@Training_Apr_ID			Numeric(18,0)	--added on 31 July 2015
	,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015
    ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
    ,@Training_Induction_ID		Numeric(18,0) --Mukti(19062018)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added By Mukti 20082015(start)
	declare @OldValue as varchar(max)
	declare @OldTran_Feedback_Id	VARCHAR(15)
	declare @OldTran_Emp_Detail_Id	VARCHAR(15)
	declare @OldTran_Question_Id	VARCHAR(15)
	declare @oldAnswer				VARCHAR(500)
	declare @OldTraining_id			VARCHAR(15)
	declare @OldCreate_Date 		VARCHAR(15)
--Added By Mukti 20082015(end)
BEGIN
	
	Declare @Create_Date AS DateTime
	Set @Create_Date = GETDATE()
	
	if @Training_Apr_ID=0
		set @Training_Apr_ID = NULL
	
	if @Training_Induction_ID=0
		set @Training_Induction_ID = NULL
	
	If Upper(@Trans_Type) ='I' 
		Begin
			if NOT EXISTS(select Tran_Answer_ID from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where emp_Id=@emp_Id and Training_Apr_ID=@Training_Apr_ID and Training_id=@Training_id and Tran_Question_Id=@Tran_Question_Id) --Mukti(02082017)
				BEGIN
					select @Tran_Answer_ID = Isnull(max(Tran_Answer_ID),0) + 1  From T0150_HRMS_TRAINING_Answers WITH (NOLOCK)
			
					Insert Into T0150_HRMS_TRAINING_Answers
							(
								Tran_Answer_ID
								,Tran_Feedback_Id
								,Tran_Emp_Detail_Id
								,Tran_Question_Id
								,Answer
								,Cmp_Id
								,Create_Date
								,emp_Id			--added on 31 July 2015
								,Training_id	--added on 31 July 2015
								,Training_Apr_ID	--added on 31 July 2015
								,Training_Induction_ID
							)
						VALUES
							(
								@Tran_Answer_ID
								,@Tran_Feedback_Id
								,@Tran_Emp_Detail_Id
								,@Tran_Question_Id
								,@Answer
								,@Cmp_Id
								,@Create_Date
								,@emp_Id		--added on 31 July 2015
								,@Training_id	--added on 31 July 2015
								,@Training_Apr_ID --added on 31 July 2015
								,@Training_Induction_ID
							)
					 --Added By Mukti 20082015(start)
						set @OldValue = 'New Value' + '#'+ 'Tran Feedback Id:' + cast(Isnull(@Tran_Feedback_Id,0) as varchar(15)) + '#' + 
															'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
															'Tran Emp Detail Id:' + cast(Isnull(@Tran_Emp_Detail_Id,0) as varchar(25)) + '#' +
															'Tran Question Id:' + cast(Isnull(@Tran_Question_Id,0) as varchar(25)) + '#' +
															'Answer:' + cast(Isnull(@Answer,'') as varchar(25)) + '#' +
															'Create Date:' + cast(Isnull(@Create_Date,'') as varchar(25)) + '#' +
															'Employee Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
															'Training Id:' + cast(Isnull(@Training_id,0) as varchar(25)) + '#' +
															'Training Apr ID:' + cast(Isnull(@Training_Apr_ID,0) as varchar(25)) 
															
					--Added By Mukti 20082015(end)		
				END
			else
				BEGIN  --Mukti(02082017)
					update T0150_HRMS_TRAINING_Answers
					set Answer=@Answer
					where emp_Id=@emp_Id and Training_Apr_ID=@Training_Apr_ID and Training_id=@Training_id and Tran_Question_Id=@Tran_Question_Id
				END
								
		End
	If Upper(@Trans_Type) ='D'
		begin
			--Added By Mukti 20082015(start)
					select @OldTran_Feedback_Id=Tran_Feedback_Id
						,@OldTran_Emp_Detail_Id=Tran_Emp_Detail_Id
						,@OldTran_Question_Id=Tran_Question_Id
						,@OldAnswer=Answer
						,@OldCreate_Date=Create_Date
						,@OldTraining_id=Training_id
					from t0150_HRMS_TRAINING_Answers WITH (NOLOCK)
					where emp_Id = @emp_Id and Training_Apr_ID = @Training_Apr_ID and Cmp_Id = @Cmp_Id
			--Added By Mukti 20082015(end)	
			
			delete from t0150_HRMS_TRAINING_Answers where emp_Id = @emp_Id and Training_Apr_ID = @Training_Apr_ID and Cmp_Id = @Cmp_Id
			
			--Added By Mukti 20082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Tran Feedback Id:' + cast(Isnull(@OldTran_Feedback_Id,0) as varchar(15)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
													'Tran Emp Detail Id:' + cast(Isnull(@OldTran_Emp_Detail_Id,0) as varchar(25)) + '#' +
													'Tran Question Id:' + cast(Isnull(@OldTran_Question_Id,0) as varchar(25)) + '#' +
													'Answer:' + cast(Isnull(@OldAnswer,'') as varchar(25)) + '#' +
													'Create Date:' + cast(Isnull(@OldCreate_Date,'') as varchar(25)) + '#' +
													'Employee Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
													'Training Id:' + cast(Isnull(@OldTraining_id,0) as varchar(25)) + '#' +
													'Training Apr ID:' + cast(Isnull(@Training_Apr_ID,0) as varchar(25)) 
			--Added By Mukti 20082015(end)				
		End 
	exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'ESS-Training Feedback',@OldValue,@Training_Apr_ID,@User_Id,@IP_Address
END
