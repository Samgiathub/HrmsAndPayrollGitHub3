
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_Apprisal]
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@SEmp_ID numeric(18,0),
	@Dept_ID numeric(18,0),
	@Initiate_ID numeric(18,0),
	@Details xml,
	@Type char(1),
	@Result varchar(max) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @SAppraisalID numeric(18,0)
DECLARE @Answer varchar(50)
DECLARE @SelfRate numeric(18,0)

DECLARE @PAID numeric(18,0)
DECLARE @AttrScore numeric(18,0)

DECLARE @OAID numeric(18,0)
DECLARE @OAAnswer varchar(50)

DECLARE @SelfApp_ID numeric(18,0)
DECLARE @Emp_Attr_ID numeric(18,0)
DECLARE @Emp_OA_ID numeric(18,0)


IF @Type = 'I'
	BEGIN
		SELECT Table1.value('(SAppraisal_ID/text())[1]','numeric(18,0)') AS SAppraisalID,
		Table1.value('(Answer/text())[1]','varchar(50)') AS Answer,
		Table1.value('(SelfRate/text())[1]','numeric(18,0)') AS SelfRate
		INTO #SelfRate FROM @Details.nodes('/NewDataSet/SelfRate') as Temp(Table1)
		
		SELECT Table1.value('(PA_ID/text())[1]','numeric(18,0)') AS PAID,
		Table1.value('(Attr_Score/text())[1]','numeric(18,0)') AS AttrScore
		INTO #SkillRate FROM @Details.nodes('/NewDataSet/SkillRate') as Temp(Table1)
		
		SELECT Table1.value('(OA_ID/text())[1]','numeric(18,0)') AS OAID,
		Table1.value('(OA_Answer/text())[1]','varchar(50)') AS OAAnswer
		INTO #Other FROM @Details.nodes('/NewDataSet/Other') as Temp(Table1)
		
		
		SELECT @SelfApp_ID = ISNULL(MAX(SelfApp_ID),0) FROM T0052_Mobile_Emp_SelfAppraisal WITH (NOLOCK)
		
		INSERT INTO T0052_Mobile_Emp_SelfAppraisal--(SelfApp_ID,Initiate_ID,Emp_ID,Cmp_ID,SAppraisal_ID,Answer,SelfRate,SEmp_ID) 
		SELECT (@SelfApp_ID + ROW_NUMBER() OVER (Order by SAppraisalID)),@Initiate_ID,@Emp_ID,@Cmp_ID,
		SAppraisalID,Answer,SelfRate ,@SEmp_ID FROM #SelfRate
		
		--SELECT * FROM T0052_Mobile_Emp_SelfAppraisal
		
		
		SELECT @Emp_Attr_ID = ISNULL(MAX(Emp_Attr_ID),0) FROM T0052_Mobile_HRMS_AttributeFeedback WITH (NOLOCK)
		
		INSERT INTO T0052_Mobile_HRMS_AttributeFeedback
		SELECT (@Emp_Attr_ID + ROW_NUMBER() OVER (Order by PAID)),@Initiate_ID,@Emp_ID,@SEmp_ID,@Cmp_ID,
		PAID,AttrScore FROM #SkillRate
		
		--SELECT * FROM T0052_Mobile_HRMS_AttributeFeedback
		
		
		SELECT @Emp_OA_ID = ISNULL(MAX(Emp_OA_ID),0) FROM T0050_MObile_HRMS_EmpOA_Feedback WITH (NOLOCK)
		
		INSERT INTO T0050_MObile_HRMS_EmpOA_Feedback
		SELECT (@Emp_OA_ID + ROW_NUMBER() OVER (Order by OAID)),@Initiate_ID,@Emp_ID,@SEmp_ID,@Cmp_ID,
		OAID,OAAnswer FROM #Other
		
		--SELECT * FROM T0050_MObile_HRMS_EmpOA_Feedback
		
		SET @Result = 'Record Insert Successfully'
		
		
		
		--DECLARE SELFRATE_CURSOR CURSOR FAST_FORWARD FOR
		--SELECT SAppraisalID,Answer,SelfRate FROM #SelfRate
		--OPEN SELFRATE_CURSOR
		--FETCH NEXT FROM SELFRATE_CURSOR INTO @SAppraisalID,@Answer,@SelfRate
		--WHILE @@FETCH_STATUS = 0
		--	BEGIN
		--		SELECT @SelfApp_ID = ISNULL(MAX(SelfApp_ID),0) + 1 FROM T0052_Mobile_Emp_SelfAppraisal
				
		--		INSERT INTO T0052_Mobile_Emp_SelfAppraisal(SelfApp_ID,Initiate_ID,Emp_ID,Cmp_ID,SAppraisal_ID,Answer,SelfRate,SEmp_ID) 
		--		VALUES(@SelfApp_ID,@Initiate_ID,@Emp_ID,@Cmp_ID,@SAppraisalID,@Answer,@SelfRate,@SEmp_ID)
				
		--	FETCH NEXT FROM SELFRATE_CURSOR INTO @SAppraisalID,@Answer,@SelfRate
		--	END
		--CLOSE SELFRATE_CURSOR     
		--DEALLOCATE SELFRATE_CURSOR
		
		--DECLARE SKILLRATE_CURSOR CURSOR FAST_FORWARD FOR
		--SELECT PAID,AttrScore FROM #SkillRate
		--OPEN SKILLRATE_CURSOR
		--FETCH NEXT FROM SKILLRATE_CURSOR INTO @PAID,@AttrScore
		--WHILE @@FETCH_STATUS = 0
		--	BEGIN
				
		--		SELECT @Emp_Attr_ID = ISNULL(MAX(Emp_Attr_ID),0) + 1 FROM T0052_Mobile_HRMS_AttributeFeedback
			
		--	FETCH NEXT FROM SKILLRATE_CURSOR INTO @PAID,@AttrScore
		--	END
		--CLOSE SKILLRATE_CURSOR     
		--DEALLOCATE SKILLRATE_CURSOR
		
		--DECLARE OTHER_CURSOR CURSOR FAST_FORWARD FOR
		--SELECT OAID,OAAnswer FROM #Other
		--OPEN OTHER_CURSOR
		--FETCH NEXT FROM OTHER_CURSOR INTO @OAID,@OAAnswer
		--WHILE @@FETCH_STATUS = 0
		--	BEGIN
			
		--		SELECT @Emp_OA_ID = ISNULL(MAX(Emp_OA_ID),0) + 1  FROM T0050_MObile_HRMS_EmpOA_Feedback

			
		--	FETCH NEXT FROM OTHER_CURSOR INTO @OAID,@OAAnswer
		--	END
		--CLOSE OTHER_CURSOR     
		--DEALLOCATE OTHER_CURSOR
		
		
		--SELECT * FROM #SelfRate
		--SELECT * FROM #SkillRate
		--SELECT * FROM #Other
		
		
		--SELECT * FROM T0040_HRMS_AttributeMaster
	END
ELSE IF @Type = 'S'
	BEGIN
	
		SELECT @Dept_ID = Dept_ID FROM V0080_Employee_Master WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
	
	
		SELECT SApparisal_ID,SApparisal_Content,SAppraisal_Sort,SDept_Id,SIsMandatory,SType,
		SUBSTRING(SApparisal_Content,0,CHARINDEX(' ',SApparisal_Content)) AS 'Apparisal_Code'
		FROM T0040_SelfAppraisal_Master WITH (NOLOCK) 
		WHERE @Dept_ID IN (SELECT Data FROM dbo.Split(SDept_Id,'#'))
		ORDER BY SAppraisal_Sort
		
		SELECT *  
		FROM T0040_HRMS_AttributeMaster WITH (NOLOCK)
		ORDER BY PA_SortNo
	
		SELECT Range_ID,Range_Level 
		FROM T0040_HRMS_RangeMaster WITH (NOLOCK)
		ORDER BY Range_AchievementId DESC
		
		
		SELECT * 
		FROM T0040_HRMS_OtherAssessment_Master WITH (NOLOCK)
		ORDER BY OA_Sort
		
	END

