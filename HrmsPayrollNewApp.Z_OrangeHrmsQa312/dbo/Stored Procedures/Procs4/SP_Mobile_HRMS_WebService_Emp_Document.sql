
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Emp_Document]
	@Emp_ID NUMERIC(18,0),
	@Cmp_ID NUMERIC(18,0),
	@Doc_ID NUMERIC(18,0),
	@Doc_Type int,
	@Doc_Name varchar(MAX),
	@Doc_Comment varchar(MAX),
	@Login_ID numeric,
	@Type Char(1),
	@Result varchar(255) OUTPUT
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Row_ID numeric(18,0) = 0

IF @Type = 'I' --- For Document Upload
	BEGIN
		BEGIN TRY
			EXEC P0090_EMP_DOC_DETAIL @Row_ID OUTPUT ,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Doc_ID = @Doc_ID,
			@Doc_Path = @Doc_Name,@Doc_Comments = @Doc_Comment,@tran_type='Insert',@Login_Id = @Login_ID,
			@Date_Of_Expiry =''
			
			SET @Result = 'Document Upload Successfully#True#'
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
		END CATCH
	END
ELSE IF @Type = 'R' --- For Document Read Status
	BEGIN
		BEGIN TRY
			IF NOT EXISTS (SELECT * FROM T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK) WHERE Cmp_ID =  @Cmp_ID AND Emp_ID = @Emp_ID AND Policy_Doc_ID = @Doc_ID)
				BEGIN
					EXEC P0090_EMP_POLICY_DOC_READ_DETAIL @Cmp_Id = @Cmp_ID,@Emp_ID	= @Emp_ID,@Policy_Doc_ID = @Doc_ID,@Doc_Type = @Doc_Type,@Is_Mobile_Read = 1 
		
					SET @Result = 'Document Read #True#'
				END
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
		END CATCH
	END

