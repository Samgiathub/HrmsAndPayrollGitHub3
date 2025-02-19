


-- =============================================
-- AUTHOR:		Mukti Chauhan
-- CREATE DATE: 22-01-2018
-- DESCRIPTION:	Employee Type Master
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_KPAType_Master]
	@KPA_Type_Id	NUMERIC(18) OUTPUT  
   ,@CMP_ID			NUMERIC(18)   
   ,@KPA_Type		nVARCHAR(100)    --Changed by Deepali -04Jun22
   ,@TRAN_TYPE		VARCHAR(1) 
   ,@USER_ID		NUMERIC(18,0) = 0
   ,@IP_ADDRESS		VARCHAR(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	 DECLARE @OLDVALUE AS nVARCHAR(MAX)
	 DECLARE @OLDCONTENT AS nVARCHAR(100)
	 DECLARE @OLDSORT AS nVARCHAR(18)
	 
	 SET @OLDVALUE = ''
	 SET @OLDCONTENT = ''
	 SET @OLDSORT =''
	 
	  IF UPPER(@TRAN_TYPE) ='I' OR UPPER(@TRAN_TYPE) ='U'
		BEGIN
			IF @KPA_Type = ''
				BEGIN				
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0040_HRMS_KPAType_Master WITH (NOLOCK) WHERE KPA_Type=@KPA_Type AND CMP_ID=@CMP_ID)  --AND KPA_Type_Id<>@KPA_Type_Id 
				BEGIN
					SET @KPA_Type_Id = 0 						
					RETURN
				END		
		END
	 IF UPPER(@TRAN_TYPE) ='I'
		BEGIN
			SELECT @KPA_Type_Id = ISNULL(MAX(KPA_Type_Id),0) + 1 FROM T0040_HRMS_KPAType_Master WITH (NOLOCK)
			INSERT INTO T0040_HRMS_KPAType_Master(KPA_Type_Id,CMP_ID,KPA_Type)
			VALUES(@KPA_Type_Id,@CMP_ID,@KPA_Type)	
			SET @OLDVALUE = 'New Value' + '#'+ 'Type :' +ISNULL( @KPA_Type,'') 	
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='U' 
		BEGIN			
			SELECT @OLDCONTENT  =ISNULL(KPA_Type,'') FROM DBO.T0040_HRMS_KPAType_Master WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND KPA_Type_Id = @KPA_Type_Id		
			UPDATE    T0040_HRMS_KPAType_Master
			SET       KPA_Type = @KPA_Type
			WHERE     KPA_Type_Id = @KPA_Type_Id
			
			SET @OLDVALUE = 'old Value' + '#'+ 'KPA_Type :' + @OLDCONTENT  
            + 'New Value' + '#'+ 'KPA_Type :' +ISNULL(@KPA_Type,'')
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='D'
		BEGIN
			 SELECT @OLDCONTENT  =ISNULL(KPA_Type,'') FROM DBO.T0040_HRMS_KPAType_Master WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND KPA_Type_Id = @KPA_Type_Id		
				DELETE FROM T0040_HRMS_KPAType_Master WHERE KPA_Type_Id = @KPA_Type_Id					
			 set @OldValue = 'old Value' + '#'+ 'Content :' +ISNULL( @OldContent,'') 
		END
	EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRAN_TYPE,'KPA Type Master',@OLDVALUE,@KPA_Type_Id,@USER_ID,@IP_ADDRESS
END
