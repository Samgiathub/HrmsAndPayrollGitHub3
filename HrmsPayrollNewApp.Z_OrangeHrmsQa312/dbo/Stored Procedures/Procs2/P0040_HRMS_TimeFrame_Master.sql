
-- =============================================
-- AUTHOR:		Mukti Chauhan
-- CREATE DATE: 22-01-2018
-- DESCRIPTION:	TimeFrame Master
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_TimeFrame_Master]
	@TimeFrame_Id	NUMERIC(18) OUTPUT  
   ,@CMP_ID			NUMERIC(18)   
   ,@TimeFrame		NVARCHAR(100)    --Changed by Deepali -04Jun22
   ,@TRAN_TYPE		VARCHAR(1) 
   ,@USER_ID		NUMERIC(18,0) = 0
   ,@IP_ADDRESS		VARCHAR(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	  IF UPPER(@TRAN_TYPE) ='I' OR UPPER(@TRAN_TYPE) ='U'
		BEGIN
			IF @TimeFrame = ''
				BEGIN				
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0040_HRMS_TimeFrame_Master WITH (NOLOCK) WHERE TimeFrame=@TimeFrame AND TimeFrame_Id<>@TimeFrame_Id AND CMP_ID=@CMP_ID)
				BEGIN
					SET @TimeFrame_Id = 0 						
					RETURN
				END		
		END
	 IF UPPER(@TRAN_TYPE) ='I'
		BEGIN
			SELECT @TimeFrame_Id = ISNULL(MAX(TimeFrame_Id),0) + 1 FROM T0040_HRMS_TimeFrame_Master WITH (NOLOCK)
			INSERT INTO T0040_HRMS_TimeFrame_Master(TimeFrame_Id,CMP_ID,TimeFrame)
			VALUES(@TimeFrame_Id,@CMP_ID,@TimeFrame)				
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='U' 
		BEGIN						
			UPDATE    T0040_HRMS_TimeFrame_Master
			SET       TimeFrame = @TimeFrame
			WHERE     TimeFrame_Id = @TimeFrame_Id
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='D'
		BEGIN
			if EXISTS(SELECT 1 from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where ISNULL(TimeFrame_Id,0)=@TimeFrame_Id)
				BEGIN
			--print 'm'
					set @TimeFrame_Id=0
					RETURN
				END
			DELETE FROM T0040_HRMS_TimeFrame_Master WHERE TimeFrame_Id = @TimeFrame_Id					
		END
	
END

