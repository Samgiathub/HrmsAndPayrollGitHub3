

-- =============================================
-- AUTHOR:		Mukti Chauhan
-- CREATE DATE: 22-01-2018
-- DESCRIPTION:	Method/Input Master
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_Method_Master]
	@Method_Id		NUMERIC(18) OUTPUT  
   ,@CMP_ID			NUMERIC(18)   
   ,@Method			NVARCHAR(100)    --Changed by Deepali -7Jun22
   ,@TRAN_TYPE		VARCHAR(1) 
   ,@USER_ID		NUMERIC(18,0) = 0
   ,@IP_ADDRESS		VARCHAR(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	  IF UPPER(@TRAN_TYPE) ='I' OR UPPER(@TRAN_TYPE) ='U'
		BEGIN
			IF @Method = ''
				BEGIN				
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0040_HRMS_Method_Master WITH (NOLOCK) WHERE Method=@Method AND Method_Id<>@Method_Id AND CMP_ID=@CMP_ID)
				BEGIN
					SET @Method_Id = 0 						
					RETURN
				END		
		END
	 IF UPPER(@TRAN_TYPE) ='I'
		BEGIN
			SELECT @Method_Id = ISNULL(MAX(Method_Id),0) + 1 FROM T0040_HRMS_Method_Master WITH (NOLOCK)
			INSERT INTO T0040_HRMS_Method_Master(Method_Id,CMP_ID,Method)
			VALUES(@Method_Id,@CMP_ID,@Method)				
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='U' 
		BEGIN						
			UPDATE    T0040_HRMS_Method_Master
			SET       Method = @Method
			WHERE     Method_Id = @Method_Id
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='D'
		BEGIN
		--SELECT * from T0050_HRMS_InitiateAppraisal 
		--select * from T0040_HRMS_Method_Master
		
			--if EXISTS(SELECT 1 from T0050_HRMS_InitiateAppraisal where (isnull(Existing_Method_ID,0)=@Method_Id or ISNULL(Future_Method_ID,0)=@Method_Id))
			--BEGIN
			----print 'm'
			--	set @Method_Id=0
			--	RETURN
			--END
			DELETE FROM T0040_HRMS_Method_Master WHERE Method_Id = @Method_Id					
		END
	
END

