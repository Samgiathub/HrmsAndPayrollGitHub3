
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_Emp_Assessment_View]
	   @Emp_AssessmentView_Id	numeric(18,0) out
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@SA_View					int
      ,@KPA_View				int
      ,@Effective_Date			datetime --19 sep 2016
      ,@tran_type				varchar(1) 
	  ,@User_Id					numeric(18,0) = 0
	  ,@IP_Address				varchar(30)= ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		BEGIN
			If @Emp_Id = 0
				BEGIN
					set @Emp_AssessmentView_Id=0
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'No employee Id',0,'Enter Employee',GetDate(),'Appraisal')						
					Return
				END
		END
	If Upper(@tran_type) ='I'
		BEGIN
			SELECT @Emp_AssessmentView_Id = isnull(max(Emp_AssessmentView_Id),0) + 1 FROM T0060_Emp_Assessment_View	WITH (NOLOCK)
			INSERT INTO T0060_Emp_Assessment_View
				(
					Emp_AssessmentView_Id
					,Cmp_Id
					,Emp_Id
					,SA_View
					,KPA_View
					,Effective_Date		--19 sep 2016			
				)	
			VALUES(
					@Emp_AssessmentView_Id
					,@Cmp_Id
					,@Emp_Id
					,@SA_View
					,@KPA_View	
					,@Effective_Date --19 sep 2016
				)
		END
	Else If  Upper(@tran_type) ='U' 
		BEGIN
			Update T0060_Emp_Assessment_View
			set  SA_View = @SA_View
				,KPA_View = @KPA_View
				,Effective_Date = @Effective_Date --19 sep 2016
			Where Emp_Id = @Emp_Id and Emp_AssessmentView_Id = @Emp_AssessmentView_Id
		END
	Else If  Upper(@tran_type) ='D'
		BEGIN
			delete from T0060_Emp_Assessment_View where Emp_AssessmentView_Id = @Emp_AssessmentView_Id
		END
END
--------------------

