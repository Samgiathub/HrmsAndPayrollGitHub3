
CREATE PROCEDURE [dbo].[P0100_Employee_Template_Response] 
	   @ETR_Id				int Output
      ,@Cmp_Id				int
      ,@Emp_Id				int
      ,@T_Id				int
      ,@F_Id				int
      ,@Answer				nvarchar(MAX) 
      ,@tran_type			varchar(1) 
	  ,@User_Id				numeric(18,0) = 0 
	  ,@Response_Flag int
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
			--IF EXISTS(SELECT 1 FROM T0100_Employee_Template_Response WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND T_Id = @T_Id AND F_Id = @F_Id)
			--	BEGIN
			--		RETURN 0
			--	END

			select @ETR_Id = isnull(max(ETR_Id),0) + 1 from T0100_Employee_Template_Response WITH (NOLOCK)
			
			Insert Into T0100_Employee_Template_Response
			(
				   ETR_Id			
				  ,Cmp_Id
				  ,Emp_Id
				  ,T_Id
				  ,F_Id
				  ,Answer
				  ,Created_Date
				  ,Response_Flag
			)
			Values
			(
				   @ETR_Id				
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@T_Id
				  ,@F_Id
				  ,@Answer
				  ,GETDATE()
				  ,@Response_Flag
			)

		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			
			UPDATE    T0100_Employee_Template_Response
			SET       Answer = @Answer,Created_Date=GETDATE()			  				
			WHERE ETR_Id = @ETR_Id and cmp_Id=@Cmp_ID

		End
	Else If  Upper(@tran_type) ='D'
		Begin
			Delete from  T0100_Employee_Template_Response  where ETR_Id = @ETR_Id
		End	

END
