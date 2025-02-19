


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 14-12-2018
-- Description:	Questionaries Anwser for Induction
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0160_HRMS_Training_Questionnaire_Response_Induction]
	   @Tran_Response_Id    numeric(18,0) output
      ,@Cmp_Id				numeric(18,0)
      ,@Checklist_ID		numeric(18,0)
	  ,@Checklist_Fun_ID	numeric(18,0)
      ,@Training_id			numeric(18,0)
      ,@Emp_id				numeric(18,0)
      ,@Tran_Question_Id	numeric(18,0)
      ,@Answer				varchar(800)
      ,@Marks_obtained		numeric(18,0)
	  ,@Induction_Training_Type tinyint
	  ,@Training_Attempt_Count tinyint
      ,@TransType			Varchar(1)
      ,@User_Id numeric(18,0) = 0 
      ,@IP_Address varchar(30)= ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as varchar(max)
    declare @OldTraining_id			varchar(15)
    declare @OldTran_Question_Id	varchar(15)
    declare @OldAnswer				varchar(800)
    declare @OldMarks_obtained		varchar(15)
    declare @OldCreateDate			varchar(25)
    declare @OldTran_Id				varchar(25)
	declare @OldInduction_Training_Type varchar(25)

	Declare @Exam_Attempt_Count tinyint
	Set @Exam_Attempt_Count = 0

BEGIN
	SET NOCOUNT ON;
	If Upper(@TransType) ='I' 
		begin
			
			select @Tran_Response_Id = Isnull(max(Tran_Response_Id),0) + 1  From T0160_HRMS_Training_Questionnaire_Response_Induction WITH (NOLOCK)
			Insert Into T0160_HRMS_Training_Questionnaire_Response_Induction
			(
				  Tran_Response_Id
				  ,Cmp_Id
				  ,Checklist_ID
				  ,Training_id
				  ,Emp_id
				  ,Tran_Question_Id
				  ,Answer
				  ,CreateDate
				  ,Marks_obtained
				  ,Checklist_Fun_ID
				  ,Induction_Training_Type
				  ,Training_attempt_count
			) 
			values
			(
				 @Tran_Response_Id
				,@Cmp_Id
				,@Checklist_ID
				,@Training_id
				,@Emp_id
				,@Tran_Question_Id
				,@Answer
				,GETDATE()
				,@Marks_obtained
				,@Checklist_Fun_ID
				,@Induction_Training_Type
				,@Training_Attempt_Count
			)
		
			    set @OldValue = 'New Value' + '#'+ 'CheckList Id:' + cast(Isnull(@Checklist_ID,0) as varchar(15)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
													'Emp Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
													'Training Id:' + cast(Isnull(@Training_id,0) as varchar(25)) + '#' +
													'Question Id:' + cast(Isnull(@Tran_Question_Id,0) as varchar(25)) + '#' +
													'Answer:' + cast(Isnull(@Answer,'') as varchar(25)) + '#' +
													'Marks Obtained:' + cast(Isnull(@Marks_obtained,0) as varchar(25)) + '#' +
													'CheckList Fun Id:' + cast(Isnull(@Checklist_Fun_ID,0) as varchar(15)) + '#' +
													'Induction_Training_Type:' + cast(Isnull(@Induction_Training_Type,0) as varchar(15)) 
		end
	else if Upper(@TransType) ='D' 
		begin
				IF @Induction_Training_Type = 1
					Begin
						select  @OldTraining_id=Training_id
							,@OldTran_Question_Id=Tran_Question_Id
							,@OldAnswer=Answer
							,@OldCreateDate=CreateDate
							,@OldMarks_obtained=Marks_obtained
							,@OldInduction_Training_Type = Induction_Training_Type
						from T0160_HRMS_Training_Questionnaire_Response_Induction WITH (NOLOCK)
						where emp_Id = @emp_Id and Checklist_ID = @Checklist_ID and Cmp_Id = @Cmp_Id

						delete from T0160_HRMS_Training_Questionnaire_Response_Induction where emp_Id = @emp_Id and Checklist_ID = @Checklist_ID and Cmp_Id = @Cmp_Id
					End
				Else if @Induction_Training_Type = 2
					BEGIN
						select  @OldTraining_id=Training_id
							,@OldTran_Question_Id=Tran_Question_Id
							,@OldAnswer=Answer
							,@OldCreateDate=CreateDate
							,@OldMarks_obtained=Marks_obtained
							,@OldInduction_Training_Type = Induction_Training_Type
						from T0160_HRMS_Training_Questionnaire_Response_Induction WITH (NOLOCK)
						where emp_Id = @emp_Id and Checklist_Fun_ID = @Checklist_Fun_ID and Cmp_Id = @Cmp_Id

						delete from T0160_HRMS_Training_Questionnaire_Response_Induction where emp_Id = @emp_Id and Checklist_Fun_ID = @Checklist_Fun_ID and Cmp_Id = @Cmp_Id
					End
		
			    set @OldValue = 'New Value' + '#'+ 'CheckList Id:' + cast(Isnull(@Checklist_ID,0) as varchar(15)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
													'Emp Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
													'Training Id:' + cast(Isnull(@OldTraining_id,0) as varchar(25)) + '#' +
													'Question Id:' + cast(Isnull(@OldTran_Question_Id,0) as varchar(25)) + '#' +
													'Answer:' + cast(Isnull(@OldAnswer,'') as varchar(25)) + '#' +
													'Marks Obtained:' + cast(Isnull(@OldMarks_obtained,0) as varchar(25)) + '#' +
													'Tran_Id:' + cast(Isnull(@OldTran_Id,0) as varchar(25)) + '#' +
													'CheckList Fun Id:' + cast(Isnull(@Checklist_Fun_ID,0) as varchar(15)) + '#' +
													'Induction_Training_Type:' + cast(Isnull(@Induction_Training_Type,0) as varchar(15)) 
		
		end
		IF @Induction_Training_Type = 1
			Begin
				exec P9999_Audit_Trail @Cmp_ID,@TransType,'ESS-Training Questionnaire Induction (HR)',@OldValue,@Checklist_ID,@User_Id,@IP_Address
			End
		Else
			Begin
				exec P9999_Audit_Trail @Cmp_ID,@TransType,'ESS-Training Questionnaire Induction (Functional)',@OldValue,@Checklist_ID,@User_Id,@IP_Address
			End
	
END

