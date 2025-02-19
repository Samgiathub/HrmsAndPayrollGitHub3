

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0050_CopyAppraisalSettings]
	 @Cmp_Id				numeric(18,0)
	,@CopyEffective_Date	datetime
	,@NewEffective_Date		datetime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	--1st table Achievement	
	
	declare @Achievement_Level  varchar(50)
	declare @Achievement_Sort  int
	declare @Achievement_Type  int
		DECLARE @AchievementId  NUMERIC(18,0)	
	DECLARE cur CURSOR
	for 
		Select Achievement_Level,Achievement_Sort,Achievement_Type  FROM T0040_Achievement_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	OPEN cur		
		FETCH next from cur into @Achievement_Level,@Achievement_Sort,@Achievement_Type
		WHILE @@fetch_status =0 
			BEGIN			
				SELECT @AchievementId =isnull(max(AchievementId),0)+1 from T0040_Achievement_Master WITH (NOLOCK)
				INSERT	INTO T0040_Achievement_Master (AchievementId,Cmp_ID,Achievement_Level,Achievement_Sort,Achievement_Type,Effective_Date) 
				VALUES(@AchievementId,@Cmp_Id,@Achievement_Level,@Achievement_Sort,@Achievement_Type,@NewEffective_Date)
								
				FETCH next from cur into @Achievement_Level,@Achievement_Sort,@Achievement_Type
			END
	CLOSE cur
	DEALLOCATE cur
	
		
	--2nd table range master
	DECLARE @Range_ID  NUMERIC(18,0)
	DECLARE @Range_PID  NUMERIC(18,0)
		
	set @AchievementId = null	
	declare @achivement_Name  varchar(50)
	declare @achivement_Type INT
	
	DECLARE cur CURSOR
	FOR 
		SELECT AchievementId,Achievement_Level,Achievement_Type from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) = @NewEffective_Date
	OPEN cur
		FETCH NEXT FROM cur INTO @AchievementId,@achivement_Name,@achivement_Type
		WHILE @@fetch_status = 0
			BEGIN
				SELECT @Range_ID = isnull(max(Range_ID),0) FROM T0040_HRMS_RangeMaster WITH (NOLOCK)
				SELECT @Range_PID = isnull(max(Range_PID),0) FROM T0040_HRMS_RangeMaster WITH (NOLOCK) WHERE  cmp_id=@cmp_id
				
				SELECT	@Range_ID + ROW_NUMBER() OVER(ORDER BY RANGE_ID),@Cmp_Id,Range_From,Range_To,Range_Type,Range_Level,Range_Dept,Range_Grade,
						@Range_PID + ROW_NUMBER() OVER(ORDER BY RANGE_ID),
					   --RPID.Range_PID,
				       Range_Percent_Allocate,@AchievementId,@NewEffective_Date
				FROM T0040_HRMS_RangeMaster WITH (NOLOCK)

				INSERT INTO T0040_HRMS_RangeMaster (Range_ID,Cmp_ID,Range_From,Range_To,Range_Type,Range_Level,Range_Dept,Range_Grade,Range_PID
													,Range_Percent_Allocate,Range_AchievementId,Effective_Date)
				SELECT	@Range_ID + ROW_NUMBER() OVER(ORDER BY RANGE_ID),@Cmp_Id,Range_From,Range_To,Range_Type,Range_Level,Range_Dept,Range_Grade,
						@Range_PID + ROW_NUMBER() OVER(ORDER BY RANGE_ID),
					   --RPID.Range_PID,
				       Range_Percent_Allocate,@AchievementId,@NewEffective_Date
				FROM T0040_HRMS_RangeMaster WITH (NOLOCK)
				-- INNER JOIN
				--(
				--	SELECT (isnull(max(Range_ID),0)+1 )Range_ID
				--	FROM T0040_HRMS_RangeMaster 
				--)RID on rid.Range_ID = T0040_HRMS_RangeMaster.Range_ID INNER JOIN
				--(
				--	SELECT (isnull(max(Range_PID),0)+1)Range_PID,Cmp_ID FROM T0040_HRMS_RangeMaster 
				--	WHERE  cmp_id=@cmp_id
				--	GROUP by Cmp_ID	
				--)RPID on RPID.Cmp_ID = T0040_HRMS_RangeMaster.Cmp_ID
				WHERE T0040_HRMS_RangeMaster.Cmp_ID = @Cmp_Id and 
				isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id))	= @CopyEffective_Date
				and Range_Level = @achivement_Name and Range_Type=@achivement_Type 
					
				FETCH NEXT FROM cur INTO @AchievementId,@achivement_Name,@achivement_Type
			END	
	CLOSE cur
	DEALLOCATE cur
	
	--3rd table range dept allocation 
	declare @oldrange_id as numeric(18,0)
	declare @newrange_id as numeric(18,0)
	declare @RangeDept_ID as numeric(18,0)
	declare @deptid as numeric(18,0)
	
	DECLARE cur CURSOR
	FOR 
		select R1.range_id, r2.Range_ID
		from T0040_HRMS_RangeMaster R1 WITH (NOLOCK) left JOIN
		T0040_HRMS_RangeMaster R2 WITH (NOLOCK) on r2.Range_Level = R1.Range_Level
		 where R1.Cmp_ID=@Cmp_Id  and r1.Range_Type=2 and r2.Range_Type=2
		 and isnull(r1.Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@NewEffective_Date and isnull(r2.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id))=@CopyEffective_Date
		and r2.Cmp_ID = @Cmp_Id
	OPEN cur	
		FETCH NEXT FROM cur INTO @newrange_id,@oldrange_id
		WHILE @@fetch_status = 0
			BEGIN				
				DECLARE cur1 CURSOR
				FOR 
					SELECT Dept_ID from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
					WHERE Cmp_ID=@Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date
					and Range_ID = @oldrange_id		
				open cur1
					FETCH NEXT FROM cur1 INTO @deptid
					WHILE @@fetch_status = 0
						BEGIN	
							SELECT @RangeDept_ID = isnull(max(RangeDept_ID),0)+1 FROM T0050_HRMS_RangeDept_Allocation WITH (NOLOCK) 				
							
							INSERT INTO T0050_HRMS_RangeDept_Allocation 
							select @RangeDept_ID + ROW_NUMBER() OVER(ORDER BY RangeDept_ID),Cmp_ID,@newrange_id,Range_Type,Dept_ID,Percent_Allocate,@NewEffective_Date
							from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
							where Cmp_ID=@Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date
							and Range_ID = @oldrange_id	and Dept_ID = @deptid	
							
							FETCH NEXT FROM cur1 INTO @deptid
						END
				close cur1
				DEALLOCATE cur1	
								
				FETCH NEXT FROM cur INTO @newrange_id,@oldrange_id
			END
		close cur
	DEALLOCATE cur
	
	--4th table limit settings
	DECLARE @Limit_Id numeric(18,0) 
	SELECT @Limit_Id = isnull(max(Limit_Id),0)+1 FROM T0050_AppraisalLimit_Setting WITH (NOLOCK)				
	INSERT INTO T0050_AppraisalLimit_Setting
	(Limit_Id,Cmp_ID,ScoreLimit_KPA,ScoreLimit_PA,ScoreLimit_PoA,RecommendLimit_Skill,RecommendLimit_GM,
	JoiningDate_Limit,KPA_Limit,KpaMaster_Yes,KPA_Default,KPA_Score,KPA_AllowEmp,SA_SubCriteria,OA_ViewByManager,
	KPA_AllowEmpScore_Display,KPA_AllowRMScore_Display,KPA_Percentage,KPA_PerScore,KPA_AllowAddKPA,
	Emp_AssessApprove_days,Emp_PA_Approve_RM_days,PA_HOD_Days,PA_GH_Days,Multiple_Evaluation,Interim_EvaluationBy,Interim_DisplayTab,Display_PreviousKPA,Display_PreviousKPAYear,Effective_Date)
	Select @Limit_Id +  ROW_NUMBER() OVER (ORDER BY Limit_Id),Cmp_ID,
			ScoreLimit_KPA,ScoreLimit_PA,ScoreLimit_PoA,RecommendLimit_Skill,RecommendLimit_GM,
			JoiningDate_Limit,KPA_Limit,KpaMaster_Yes,KPA_Default,KPA_Score,KPA_AllowEmp,SA_SubCriteria,OA_ViewByManager,
			KPA_AllowEmpScore_Display,KPA_AllowRMScore_Display,KPA_Percentage,KPA_PerScore,KPA_AllowAddKPA,
			Emp_AssessApprove_days,Emp_PA_Approve_RM_days,PA_HOD_Days,PA_GH_Days,Multiple_Evaluation,Interim_EvaluationBy,Interim_DisplayTab,Display_PreviousKPA,Display_PreviousKPAYear,@NewEffective_Date
	from T0050_AppraisalLimit_Setting WITH (NOLOCK)
	Where Cmp_ID = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	
	--5th table Emp Weightage
	declare @Emp_Id as numeric(18,0)
	declare @EKPA_Weightage as numeric(18,0)
	declare @SA_Weightage as numeric(18,0)
	declare @Emp_Weightage_Id as numeric(18,0)
	
		
	--DECLARE cur CURSOR
	--FOR 
	--	SELECT Emp_Id,EKPA_Weightage,SA_Weightage from T0060_Appraisal_EmpWeightage
	--	WHERE Cmp_Id  = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	--open cur
	--	fetch next from cur into @Emp_Id,@EKPA_Weightage,@SA_Weightage
	--	WHILE @@fetch_status = 0
	--		BEGIN
	--			(SELECT @Emp_Weightage_Id=isnull(max(Emp_Weightage_Id),0)+1 from T0060_Appraisal_EmpWeightage )
	--				print @Emp_Weightage_Id
	--			--INSERT INTO T0060_Appraisal_EmpWeightage
	--			--(Emp_Weightage_Id,Cmp_Id,Emp_Id,EKPA_Weightage,SA_Weightage,Effective_Date)
	--			--values(@Emp_Weightage_Id,@Cmp_Id,@Emp_Id,@EKPA_Weightage,@SA_Weightage,@NewEffective_Date)
				
	--			fetch next from cur into @Emp_Id,@EKPA_Weightage,@SA_Weightage
	--		END
	--close cur
	--DEALLOCATE cur
	
	declare @pkempwt as NUMERIC(18,0)
	 SELECT @pkempwt =isnull(max(Emp_Weightage_Id),0) from T0060_Appraisal_EmpWeightage WITH (NOLOCK) 
	 --print @pkempwt
	INSERT INTO T0060_Appraisal_EmpWeightage
	(Emp_Weightage_Id,Cmp_Id,Emp_Id,EKPA_Weightage,SA_Weightage,Effective_Date)
	SELECT @pkempwt + ROW_NUMBER() OVER(ORDER BY Emp_Weightage_Id),Cmp_Id,Emp_Id,EKPA_Weightage,SA_Weightage,@NewEffective_Date
	from T0060_Appraisal_EmpWeightage WITH (NOLOCK)
	where Cmp_Id  = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	
	set @pkempwt =null
	--6th table Desig Weightage
	
	
	
	declare @Desig_ID as numeric(18,0)
	set @SA_Weightage = NULL
	set @EKPA_Weightage= null
	declare @Desig_weightage_Id numeric(18,0)
	
	SELECT @Desig_weightage_Id=isnull(max(Desig_weightage_Id),0)+1 from T0060_Appraisal_DesigWeightage WITH (NOLOCK)
	INSERT INTO T0060_Appraisal_DesigWeightage
	(Desig_weightage_Id,Cmp_ID,Desig_ID,EKPA_Weightage,SA_Weightage,Effective_Date,PA_Weightage,PoA_Weightage,EKPA_RestrictWeightage,SA_RestrictWeightage)
	SELECT @Desig_weightage_Id + ROW_NUMBER() OVER(ORDER BY Desig_weightage_Id),Cmp_Id,Desig_ID,EKPA_Weightage,SA_Weightage,@NewEffective_Date,PA_Weightage,PoA_Weightage,EKPA_RestrictWeightage,SA_RestrictWeightage
	from T0060_Appraisal_DesigWeightage WITH (NOLOCK)
	where Cmp_Id  = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	
	--DECLARE cur CURSOR
	--FOR 
	--	SELECT Desig_ID,EKPA_Weightage,SA_Weightage from T0060_Appraisal_DesigWeightage
	--	WHERE Cmp_Id  = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	--open cur
	--	fetch next from cur into @Desig_ID,@EKPA_Weightage,@SA_Weightage
	--	WHILE @@fetch_status = 0
	--		BEGIN
				
			
	--			INSERT INTO T0060_Appraisal_DesigWeightage
	--			(Desig_weightage_Id,Cmp_Id,Desig_ID,EKPA_Weightage,SA_Weightage,Effective_Date)
	--			values((@Desig_weightage_Id + ROW_NUMBER() OVER (ORDER BY Desig_weightage_Id)) ,@Cmp_Id,@Desig_ID,@EKPA_Weightage,@SA_Weightage,@NewEffective_Date)
				
	--			fetch next from cur into @Desig_ID,@EKPA_Weightage,@SA_Weightage
	--		END
	--close cur
	--DEALLOCATE cur
	
	
	--7th table Assessment View
	set @Emp_Id =null
	declare @SA_View as numeric(18,0)
	declare @KPA_View as numeric(18,0)
	declare @Emp_AssessmentView_Id as numeric(18,0)
	
	SELECT @Emp_AssessmentView_Id=isnull(max(Emp_AssessmentView_Id),0)+1 from T0060_Emp_Assessment_View WITH (NOLOCK) 
	INSERT INTO T0060_Emp_Assessment_View
				(Emp_AssessmentView_Id,Cmp_Id,Emp_Id,SA_View,KPA_View,Effective_Date)
	SELECT @Emp_AssessmentView_Id + ROW_NUMBER() OVER (ORDER BY Emp_AssessmentView_Id),Cmp_Id,Emp_Id,SA_View,KPA_View,@NewEffective_Date
	FROM T0060_Emp_Assessment_View WITH (NOLOCK)
	
	
	--DECLARE cur CURSOR
	--FOR 
	--	SELECT Emp_Id,SA_View,KPA_View from T0060_Emp_Assessment_View
	--	WHERE Cmp_Id  = @Cmp_Id and isnull(Effective_Date,(select from_date from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id)) =@CopyEffective_Date 
	--open cur
	--	fetch next from cur into @Emp_Id,@SA_View,@KPA_View
	--	WHILE @@fetch_status = 0
	--		BEGIN
	--			SELECT @Emp_AssessmentView_Id=isnull(max(Emp_AssessmentView_Id),0)+1 from T0060_Emp_Assessment_View 
			
	--			INSERT INTO T0060_Emp_Assessment_View
	--			(Emp_AssessmentView_Id,Cmp_Id,Emp_Id,SA_View,KPA_View,Effective_Date)
	--			values(@Emp_AssessmentView_Id + ROW_NUMBER() OVER (ORDER BY Emp_AssessmentView_Id),@Cmp_Id,@Emp_Id,@SA_View,@KPA_View,@NewEffective_Date)
				
	--			fetch next from cur into @Emp_Id,@SA_View,@KPA_View
	--		END
	--close cur
	--DEALLOCATE cur
	
END
-------------------------

