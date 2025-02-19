

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0160_HRMS_Training_Questionnaire_Response]
	   @Tran_Response_Id    numeric(18,0) output
      ,@Cmp_Id				numeric(18,0)
      ,@Training_Apr_ID		numeric(18,0)
      ,@Training_id			numeric(18,0)
      ,@Emp_id				numeric(18,0)
      ,@Tran_Question_Id	numeric(18,0)
      ,@Answer				varchar(800)
      ,@Marks_obtained		numeric(18,0)
      ,@TransType			Varchar(1)
      ,@Tran_Id				numeric(18,0)
      ,@User_Id numeric(18,0) = 0 -- added By Mukti 20082015
      ,@IP_Address varchar(30)= '' -- added By Mukti 20082015
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--Added By Mukti 20082015(start)
	declare @OldValue as varchar(max)
    declare @OldTraining_id			varchar(15)
    declare @OldTran_Question_Id	varchar(15)
    declare @OldAnswer				varchar(800)
    declare @OldMarks_obtained		varchar(15)
    declare @OldCreateDate			varchar(25)
    declare @OldTran_Id				varchar(25)
--Added By Mukti 20082015(end)
BEGIN
	SET NOCOUNT ON;
	
	IF @Training_Apr_ID =0
		SET @Training_Apr_ID=NULL

	If Upper(@TransType) ='I' 
		begin
		print @Training_Apr_ID
			select @Tran_Response_Id = Isnull(max(Tran_Response_Id),0) + 1  From T0160_HRMS_Training_Questionnaire_Response WITH (NOLOCK)
			Insert Into T0160_HRMS_Training_Questionnaire_Response
			(
				  Tran_Response_Id
				  ,Cmp_Id
				  ,Training_Apr_ID
				  ,Training_id
				  ,Emp_id
				  ,Tran_Question_Id
				  ,Answer
				  ,CreateDate
				  ,Marks_obtained
				  ,Tran_Id
			) 
			values
			(
				 @Tran_Response_Id
				,@Cmp_Id
				,@Training_Apr_ID
				,@Training_id
				,@Emp_id
				,@Tran_Question_Id
				,@Answer
				,GETDATE()
				,@Marks_obtained
				,@Tran_Id
			)
		--Added By Mukti 20082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Tran Approval Id:' + cast(Isnull(@Training_Apr_ID,0) as varchar(15)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
													'Emp Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
													'Training Id:' + cast(Isnull(@Training_id,0) as varchar(25)) + '#' +
													'Question Id:' + cast(Isnull(@Tran_Question_Id,0) as varchar(25)) + '#' +
													'Answer:' + cast(Isnull(@Answer,'') as varchar(25)) + '#' +
													'Marks Obtained:' + cast(Isnull(@Marks_obtained,0) as varchar(25)) + '#' +
													'Tran_Id:' + cast(Isnull(@Tran_Id,0) as varchar(25))
		--Added By Mukti 20082015(end)
		end
	else if Upper(@TransType) ='D' 
		begin
		--Added By Mukti 20082015(start)
					select  @OldTraining_id=Training_id
							,@OldTran_Question_Id=Tran_Question_Id
							,@OldAnswer=Answer
							,@OldCreateDate=CreateDate
							,@OldMarks_obtained=Marks_obtained
							,@OldTran_Id=Tran_Id
					from T0160_HRMS_Training_Questionnaire_Response WITH (NOLOCK)
					where emp_Id = @emp_Id and Training_Apr_ID = @Training_Apr_ID and Cmp_Id = @Cmp_Id
			--Added By Mukti 20082015(end)
			
			delete from T0160_HRMS_Training_Questionnaire_Response where emp_Id = @emp_Id and Training_Apr_ID = @Training_Apr_ID and Cmp_Id = @Cmp_Id
		
		--Added By Mukti 20082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Tran Approval Id:' + cast(Isnull(@Training_Apr_ID,0) as varchar(15)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' +
													'Emp Id:' + cast(Isnull(@emp_Id,0) as varchar(25)) + '#' +
													'Training Id:' + cast(Isnull(@OldTraining_id,0) as varchar(25)) + '#' +
													'Question Id:' + cast(Isnull(@OldTran_Question_Id,0) as varchar(25)) + '#' +
													'Answer:' + cast(Isnull(@OldAnswer,'') as varchar(25)) + '#' +
													'Marks Obtained:' + cast(Isnull(@OldMarks_obtained,0) as varchar(25)) + '#' +
													'Tran_Id:' + cast(Isnull(@OldTran_Id,0) as varchar(25))
		--Added By Mukti 20082015(end)
		end
	exec P9999_Audit_Trail @Cmp_ID,@TransType,'ESS-Training Questionnaire',@OldValue,@Training_Apr_ID,@User_Id,@IP_Address
END

