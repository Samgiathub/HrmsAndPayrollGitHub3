
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Appraisal_Calculation_Slab_Get]
	 @Initiate_Id	numeric(18,0)
	,@SA_StartDate	datetime
	,@cmp_id	numeric(18,0)
	,@flag varchar(10)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	CREATE TABLE #SA_Score	
	(
		initiate_Id		NUMERIC(18,0)
		,emp_Score		NUMERIC(18,2)
		,manager_score  NUMERIC(18,2)
		,Weightage		NUMERIC(18,2)
	)
	
	CREATE TABLE #KPA_Score	
	(
		initiate_Id		NUMERIC(18,0)
		,emp_Score		NUMERIC(18,2)
		,manager_score  NUMERIC(18,2)	
		
	)
	
	declare @sa_subcriteria as int
	DECLARE @Self_Assessment_With_Answer as INT
	
	SELECT @sa_subcriteria = isnull(SA_SubCriteria,0),@Self_Assessment_With_Answer = isnull(Self_Assessment_With_Answer,0)
	FROM T0050_AppraisalLimit_Setting WITH (NOLOCK) INNER JOIN
		 (
			SELECT max(Effective_Date)Effective_Date
			FROM T0050_AppraisalLimit_Setting WITH (NOLOCK)
			where Cmp_ID = @cmp_id
		 )T on T.Effective_Date = T0050_AppraisalLimit_Setting.Effective_Date
	WHERE  Cmp_ID = @cmp_id
	
	if @Self_Assessment_With_Answer = 1	
		BEGIN
			IF @sa_subcriteria = 1
				BEGIN
					INSERT INTO #SA_Score
					SELECT DISTINCT InitiateId,Emp_Score,Manager_Score,Weightage				
					FROM T0052_Emp_SelfAppraisal WITH (NOLOCK)
					WHERE  InitiateId = @Initiate_Id
					GROUP by  InitiateId,SAppraisal_ID,Emp_Score,Manager_Score,Weightage
				END
			ELSE
				BEGIN		
					INSERT INTO #SA_Score		
					SELECT  InitiateId,Emp_Score,Manager_Score,Weightage				
					FROM T0052_Emp_SelfAppraisal WITH (NOLOCK)
					WHERE  InitiateId = @Initiate_Id
					--GROUP by  InitiateId,SAppraisal_ID,Emp_Score,Manager_Score,Weightage
				END		
		END
	ELSE
		BEGIN	
			INSERT INTO #SA_Score			
			SELECT  InitiateId,Final_Emp_Score,
			CASE when @flag='RM' then
				case when ISNULL(Final_RM_Score,0)>0 then ISNULL(Final_RM_Score,0) else ISNULL(Final_Emp_Score,0)end
			when @flag='HOD' THEN 
				case when ISNULL(Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0) 
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end
			when @flag='GH' then 
				case when ISNULL(Final_GH_Score,0) > 0 then ISNULL(Final_GH_Score,0)
				when ISNULL(Final_HOD_Score,0) > 0 then ISNULL(Final_HOD_Score,0)
				when ISNULL(Final_RM_Score,0) > 0 then ISNULL(Final_RM_Score,0)
				when ISNULL(Final_Emp_Score,0) > 0 then ISNULL(Final_Emp_Score,0) end
			end,
			Emp_Weightage 	
						
			FROM T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK)
			WHERE  InitiateId = @Initiate_Id
			--GROUP by  InitiateId,SAppraisal_ID,Emp_Score,Manager_Score,Weightage
		END		
	
			INSERT INTO #KPA_Score			
			SELECT  InitiateId,KPA_AchievementEmp,
			CASE when @flag='RM' then
					case when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0)
					when ISNULL(KPA_AchievementRM,0) = 0 then ISNULL(KPA_AchievementEmp,0)	end					
				when @flag='HOD' THEN 
					case when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
					when ISNULL(KPA_AchievementHOD,0) = 0 and ISNULL(KPA_AchievementRM,0)> 0 then ISNULL(KPA_AchievementRM,0)
					when ISNULL(KPA_AchievementHOD,0) = 0 and ISNULL(KPA_AchievementRM,0)= 0 then ISNULL(KPA_AchievementEmp,0) end
				when @flag='GH' then 
					case when ISNULL(KPA_AchievementGH,0) > 0 then ISNULL(KPA_AchievementGH,0)
					when ISNULL(KPA_AchievementGH,0) = 0 and ISNULL(KPA_AchievementHOD,0)> 0 then ISNULL(KPA_AchievementHOD,0)
					when ISNULL(KPA_AchievementGH,0) = 0 and ISNULL(KPA_AchievementHOD,0)= 0 and ISNULL(KPA_AchievementRM,0)> 0
					then ISNULL(KPA_AchievementRM,0) else KPA_AchievementEmp end
			end
			FROM T0052_HRMS_KPA WITH (NOLOCK)
			WHERE  InitiateId = @Initiate_Id
			--	select * from #KPA_Score
SELECT DISTINCT I.Emp_Id,I.KPA_Final,I.PO_Final,I.PF_Final,EKPA_Weightage,EKPA_RestrictWeightage,
SA_Weightage,SA_RestrictWeightage,PA_Weightage,PoA_Weightage,
 CASE WHEN AE.EKPA_RestrictWeightage = 0 THEN CAST(AE.EKPA_Weightage AS VARCHAR)+' % of ' + CAST(KPA.KPAScore as VARCHAR) +'='+ cast(cast(KPA.KPAScore*(AE.EKPA_Weightage/100) as NUMERIC(18,2)) AS VARCHAR) ELSE cast(KPA.KPAScore as VARCHAR) END displayKPA
,CASE WHEN AE.PoA_Weightage <> 0 THEN CAST(AE.PoA_Weightage as VARCHAR) + '% of ' + CAST(I.PO_Final as VARCHAR) +'='+ cast(cast(I.PO_Final*(AE.PoA_Weightage/100) as NUMERIC(18,2))as VARCHAR) ELSE '0' END display_PoA
,CASE WHEN AE.PA_Weightage <> 0 THEN  CAST(AE.PA_Weightage as VARCHAR) + '% of ' + CAST(I.PF_Final as VARCHAR) +'='+  cast(cast(I.PF_Final*(AE.PA_Weightage/100) as NUMERIC(18,2))as VARCHAR) ELSE '0' END display_PF
,CASE WHEN AE.SA_RestrictWeightage = 0 THEN  CAST(AE.SA_Weightage AS VARCHAR)+' % of ' + CAST(SI.SAScore as VARCHAR) +'='+  cast(cast(SAScore*(AE.SA_Weightage/100) AS NUMERIC(18,2)) AS VARCHAR) ELSE cast(SAScore as varchar) END displaySAScore 
FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) INNER JOIN
      T0060_Appraisal_EmpWeightage AE WITH (NOLOCK)  ON I.Emp_Id = AE.Emp_Id INNER JOIN
      (
		SELECT MAX(Effective_Date)Effective_Date,Emp_Id
		FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK)
		WHERE Effective_Date <= @SA_StartDate
		GROUP by Emp_Id
      )AE1 on AE.Emp_Id = AE1.Emp_Id and AE.Effective_Date = ae1.Effective_Date LEFT JOIN
      (
		SELECT initiate_Id,
				CASE WHEN SUM(manager_score) =0 and SUM(emp_Score)=0 THEN
					 SUM(Weightage)
					 WHEN SUM(manager_score) = 0 and SUM(emp_Score)<>0  THEN
					 SUM(emp_Score)
					 ELSE
						SUM(manager_score) END SAScore
		FROM #SA_Score
		GROUP by initiate_Id
	) SI on SI.initiate_Id = I.InitiateId LEFT JOIN
	(
		SELECT initiate_Id,
				CASE WHEN SUM(manager_score) = 0 and SUM(emp_Score)<>0  
				THEN SUM(emp_Score)
			    ELSE SUM(manager_score) END KPAScore
		FROM #KPA_Score
		GROUP by initiate_Id
	) KPA on KPA.initiate_Id = I.InitiateId
WHERE I.InitiateId = @Initiate_Id
	
	
	DROP TABLE #SA_Score
END

