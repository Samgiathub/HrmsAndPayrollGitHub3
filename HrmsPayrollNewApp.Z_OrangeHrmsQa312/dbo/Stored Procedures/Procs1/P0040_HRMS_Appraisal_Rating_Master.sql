﻿

-- =============================================
-- AUTHOR:		<RIPAL PATEL>
-- ALTER DATE: <24-DEC-2012>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_Appraisal_Rating_Master]
	@RATING_ID			NUMERIC(18,0) OUTPUT,
	@RATING_CMPID		NUMERIC(18,0),
	@RATING				VARCHAR(50),
	@RATING_ISACTIVE	TINYINT,
	@TRAN_TYPE			VARCHAR(1),
	@USER_ID			NUMERIC(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	IF @TRAN_TYPE ='I'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0040_HRMS_APPRAISAL_RATING_MASTER WITH (NOLOCK)
									WHERE RATING = @RATING AND RATING_CMPID = @RATING_CMPID)
			BEGIN
			    SET	@RATING_ID = 0
				RETURN
			END
				SELECT @RATING_ID = ISNULL(MAX(RATING_ID),0)+1 FROM T0040_HRMS_APPRAISAL_RATING_MASTER WITH (NOLOCK)
				INSERT INTO T0040_HRMS_APPRAISAL_RATING_MASTER
						   (RATING_ID
						   ,RATING_CMPID
						   ,RATING
						   ,RATING_ISACTIVE
						   ,RATING_CREATEDBY
						   ,RATING_CREATEDDATE)
					 VALUES
						   (@RATING_ID
						   ,@RATING_CMPID
						   ,@RATING
						   ,@RATING_ISACTIVE
						   ,@USER_ID
						   ,GETDATE())		   
		END
	ELSE IF @TRAN_TYPE ='U'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0040_HRMS_APPRAISAL_RATING_MASTER WITH (NOLOCK)
									WHERE RATING = @RATING AND RATING_CMPID = @RATING_CMPID AND RATING_ID <> @RATING_ID)
			BEGIN
			    SET	@RATING_ID = 0
				RETURN
			END
			UPDATE T0040_HRMS_APPRAISAL_RATING_MASTER
			   SET RATING = @RATING
				  ,RATING_ISACTIVE = @RATING_ISACTIVE
				  ,RATING_MODIFYBY = @USER_ID
				  ,RATING_MODIFYDATE = GETDATE()
			 WHERE RATING_ID = @RATING_ID AND RATING_CMPID = @RATING_CMPID
		END
	ELSE IF @TRAN_TYPE ='D'
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_GOALREVIEW WITH (NOLOCK) WHERE FK_RATING = @RATING_ID)
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_PERFSUMMREVIEW WITH (NOLOCK) WHERE FK_RATINGID = @RATING_ID)
						BEGIN
							IF NOT EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_SOLASSESSMENTDTL WITH (NOLOCK) WHERE FK_RATING_EMP = @RATING_ID OR FK_RATING_SUP = @RATING_ID)
								BEGIN
									DELETE FROM T0040_HRMS_APPRAISAL_RATING_MASTER
									WHERE RATING_ID = @RATING_ID AND RATING_CMPID = @RATING_CMPID
								END
							ELSE
								BEGIN
									SET	@RATING_ID = 0
									RETURN
								END
						END
					ELSE
						BEGIN
							SET	@RATING_ID = 0
							RETURN
						END
				END
			ELSE
				BEGIN
					SET	@RATING_ID = 0
					RETURN
				END
		END
END



