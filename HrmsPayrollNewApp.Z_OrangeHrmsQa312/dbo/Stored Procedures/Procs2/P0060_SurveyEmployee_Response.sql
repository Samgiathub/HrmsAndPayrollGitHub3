-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_SurveyEmployee_Response] 
	   @SurveyEmp_Id		numeric(18,0) Output
      ,@Cmp_Id				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@Survey_Id			numeric(18,0)
      ,@SurveyQuestion_Id	numeric(18,0)
      ,@Answer				nvarchar(MAX) --Changed By Deepali -30jun22
      ,@Response_Date		datetime
      ,@tran_type			varchar(1) 
	  ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @OldValue as  nvarchar(max)
DECLARE @OldSurvey_Id AS VARCHAR(50)
DECLARE @OldSurveyQuestion_Id AS VARCHAR(50)
DECLARE @OldAnswer AS nVARCHAR(MAX)



	If Upper(@tran_type) ='I'
		Begin
			IF EXISTS(SELECT * FROM T0060_SurveyEmployee_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Survey_ID = @Survey_ID AND SurveyQuestion_ID = @SurveyQuestion_ID)
				BEGIN
					RETURN 0
				END

			select @SurveyEmp_Id = isnull(max(SurveyEmp_Id),0) + 1 from T0060_SurveyEmployee_Response WITH (NOLOCK)
			
			Insert Into T0060_SurveyEmployee_Response
			(
				   SurveyEmp_Id				
				  ,Cmp_Id
				  ,Emp_Id
				  ,Survey_Id
				  ,SurveyQuestion_Id
				  ,Answer
				  ,Response_Date
			)
			Values
			(
				   @SurveyEmp_Id				
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Survey_Id
				  ,@SurveyQuestion_Id
				  ,@Answer
				  ,GETDATE()
			)
			
			set @OldValue = 'New Value' + '#'+ 'Survey Id :' +cast(@Survey_Id as varchar(50)) + '#' + 'Survey Question Id :' + cast(@SurveyQuestion_Id as varchar(50)) + '#' + 'Answer :' + @Answer + '#' + 'Response_Date :' + convert(varchar(15),GETDATE(),103)     			
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			select @OldSurvey_Id =Survey_Id ,@OldSurveyQuestion_Id  =SurveyQuestion_Id,@OLDAnswer=ANSWER
			From T0060_SurveyEmployee_Response WITH (NOLOCK) Where SurveyEmp_Id = @SurveyEmp_Id and cmp_Id=@Cmp_ID

			UPDATE    T0060_SurveyEmployee_Response 
			SET       Answer = @Answer,Response_Date=GETDATE()			  				
			WHERE SurveyEmp_Id = @SurveyEmp_Id and cmp_Id=@Cmp_ID

			set @OldValue = 'Old Value' + '#'+ 'Survey Id :' +cast(@OldSurvey_Id as varchar(50)) + '#' + 'Survey Question Id :' + cast(@OldSurveyQuestion_Id as varchar(50)) + '#' + 'Answer :' + @OldAnswer
							+ 'New Value' + '#'+ 'Survey Id :' +cast(@Survey_Id as varchar(50)) + '#' + 'Survey Question Id :' + cast(@SurveyQuestion_Id as varchar(50)) + '#' + 'Answer :' + @Answer + '#' + 'Response_Date :' + convert(varchar(15),GETDATE(),103)   			
		
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			Delete from  T0060_SurveyEmployee_Response where SurveyEmp_Id = @SurveyEmp_Id
		End	

		DECLARE @Description VARCHAR(MAX)
		SET @Description='SurveyID' + cast(@Survey_Id as varchar(50)) +'-QuesID'+ cast(@SurveyQuestion_Id as varchar(50)) +'-Answer'+ @Answer
		
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Survey',@OldValue,@Emp_Id,@User_Id,@IP_Address
END
