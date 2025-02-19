CREATE PROCEDURE [dbo].[FillKPA_PrevYears_One]
	  @cmp_id	 numeric(18,0)
	 ,@init_id numeric(18,0)
	 ,@init_date datetime 
	 ,@emp_id  numeric(18,0)
	 ,@type    int=1 --1 for self assessment and 2 for others
	 ,@flag   varchar(10)=''
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	declare @kpacount as int  = 0
	declare @finyear as int = 0
	declare @prevKpa as bit =0 
	declare @step1 as int = 0
	declare @Score_Using_Formula as int=0
	create table #prevkpa
	(
		prevkpa  int
	)
	
	select @kpacount= count (*) from T0052_HRMS_KPA WITH (NOLOCK) 
	left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId  
	where T0052_HRMS_KPA.Emp_Id=@emp_id	and T0052_HRMS_KPA.InitiateId = @init_id
	
	SELECT @Score_Using_Formula=isnull(Score_Using_Formula,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))<=@init_date
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id

	
	if  EXISTS(Select Mul_Range_ID from T0040_HRMS_Range_Multiplier WITH (NOLOCK) where cmp_id=@cmp_id and Mul_Effective_Date =
			   (select max(Effective_Date) from [T0050_AppraisalLimit_Setting] WITH (NOLOCK) where cmp_id=@cmp_id and 
				effective_date<= @init_date))
		BEGIN
			set @Score_Using_Formula=1
		END
	
	CREATE TABLE #EMP_GOALS
	(
	SrNo INT,
	Emp_KPA_Id INT,
	KPA_InitiateId INT,
	Emp_Id INT,
	KPA_Content VARCHAR(MAX),		
	EMP_Weightage FLOAT,
	RM_Weightage FLOAT,
	HOD_Weightage FLOAT,
	GH_Weightage FLOAT,
	EMP_REMARKS VARCHAR(MAX),
	RM_REMARKS VARCHAR(MAX),
	HOD_REMARKS VARCHAR(MAX),
	GH_REMARKS VARCHAR(MAX),
	IS_Active bit
	)
	DECLARE @Review_Type AS VARCHAR(25)
	IF @type=3
	BEGIN
		SELECT @Review_Type=Review_Type FROM T0055_Hrms_Initiate_KPASetting WHERE KPA_InitiateId=@init_id
		IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA where Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id AND Approval_Level='EMP' )--AND Approval_Level='EMP'
				BEGIN	
				print 'm'
					IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA where Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id AND Approval_Level=@flag)
						BEGIN	
							INSERT INTO #EMP_GOALS(SrNo,Emp_KPA_Id,KPA_InitiateId,Emp_Id,KPA_Content) 
							SELECT DISTINCT AE.SrNo,AE.Emp_KPA_Id,KPA_InitiateId,AE.Emp_Id,AE.KPA_Content
							FROM T0060_Appraisal_EmployeeKPA AE 
							LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
							WHERE AE.Cmp_Id=@cmp_id AND KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id AND Approval_Level=@flag
						END
					ELSE	
							BEGIN	
							INSERT INTO #EMP_GOALS(SrNo,Emp_KPA_Id,KPA_InitiateId,Emp_Id,KPA_Content) 
							SELECT DISTINCT AE.SrNo,AE.Emp_KPA_Id,KPA_InitiateId,AE.Emp_Id,AE.KPA_Content
							FROM T0060_Appraisal_EmployeeKPA AE 
							LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
							WHERE AE.Cmp_Id=@cmp_id AND KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id AND Approval_Level='Emp'
						END
				--SELECT * FROM #EMP_GOALS
					--UPDATE EG
					--SET PREV_Weightage=ISNULL(AE.KPA_Weightage,0)
					--FROM #EMP_GOALS EG
					--LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.SrNo=AE.SrNo 
					--WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId<@init_id and AE.Emp_Id = @emp_id AND AE.[status]=1
					
					UPDATE EG
					SET EMP_Weightage=ISNULL(AE.KPA_Weightage,0),EMP_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE				
					FROM #EMP_GOALS EG
					LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='Emp'
					WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
					UPDATE EG
					SET RM_Weightage=ISNULL(AE.KPA_Weightage,0),RM_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE					
					FROM #EMP_GOALS EG
					LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='RM'
					WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
					UPDATE EG
					SET HOD_Weightage=ISNULL(AE.KPA_Weightage,0),HOD_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE					
					FROM #EMP_GOALS EG
					LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='HOD'
					WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
					UPDATE EG
					SET GH_Weightage=ISNULL(AE.KPA_Weightage,0),GH_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE
					FROM #EMP_GOALS EG
					LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='GH'
					WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
					SELECT SrNo,Emp_KPA_Id,KPA_InitiateId,emp_id,KPA_Content,RM_Weightage,
					 ISNULL(EMP_Weightage,0)  as KPA_WEIGHTAGE,'' AS COMPLETION_DATE,IS_Active,
					1 AS IS_DISABLE,
					case when ISNULL(EMP_Weightage,0)=0 then ISNULL(RM_Weightage,0) else ISNULL(EMP_Weightage,0) end as EMP_Weightage,
					case when ISNULL(EMP_REMARKS,'')='' then ISNULL(RM_REMARKS,'') else ISNULL(EMP_REMARKS,'') end as EMP_REMARKS,	
					case when ISNULL(HOD_Weightage,0)=0 then RM_Weightage else HOD_Weightage end as HOD_Weightage1,
					case when ISNULL(HOD_REMARKS,'')='' then RM_REMARKS else HOD_REMARKS end as HOD_REMARKS1,
					CASE WHEN @FLAG='RM' THEN 
						 CASE WHEN ISNULL(RM_Weightage,0) =0 THEN EMP_Weightage ELSE RM_Weightage END 			
					WHEN @FLAG='HOD' THEN 
						 CASE WHEN ISNULL(HOD_Weightage,0) =0 THEN RM_Weightage ELSE HOD_Weightage END END AS FINAL_Weightage,
						 '' as kpa_type,0 as kpa_type_id,'' as KPA_Performace_Measure,'' as kpa_target
					FROM #EMP_GOALS
					RETURN
			END
		BEGIN 
		--select @init_id,333
			--IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA WHERE Emp_Id=@emp_id and KPA_InitiateId<@init_id AND [status]=1)
			--	BEGIN
			--	select 555
			--		SELECT DISTINCT 0 as Emp_KPA_Id,AE.KPA_InitiateId,AE.Emp_Id,B1.KPA_Content,1 AS IS_DISABLE ,Remarks AS EMP_Remarks,AE.Approval_Level,
			--			   B1.KPA_Weightage AS EMP_Weightage,IS_ACTIVE
			--		FROM T0060_Appraisal_EmployeeKPA AE 
			--		INNER JOIN 
			--			(SELECT MAX(Effective_Date)Effective_Date 
			--			 FROM T0060_Appraisal_EmployeeKPA 
			--			 WHERE Emp_Id=@emp_id and Effective_Date <= @init_date)B 
			--		ON B.Effective_Date = AE.Effective_Date
			--		INNER JOIN 
			--			(SELECT Emp_KPA_Id,KPA_Weightage,KPA_Content
			--			 FROM T0060_Appraisal_EmployeeKPA 
			--			 WHERE Emp_Id=@emp_id and KPA_InitiateId<@init_id AND [status]=1)B1 
			--		ON AE.Emp_KPA_Id = B1.Emp_KPA_Id			
			--		LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
			--		WHERE AE.Cmp_Id= @cmp_id and Emp_Id = @emp_id and AE.status=1 --AND AE.Approval_Level='EMP'
			--		RETURN
			--	END
			--ELSE
				BEGIN
				--select 777
					SELECT 0 AS Emp_KPA_Id,0 AS KPA_InitiateId,A.Emp_Id,A.KPA_Content,1 AS IS_DISABLE,'' AS EMP_Remarks
					,'EMP' AS Approval_Level,A.KPA_AchievementEmp AS EMP_Weightage,1 AS IS_ACTIVE
					FROM T0052_HRMS_KPA A INNER JOIN 
							(SELECT MAX(InitiateId)InitiateId 
							 FROM T0050_HRMS_InitiateAppraisal 
							 WHERE Emp_Id=@emp_id and 
									ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=2019)B 
						ON B.InitiateId = A.InitiateId 
						left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
					WHERE A.Emp_Id=@emp_id	
					RETURN			
				END
		END
END

	if @kpacount >0 
	begin	
		if @type= 1
			BEGIN
				if @Score_Using_Formula = 1
					BEGIN		
					print 'j'		
						select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,isnull(KPA_Weightage,0) as KPA_Weightage
						,ISNULL(KPA_Achievement,0) as Score,KPA_Critical as Criteria,
						KM.KPA_Type_Id,KM.KPA_Type ,Actual_Achievement,ISNULL(KPA_AchievementEmp,0) as KPA_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
						SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						from T0052_HRMS_KPA 
						left join T0050_HRMS_InitiateAppraisal on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId
						left join T0040_HRMS_KPAType_Master KM on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id  
						where T0052_HRMS_KPA.Emp_Id=@emp_id
						and T0052_HRMS_KPA.InitiateId = @init_id
					END
				
				else
					BEGIN	
					print 'r'	
						select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,isnull(KPA_Weightage,0) as KPA_Weightage
						,case when KPA_AchievementEmp is null then KPA_Achievement else KPA_AchievementEmp end as Score,KPA_Critical as Criteria,
						KM.KPA_Type_Id,KM.KPA_Type ,Actual_Achievement,KPA_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp, 
						SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						from T0052_HRMS_KPA 
						left join T0050_HRMS_InitiateAppraisal on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId
						left join T0040_HRMS_KPAType_Master KM on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id  
						where T0052_HRMS_KPA.Emp_Id=@emp_id
						and T0052_HRMS_KPA.InitiateId = @init_id
					END
			END
		ELSE
			BEGIN 	
			print 'mm'		
							select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,
							isnull(KPA_Weightage,0) as KPA_Weightage,							
							ISNULL(KPA_Achievement,0) as Score,KPA_Critical as Criteria ,ISNULL(KPA_AchievementEmp,0) KPA_AchievementEmp,
							case when ISNULL(RM_Comments,'') ='' then ISNULL(KPA_Critical,'') else RM_Comments end as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
							ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,							
							case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
							when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
							when ISNULL(KPA_Weightage,0) > 0 then ISNULL(KPA_Weightage,0) end as HOD_Weightage,
							
							case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
							when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
							when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Weightage,
							
							case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
							case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
							when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as HOD_Rating,
							
							case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
							when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
							when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Rating,
							
							ISNULL(KPA_AchievementRM,KPA_AchievementEmp)as KPA_AchievementRM,
							case when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
							when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0) 
							when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementHOD,
							
							case when ISNULL(KPA_AchievementGH,0) > 0 then ISNULL(KPA_AchievementGH,0)
							when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
							when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0)
							when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementGH,
							HOD_Comments,GH_Comments,KPA_Performace_Measure,
							
							ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
							case when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0) else ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_RM,
							
							case when ISNULL(Achievement_Percentage_HOD,0) > 0 then ISNULL(Achievement_Percentage_HOD,0)
							when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0) 
							when ISNULL(Achievement_Percentage_Emp,0) > 0 then ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_HOD,
							
							case when ISNULL(Achievement_Percentage_GH,0) > 0 then ISNULL(Achievement_Percentage_GH,0)
							when ISNULL(Achievement_Percentage_HOD,0) > 0 then ISNULL(Achievement_Percentage_HOD,0)
							when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0)
							when ISNULL(Achievement_Percentage_Emp,0) > 0 then ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_GH,
							ISNULL(SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])),'') AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						from T0052_HRMS_KPA 
							left join T0050_HRMS_InitiateAppraisal on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId  
							left join T0040_HRMS_KPAType_Master KM on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id
							where T0052_HRMS_KPA.Emp_Id=@emp_id
						and T0052_HRMS_KPA.InitiateId = @init_id
					END				
			
	End
ELSE
	BEGIN
	
		--check whether eval is of prev year is allowed
		INSERT INTO #prevkpa
			EXEC CheckMultiple_EvalAppraisal @cmp_id,@init_date,4

	
		SELECT @prevKpa = prevkpa from #prevkpa	  	
		SELECT	@finyear = Financial_Year from T0050_HRMS_InitiateAppraisal where InitiateId = @init_id	
		
		IF (@prevKpa = 1) --to take the KPA of prev year to next year
			BEGIN  --if eval is in same year,ie. whether eval if first in the year
				IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = @finyear)
					BEGIN 
						set @prevKpa=0  
							
						DELETE from #prevkpa						
						INSERT into #prevkpa
							EXEC CheckMultiple_EvalAppraisal @cmp_id,@init_date,1
						
						SELECT @prevKpa = prevkpa from #prevkpa	  
						IF @prevKpa =1 --check whether eval of same year allowed
							BEGIN
								IF @type= 1
									BEGIN
									print 'k'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,
												null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
												0 as KPA_Achievement ,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
								ELSE
									BEGIN
									print 'p'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,
												KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							 
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
							END
						Else
							BEGIN 
								SET @step1 = 1
							END	
					END
				Else
					BEGIN 
					PRINT @finyear
					PRINT @init_id
						IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = (@finyear-1))
							BEGIN
								IF @type= 1
									BEGIN
										print 's'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,
												null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
												0 as KPA_Achievement  ,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=(@finyear-1) )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
								ELSE
									BEGIN
										print 'aa'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,
												null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,
												KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
												ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,
												case when ISNULL(RM_Weightage,0)<>0 then ISNULL(HOD_Weightage,RM_Weightage) 
												when ISNULL(KPA_Achievement,0)<>0 then ISNULL(HOD_Weightage,KPA_Achievement) end as HOD_Weightage,
												case when ISNULL(HOD_Weightage,0)<>0 then ISNULL(GH_Weightage,HOD_Weightage)
												when ISNULL(RM_Weightage,0)<>0 then ISNULL(GH_Weightage,RM_Weightage)
												when ISNULL(KPA_Achievement,0)<>0 then ISNULL(GH_Weightage,KPA_Achievement) end	as GH_Weightage,
												ISNULL(RM_Rating,0)as RM_Rating,ISNULL(HOD_Rating,0) as HOD_Rating,ISNULL(GH_Rating,0) as GH_Rating ,
												ISNULL(KPA_AchievementHOD,0)KPA_AchievementHOD,ISNULL(KPA_AchievementGH,0)KPA_AchievementGH,KPA_Performace_Measure,
												ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date																			
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=(@finyear-1) )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
							END
						Else							
							SET @step1 = 1
					END
			END
		ELSE
			BEGIN  
		
				--SET @step1 = 1
				IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = @finyear)
					BEGIN
						set @prevKpa=0  
						
						DELETE from #prevkpa						
						INSERT into #prevkpa
							EXEC CheckMultiple_EvalAppraisal @cmp_id,@init_date,1
						SELECT @prevKpa = prevkpa from #prevkpa	  	
						IF @prevKpa =1 --check whether eval of same year allowed
							BEGIN
								IF @type= 1
									BEGIN
									PRINT 'd'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,
												KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,0 as KPA_Achievement,KPA_Performace_Measure,
												ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
								ELSE
									BEGIN
									print 'ss'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,null as KPA_AchievementEmp,null as KPA_AchievementRM,
												KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,KPA_Performace_Measure,
												ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal 
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
							END
						Else
							BEGIN 
								SET @step1 = 1
							END	
					END
				Else
					BEGIN 
						SET @step1 = 1
					END
			END
	END
	

set @kpacount = 0
IF @step1 = 1 
	begin	 --check if employee assigned any kpa	
		select @kpacount = count(*) FROM T0060_Appraisal_EmployeeKPA E left join 
					 T0050_HRMS_InitiateAppraisal I on I.Emp_Id = e.Emp_Id inner JOIN
					 (select isnull(max(effective_date),
							(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))effective_date,
							Emp_Id
						from T0060_Appraisal_EmployeeKPA 
						where Emp_Id=@emp_id
						GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
				WHERE e.emp_id =@emp_id and InitiateId = @init_id  and E.Effective_Date <= i.SA_Startdate and isnull(E.status,1)=1
	
		IF @kpacount >0
			BEGIN 
			
				if @type = 1
					begin		
					print 'mm'		
						select null as SApparisal_ID,Emp_KPA_Id as KPA_ID,kpa_content as KPA,kpa_target,
							   isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as score, '' as Criteria,
							   KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement,0 as KPA_Achievement,KPA_Performace_Measure,
							   0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
							   SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						FROM T0060_Appraisal_EmployeeKPA E left join 
							 T0050_HRMS_InitiateAppraisal I on I.Emp_Id = e.Emp_Id inner JOIN
							 (select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))effective_date,
									Emp_Id
								from T0060_Appraisal_EmployeeKPA 
								where Emp_Id=@emp_id
								GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
							left join T0040_HRMS_KPAType_Master KM on E.kpa_Type_ID=KM.KPA_Type_Id
						WHERE e.emp_id =@emp_id and InitiateId = @init_id  and E.Effective_Date <= i.SA_Startdate and isnull(E.status,1)=1
					end
				ELSE
					BEGIN	
					print 'b'	
						select null as SApparisal_ID,Emp_KPA_Id as KPA_ID,kpa_content as KPA,kpa_target,
							   isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as score, '' as Criteria,null as KPA_AchievementEmp,null as KPA_AchievementRM  
							   ,'' as RM_Comments,--Added By Mukti(23122016)field(RM_Comments) 
							   KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement ,KPA_Performace_Measure,
							   0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
							   SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date,
							   0 as RM_Rating,0 as RM_Weightage -- add by mayur modi 09-04-2019 for Wonder column not found in vb page Ess_PerformanceAssessment.aspx line no 2524														
						FROM T0060_Appraisal_EmployeeKPA E left join 
							 T0050_HRMS_InitiateAppraisal I on I.Emp_Id = e.Emp_Id inner JOIN
							 (select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))effective_date,
									Emp_Id
								from T0060_Appraisal_EmployeeKPA 
								where Emp_Id=@emp_id
								GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
						left join T0040_HRMS_KPAType_Master KM on E.kpa_Type_ID=KM.KPA_Type_Id
						WHERE e.emp_id =@emp_id and InitiateId = @init_id  and E.Effective_Date <= i.SA_Startdate and isnull(E.status,1)=1
					END
			END
		ELSE	
			BEGIN  --check if employee's designation assigned any kpa	
			
				IF @type = 1				
					BEGIN 
					print 'w'
					print @emp_id							
						select DISTINCT null as SApparisal_ID,KPA_id as KPA_ID,kpa_content as KPA, kpa_target,
							  isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as Score ,'' as Criteria,
							  KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement,0 as KPA_Achievement ,KPA_Performace_Measure,
							  0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
							  '' AS [file_name],'' as File_Name_ID,'' as Completion_Date							
						from T0051_KPA_Master e  cross join T0095_INCREMENT i left JOIN 
							  T0050_HRMS_InitiateAppraisal h on h.Emp_Id = i.Emp_ID  inner JOIN
							 (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID
							  FROM T0095_INCREMENT Inner JOIN 
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT 
										WHERE CMP_ID = @cmp_id 
										GROUP BY EMP_ID
									)inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 Where T0095_INCREMENT.emp_id=@emp_id)i1 on i1.INCREMENT_ID = i.Increment_ID inner JOIN
							 (
								select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))effective_date,
								Desig_Id,Dept_Id
								from T0051_KPA_Master 
								where Cmp_Id=@cmp_id
								GROUP by Desig_Id,Dept_Id
							 )e1 on e.Effective_Date = e1.effective_date
							 left join T0040_HRMS_KPAType_Master KM on E.kpa_Type_ID=KM.KPA_Type_Id
						where  i.Emp_ID = @emp_id  
						and e.Effective_Date <=h.SA_Startdate and e.Cmp_Id=@cmp_id
						/*and cast(i.desig_id as varchar(10)) in
						 (select Data from dbo.Split(isnull(e.desig_id,''),'#')) 
						 and  (cast(i.Dept_Id as varchar(10)) in 
						 (select Data from dbo.Split(isnull(e.dept_Id,''),'#')) 
						 or isnull(e.dept_Id,'')='') */
				 END
			ELSE
				BEGIN
				print 'ss'	
					select DISTINCT null as SApparisal_ID,KPA_id as KPA_ID,kpa_content as KPA, kpa_target,
							  isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as Score ,'' as Criteria ,null as KPA_AchievementEmp,null as KPA_AchievementRM
							  ,'' as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement, --Added By Mukti(19122016)field(RM_Comments) 
							   isnull(KPA_Weightage,0) as RM_Weightage, isnull(KPA_Weightage,0) as HOD_Weightage, isnull(KPA_Weightage,0) as GH_Weightage,
    						  0 as RM_Rating,0 as HOD_Rating,0 as GH_Rating,0 as KPA_AchievementHOD,0 as KPA_AchievementGH, KPA_Performace_Measure,
    						  0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
    						  '' AS [file_name],'' as File_Name_ID,'' as Completion_Date							
						from T0051_KPA_Master e  cross join T0095_INCREMENT i left JOIN 
							  T0050_HRMS_InitiateAppraisal h on h.Emp_Id = i.Emp_ID  inner JOIN
							 (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID
							  FROM T0095_INCREMENT Inner JOIN 
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT 
										WHERE CMP_ID = @cmp_id 
										GROUP BY EMP_ID
									)inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 Where T0095_INCREMENT.emp_id=@emp_id)i1 on i1.INCREMENT_ID = i.Increment_ID inner JOIN
							 (
								select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_id))effective_date,
								Desig_Id,Dept_Id
								from T0051_KPA_Master 
								where Cmp_Id=@cmp_id
								GROUP by Desig_Id,Dept_Id
							 )e1 on e.Effective_Date = e1.effective_date
							 left join T0040_HRMS_KPAType_Master KM on E.kpa_Type_ID=KM.KPA_Type_Id
						where  i.Emp_ID = @emp_id  and e.Effective_Date <=h.SA_Startdate
						and cast(i.desig_id as varchar(10)) in
						 (select Data from dbo.Split(isnull(e.desig_id,''),'#')) 
						 and  (cast(i.Dept_Id as varchar(10)) in 
						 (select Data from dbo.Split(isnull(e.dept_Id,''),'#')) 
						 or isnull(e.dept_Id,'')='') and e.Cmp_Id=@cmp_id
				END	
			END
	END


drop table #prevkpa
	
END
