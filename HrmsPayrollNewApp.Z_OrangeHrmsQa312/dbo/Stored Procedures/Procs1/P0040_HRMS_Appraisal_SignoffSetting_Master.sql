

-- =============================================
-- AUTHOR:		<RIPAL PATEL>
-- ALTER DATE: <20-FEB-2013>
-- @SETTING_TYPE = 1 (GOAL DEFINITION)
-- @SETTING_TYPE = 2 (REVIEW GOAL)
-- @SETTING_TYPE = 3 (REVIEW PERFORMANCE SUMMARY)
-- @SETTING_TYPE = 4 (REVIEW SOL)
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_HRMS_Appraisal_SignoffSetting_Master]
	@SETTING_ID			NUMERIC(18,0) OUTPUT,
	@SETTING_CMPID		NUMERIC(18,0),
	@SETTING_EMPID		NUMERIC(18,0),
	@SETTING_TYPE		NUMERIC(18,0),
	@SETTING_YEAR		NUMERIC(18,0),
	@SETTING_FROMDATE	DATETIME,
	@SETTING_TODATE		DATETIME,
	@TRAN_TYPE			VARCHAR(1),
	@USER_ID			NUMERIC(18,0),
	@RESULT				NUMERIC(18,0) OUTPUT
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
	IF @TRAN_TYPE = 'I'
		BEGIN
			SELECT @SETTING_ID = ISNULL(MAX(SETTING_ID),0)+1 FROM T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER WITH (NOLOCK)
			
			--if @Setting_Type = 1
			--begin
			--	if exists(select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master 
			--			  where Setting_EmpId = @Setting_EmpId and Setting_Type = @Setting_Type and Setting_Year = @Setting_Year)
			--	begin
			--		set @Result = 1
			--		return
			--	end
			--end
			
			--if exists(select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master
			--				where Setting_EmpId = @Setting_EmpId and Setting_Year = @Setting_Year and Setting_Type = @Setting_Type and Setting_Type <> 1
			--					  and Setting_ToDate >= @Setting_FromDate)
			--begin
			--	set @Result = 2
			--	return
			--end
			
			INSERT INTO T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER
					   (SETTING_ID
					   ,SETTING_CMPID
					   ,SETTING_EMPID
					   ,SETTING_TYPE
					   ,SETTING_YEAR
					   ,SETTING_FROMDATE
					   ,SETTING_TODATE
					   ,SETTING_CREATEDBY
					   ,SETTING_CREATEDDATE)
				 VALUES
					   (@SETTING_ID
					   ,@SETTING_CMPID
					   ,@SETTING_EMPID
					   ,@SETTING_TYPE
					   ,@SETTING_YEAR
					   ,@SETTING_FROMDATE
					   ,@SETTING_TODATE
					   ,@USER_ID
					   ,GETDATE())
		END
	ELSE IF @TRAN_TYPE = 'U'
		BEGIN
		
			--if @Setting_Type = 1
			--begin
			--	if exists(select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master 
			--				  where Setting_EmpId = @Setting_EmpId and Setting_Type = 1 and Setting_Year = @Setting_Year  and Setting_Id <> @Setting_Id)
			--	begin
			--		set @Result = 1
			--		return
			--	end
			--end
			--if exists(select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master 
			--				   where Setting_Id = @Setting_Id and Setting_FromDate <= GETDATE() AND GETDATE() <= Setting_ToDate)
			--begin
			--	set @Result = 3
			--	return
			--end
			--if exists(select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master
			--				where Setting_EmpId = @Setting_EmpId and Setting_Year = @Setting_Year  and Setting_Type = @Setting_Type  and Setting_Type <> 1
			--					  and Setting_ToDate >= @Setting_FromDate and Setting_Id <> @Setting_Id)
			--begin
			--	set @Result = 2
			--	return
			--end
			
			UPDATE T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER
			   SET SETTING_FROMDATE = @SETTING_FROMDATE
				  ,SETTING_TODATE = @SETTING_TODATE
				  ,SETTING_MODIFYBY = @USER_ID
				  ,SETTING_MODIFYDATE = GETDATE()
			 WHERE SETTING_ID = @SETTING_ID
		END
	ELSE IF @TRAN_TYPE = 'D'
		BEGIN
		
			--select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master 
			--				   where Setting_Id = @Setting_Id and Setting_FromDate <= GETDATE() AND GETDATE() <= Setting_ToDate
			--select 1 from T0040_HRMS_Appraisal_SignoffSetting_Master 
			--				   where Setting_Id = @Setting_Id and convert(date,GETDATE()) between  convert(date,Setting_FromDate) AND convert(date,Setting_ToDate)
			
			--Edit on 14Dec2013 Ripal 06Dec2013
			IF EXISTS(SELECT 1 FROM T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER WITH (NOLOCK)
							   WHERE SETTING_ID = @SETTING_ID AND REPLACE(CONVERT(NVARCHAR, GETDATE(), 106), ' ', '-') BETWEEN  SETTING_FROMDATE AND SETTING_TODATE) /*01MAY2013 BY RIPAL PATEL*/
				BEGIN
					SET @RESULT = 3
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_GOAL WITH (NOLOCK) INNER JOIN T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER WITH (NOLOCK)
									ON SETTING_EMPID = FK_EMPLOYEEID AND SETTING_YEAR = GOAL_YEAR AND SETTING_TYPE = 1 
									WHERE SETTING_ID = @SETTING_ID)
				BEGIN
					SET @RESULT = 1
					RETURN
				END
			IF EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_GOALREVIEW WITH (NOLOCK) WHERE FK_SETTINGID = @SETTING_ID) OR
			   EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_SOLASSESSMENTDTL WITH (NOLOCK) WHERE FK_SETTINGID = @SETTING_ID) OR
			   EXISTS(SELECT 1 FROM T0090_HRMS_APPRAISAL_EMP_PERFSUMMREVIEW WITH (NOLOCK) WHERE FK_SETTINGID = @SETTING_ID)
				BEGIN
					SET @RESULT = 1
					RETURN
				END
			DELETE FROM T0040_HRMS_APPRAISAL_SIGNOFFSETTING_MASTER
				   WHERE SETTING_ID = @SETTING_ID
		END
END



