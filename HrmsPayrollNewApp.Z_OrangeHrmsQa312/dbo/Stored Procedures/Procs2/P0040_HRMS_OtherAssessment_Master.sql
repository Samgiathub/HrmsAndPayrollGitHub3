﻿


-- =============================================
-- AUTHOR:		<AUTHOR,,NAME>
-- CREATE DATE: <CREATE DATE,,>
-- DESCRIPTION:	<DESCRIPTION,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_OtherAssessment_Master]
	@OA_ID			NUMERIC(18) OUTPUT  
   ,@CMP_ID			NUMERIC(18)   
   ,@OA_TITLE		NVARCHAR(100)  
   ,@OA_SORT		INT       
   ,@TRAN_TYPE		VARCHAR(1) 
   ,@USER_ID		NUMERIC(18,0) = 0
   ,@IP_ADDRESS		VARCHAR(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 DECLARE @OLDVALUE AS VARCHAR(MAX)
	 DECLARE @OLDCONTENT AS NVARCHAR(100)
	 DECLARE @OLDSORT AS VARCHAR(18)
	 
	 SET @OLDVALUE = ''
	 SET @OLDCONTENT = ''
	 SET @OLDSORT =''
	 
	  IF UPPER(@TRAN_TYPE) ='I' OR UPPER(@TRAN_TYPE) ='U'
		BEGIN
			IF @OA_TITLE = ''
				BEGIN				
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0040_HRMS_OTHERASSESSMENT_MASTER WITH (NOLOCK) WHERE OA_SORT=@OA_SORT AND OA_ID<>@OA_ID AND CMP_ID=@CMP_ID)
				BEGIN
					SET @OA_ID = 0 						
					RETURN
				END		
			IF EXISTS(SELECT 1 FROM T0040_HRMS_OTHERASSESSMENT_MASTER WITH (NOLOCK) WHERE OA_TITLE=@OA_TITLE AND OA_ID<>@OA_ID AND CMP_ID=@CMP_ID)
				BEGIN
					SET @OA_ID = 0 						
					RETURN
				END		
		END
	 IF UPPER(@TRAN_TYPE) ='I'
		BEGIN
			SELECT @OA_ID = ISNULL(MAX(OA_ID),0) + 1 FROM T0040_HRMS_OTHERASSESSMENT_MASTER WITH (NOLOCK)
			INSERT INTO T0040_HRMS_OTHERASSESSMENT_MASTER(OA_ID,CMP_ID,OA_TITLE,OA_SORT)
			VALUES(@OA_ID,@CMP_ID,@OA_TITLE,@OA_SORT)	
			SET @OLDVALUE = 'New Value' + '#'+ 'Content :' +ISNULL( @OA_Title,'') + '#' + 'Sort :' +  CAST(ISNULL( @OA_Sort,'')AS varchar(18)) + '#'	
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='U' 
		BEGIN			
			SELECT @OLDCONTENT  =ISNULL(OA_TITLE,''),@OLDSORT=CAST(ISNULL(OA_SORT,'')AS VARCHAR(18))  FROM DBO.T0040_HRMS_OTHERASSESSMENT_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND OA_ID = @OA_ID		
			UPDATE    T0040_HRMS_OTHERASSESSMENT_MASTER
			SET       OA_TITLE = @OA_TITLE,
					  OA_SORT = @OA_SORT
			WHERE     OA_ID = @OA_ID
			
			SET @OLDVALUE = 'old Value' + '#'+ 'Content :' + @OLDCONTENT  + '#' +  'Sort :' + @OLDSORT  + '#' +
            + 'New Value' + '#'+ 'Content :' +ISNULL( @OA_TITLE,'') + '#' + 'Sort :' + CAST(ISNULL( @OA_SORT,'')as varchar(18)) + '#'		
		END
	ELSE IF  UPPER(@TRAN_TYPE) ='D'
		BEGIN
			 SELECT @OLDCONTENT  =ISNULL(OA_TITLE,''),@OLDSORT=CAST(ISNULL(OA_SORT,'')AS VARCHAR(18))  FROM DBO.T0040_HRMS_OTHERASSESSMENT_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND OA_ID = @OA_ID		
				DELETE FROM T0040_HRMS_OTHERASSESSMENT_MASTER WHERE OA_ID = @OA_ID					
			 set @OldValue = 'old Value' + '#'+ 'Content :' +ISNULL( @OldContent,'') + '#' 	+ 'Sort :' + CAST(ISNULL( @oldsort,'')as varchar(18)) + '#' 			 
		END
	EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRAN_TYPE,'Other Assessment Master',@OLDVALUE,@OA_ID,@USER_ID,@IP_ADDRESS
END

