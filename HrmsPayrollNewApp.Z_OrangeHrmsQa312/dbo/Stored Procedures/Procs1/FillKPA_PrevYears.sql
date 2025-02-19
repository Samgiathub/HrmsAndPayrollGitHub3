
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[FillKPA_PrevYears]
	  @cmp_id	 numeric(18,0)
	 ,@init_id numeric(18,0)
	 ,@init_date datetime 
	 ,@emp_id  numeric(18,0)
	 ,@type    int=1 --1 for self assessment and 2 for others
	 ,@flag   varchar(10)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @kpacount as int  = 0
	declare @finyear as int = 0
	declare @prevKpa as bit =0 
	declare @step1 as int = 0
	declare @Score_Using_Formula as int=0
	create table #prevkpa
	(
		prevkpa  int
	)
	
	select @kpacount= count (*) from T0052_HRMS_KPA WITH (NOLOCK) left join 
	T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId  
	where T0052_HRMS_KPA.Emp_Id=@emp_id
	and T0052_HRMS_KPA.InitiateId = @init_id
	
	SELECT @Score_Using_Formula=isnull(Score_Using_Formula,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@init_date
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
	KPA_Type_ID_EMP INT,
	KPA_Type_ID_RM INT,
	KPA_Type_ID_HOD INT,
	KPA_Type_ID_GH INT,
	KPA_Content_EMP VARCHAR(MAX),	
	KPA_Content_RM VARCHAR(MAX),	
	KPA_Content_HOD VARCHAR(MAX),	
	KPA_Content_GH VARCHAR(MAX),	
	KPA_Performace_Measure_EMP VARCHAR(MAX),	
	KPA_Performace_Measure_RM VARCHAR(MAX),
	KPA_Performace_Measure_HOD VARCHAR(MAX),
	KPA_Performace_Measure_GH VARCHAR(MAX),
	KPA_Target_EMP VARCHAR(MAX),	
	KPA_Target_RM VARCHAR(MAX),
	KPA_Target_HOD VARCHAR(MAX),
	KPA_Target_GH VARCHAR(MAX),
	EMP_Weightage INT,
	RM_Weightage INT,
	HOD_Weightage INT,
	GH_Weightage INT,
	EMP_REMARKS VARCHAR(MAX),
	RM_REMARKS VARCHAR(MAX),
	HOD_REMARKS VARCHAR(MAX),
	GH_REMARKS VARCHAR(MAX),
	Completion_Date_EMP DATETIME,
	Completion_Date_RM DATETIME,
	Completion_Date_HOD DATETIME,
	Completion_Date_GH DATETIME,
	File_Name_EMP VARCHAR(MAX),
	File_Name_RM VARCHAR(MAX),
	File_Name_HOD VARCHAR(MAX),
	File_Name_GH VARCHAR(MAX),
	File_Name_ID_EMP VARCHAR(MAX),
	File_Name_ID_RM VARCHAR(MAX),
	File_Name_ID_HOD VARCHAR(MAX),
	File_Name_ID_GH VARCHAR(MAX),
	IS_Active bit,
	KPA_Type varchar(200),
	EFFECTIVE_DATE VARCHAR(15)
	)
	
	DECLARE @Review_Type AS VARCHAR(25)
	DECLARE @Approval_Level AS VARCHAR(15)
	
	IF @type=3
		BEGIN
			SELECT @Review_Type=Review_Type FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE KPA_InitiateId=@init_id

			IF (@flag <>'') AND EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK) WHERE Emp_Id=@emp_id and KPA_InitiateId= @init_id AND Approval_Level=@flag)
				SET @Approval_Level=@flag
			ELSE
				BEGIN	
				
					SELECT @Approval_Level=Approval_Level
					FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
					INNER JOIN 
						(SELECT MAX(Emp_KPA_Id)Emp_KPA_Id 
						 FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
						 WHERE Emp_Id=@emp_id and KPA_InitiateId= @init_id)B 
					ON B.Emp_KPA_Id = AE.Emp_KPA_Id
					WHERE Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id 
				END
				
					SELECT AE.*,KM.KPA_Type,SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID
					FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
					LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM WITH (NOLOCK) ON AE.kpa_type_id=km.KPA_Type_Id 
					WHERE AE.Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id  AND Approval_Level=isnull(@Approval_Level,Approval_Level)
				
			RETURN
		END
		--SELECT MAX() FROM T0060_Appraisal_EmployeeKPA where Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id
		--IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA where Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id AND Approval_Level='EMP')
		--		BEGIN	
		--		print 'm'
		--			IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA where Cmp_Id= @cmp_id and Emp_Id = @emp_id and KPA_InitiateId=@init_id AND Approval_Level=@flag)
		--				BEGIN	
		--					INSERT INTO #EMP_GOALS(SrNo,Emp_KPA_Id,KPA_InitiateId,Emp_Id,EFFECTIVE_DATE) 
		--					SELECT DISTINCT AE.SrNo,AE.Emp_KPA_Id,KPA_InitiateId,AE.Emp_Id,convert(varchar(15),AE.Effective_Date,103)
		--					FROM T0060_Appraisal_EmployeeKPA AE 
		--					LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
		--					WHERE AE.Cmp_Id=@cmp_id AND KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id AND Approval_Level=@flag
		--				END
		--			ELSE	
		--					BEGIN	
		--					INSERT INTO #EMP_GOALS(SrNo,Emp_KPA_Id,KPA_InitiateId,Emp_Id,EFFECTIVE_DATE) 
		--					SELECT DISTINCT AE.SrNo,AE.Emp_KPA_Id,KPA_InitiateId,AE.Emp_Id,CONVERT(varchar(15),AE.Effective_Date,103)
		--					FROM T0060_Appraisal_EmployeeKPA AE 
		--					LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
		--					WHERE AE.Cmp_Id=@cmp_id AND KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id AND Approval_Level='Emp'
		--				END
		--		--SELECT * FROM #EMP_GOALS
		--			--UPDATE EG
		--			--SET PREV_Weightage=ISNULL(AE.KPA_Weightage,0)
		--			--FROM #EMP_GOALS EG
		--			--LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.SrNo=AE.SrNo 
		--			--WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId<@init_id and AE.Emp_Id = @emp_id AND AE.[status]=1
					
		--			UPDATE EG
		--			SET EMP_Weightage=ISNULL(AE.KPA_Weightage,0),
		--				KPA_Content_EMP=AE.KPA_Content,
		--				KPA_Type_ID_EMP=AE.KPA_Type_ID,
		--				KPA_Performace_Measure_EMP=AE.KPA_Performace_Measure,
		--				KPA_Target_EMP=AE.KPA_Target,Completion_Date_EMP=AE.Completion_Date,
		--				File_Name_EMP=AE.Attach_Docs,
		--				EMP_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE,
		--				KPA_Type=EG.KPA_Type						
		--			FROM #EMP_GOALS EG
		--			LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='Emp'
		--			LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=KM.KPA_Type_Id
		--			WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
		--			UPDATE EG
		--			SET RM_Weightage=ISNULL(AE.KPA_Weightage,0),
		--				KPA_Content_RM=AE.KPA_Content,KPA_Type_ID_RM=AE.KPA_Type_ID,
		--				KPA_Performace_Measure_RM=AE.KPA_Performace_Measure,
		--				KPA_Target_RM=AE.KPA_Target,Completion_Date_RM=AE.Completion_Date,
		--				File_Name_RM=AE.Attach_Docs,
		--				RM_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE,
		--				KPA_Type=EG.KPA_Type						
		--			FROM #EMP_GOALS EG
		--			LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='RM'
		--			LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=KM.KPA_Type_Id
		--			WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
		--			UPDATE EG
		--			SET HOD_Weightage=ISNULL(AE.KPA_Weightage,0),
		--				KPA_Content_HOD=AE.KPA_Content,KPA_Type_ID_HOD=AE.KPA_Type_ID,
		--				KPA_Performace_Measure_HOD=AE.KPA_Performace_Measure,
		--				KPA_Target_HOD=AE.KPA_Target,Completion_Date_HOD=AE.Completion_Date,
		--				File_Name_HOD=AE.Attach_Docs,
		--				HOD_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE,
		--				KPA_Type=EG.KPA_Type	
		--			FROM #EMP_GOALS EG
		--			LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='HOD'
		--			LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=KM.KPA_Type_Id
		--			WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
					
		--			UPDATE EG
		--			SET GH_Weightage=ISNULL(AE.KPA_Weightage,0),
		--				KPA_Content_GH=AE.KPA_Content,KPA_Type_ID_GH=AE.KPA_Type_ID,
		--				KPA_Performace_Measure_GH=AE.KPA_Performace_Measure,
		--				KPA_Target_GH=AE.KPA_Target,Completion_Date_GH=AE.Completion_Date,
		--				File_Name_GH=AE.Attach_Docs,
		--				GH_REMARKS=AE.Remarks,IS_Active=AE.IS_ACTIVE,
		--				KPA_Type=EG.KPA_Type
		--			FROM #EMP_GOALS EG
		--			LEFT JOIN T0060_Appraisal_EmployeeKPA AE ON EG.Emp_KPA_Id=AE.Emp_KPA_Id AND AE.KPA_InitiateId=EG.KPA_InitiateId AND Approval_Level='GH'
		--			LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=KM.KPA_Type_Id
		--			WHERE AE.Cmp_Id=@cmp_id AND AE.KPA_InitiateId=@init_id and AE.Emp_Id = @emp_id 
		--			select * from #EMP_GOALS
		--			SELECT *,1 AS IS_DISABLE,
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(RM_REMARKS,'') <>'' THEN RM_REMARKS ELSE EMP_REMARKS END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(HOD_REMARKS,'') <>'' THEN HOD_REMARKS ELSE RM_REMARKS END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(GH_REMARKS,'') <>'' THEN GH_REMARKS ELSE ISNULL(HOD_REMARKS,RM_REMARKS) END END AS LW_REMARKS,
							 
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(KPA_Type_ID_RM,0) >0 THEN ISNULL(KPA_Type_ID_RM,'') ELSE ISNULL(KPA_Type_ID_EMP,'') END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(KPA_Type_ID_HOD,0) >0 THEN ISNULL(KPA_Type_ID_HOD,'') ELSE ISNULL(KPA_Type_ID_RM,'') END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(KPA_Type_ID_GH,0) >0 THEN ISNULL(KPA_Type_ID_GH,'') ELSE ISNULL(KPA_Type_ID_HOD,'') END END AS LW_KPA_Type_ID,					
							 
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(KPA_Content_RM,'') <>'' THEN KPA_Content_RM ELSE KPA_Content_EMP END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(KPA_Content_HOD,'') <>'' THEN KPA_Content_HOD ELSE KPA_Content_RM END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(KPA_Content_GH,'') <>'' THEN KPA_Content_GH ELSE ISNULL(KPA_Content_HOD,KPA_Content_RM) END END AS LW_KPA_Content,
							 
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(KPA_Performace_Measure_RM,'') <>'' THEN KPA_Performace_Measure_RM ELSE KPA_Performace_Measure_EMP END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(KPA_Performace_Measure_HOD,'') <>'' THEN KPA_Performace_Measure_HOD ELSE KPA_Performace_Measure_RM END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(KPA_Performace_Measure_GH,'') <>'' THEN KPA_Performace_Measure_GH ELSE ISNULL(KPA_Performace_Measure_HOD,KPA_Performace_Measure_RM) END END AS LW_KPA_Performace_Measure,
							 
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(KPA_Target_RM,'') <>'' THEN KPA_Target_RM ELSE KPA_Target_EMP END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(KPA_Target_HOD,'') <>'' THEN KPA_Target_HOD ELSE KPA_Target_RM END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(KPA_Target_GH,'') <>'' THEN KPA_Target_GH ELSE ISNULL(KPA_Target_HOD,KPA_Target_RM) END END AS LW_KPA_Target,
						
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(RM_Weightage,0) >0 THEN RM_Weightage ELSE EMP_Weightage END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(HOD_Weightage,0) >0 THEN HOD_Weightage ELSE RM_Weightage END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(GH_Weightage,0) >0 THEN GH_Weightage ELSE ISNULL(HOD_Weightage,RM_Weightage) END END AS LW_Weightage,
							 
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(File_Name_RM,0) <>'' THEN File_Name_RM ELSE File_Name_EMP END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(File_Name_HOD,0) <>'' THEN File_Name_HOD ELSE File_Name_RM END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(File_Name_GH,0) <>'' THEN File_Name_GH ELSE ISNULL(File_Name_HOD,File_Name_RM) END END AS LW_File_Name,
							 
	 -- 				   CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(File_Name_ID_RM,0) <>'' THEN ISNULL(File_Name_ID_RM,'') ELSE ISNULL(File_Name_ID_EMP,'') END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(File_Name_ID_HOD,0) <>'' THEN ISNULL(File_Name_ID_HOD,'') ELSE ISNULL(File_Name_ID_RM,'') END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(File_Name_ID_GH,0) <>'' THEN ISNULL(File_Name_ID_GH,'') ELSE ISNULL(File_Name_ID_HOD,File_Name_ID_RM) END END AS LW_File_Name_ID,
						
		--				CASE WHEN @FLAG='RM' THEN 
		--					 CASE WHEN ISNULL(Completion_Date_RM,0) <>'' THEN Completion_Date_RM ELSE Completion_Date_EMP END 					
		--				WHEN @FLAG='HOD' THEN 
		--					 CASE WHEN ISNULL(Completion_Date_HOD,0) <>'' THEN Completion_Date_HOD ELSE Completion_Date_RM END
		--				WHEN @FLAG='GH' THEN 
		--					 CASE WHEN ISNULL(Completion_Date_GH,0) <>'' THEN Completion_Date_GH ELSE ISNULL(Completion_Date_HOD,Completion_Date_RM) END END AS LW_Completion_Date									
		--			FROM #EMP_GOALS
		--			RETURN
			--END	
		--BEGIN 
		----select @init_id,333
		--		SELECT DISTINCT AE.Emp_KPA_Id,AE.KPA_InitiateId,AE.Emp_Id,B1.KPA_Content AS KPA_Content_EMP,1 AS IS_DISABLE ,'' AS EMP_Remarks,AE.Approval_Level,
		--			   B1.KPA_Weightage AS EMP_Weightage,IS_ACTIVE,AE.KPA_Type_ID as KPA_Type_ID_EMP,
		--			   AE.KPA_Performace_Measure AS KPA_Performace_Measure_EMP,AE.KPA_Target AS KPA_Target_EMP,
		--			   Completion_Date AS Completion_Date_EMP,AE.Attach_Docs AS [File_Name_EMP],'' AS File_Name_ID_EMP
		--		FROM T0060_Appraisal_EmployeeKPA AE 
		--		INNER JOIN 
		--			(SELECT MAX(Effective_Date)Effective_Date 
		--			 FROM T0060_Appraisal_EmployeeKPA 
		--			 WHERE Emp_Id=@emp_id and Effective_Date <= @init_date)B 
		--		ON B.Effective_Date = AE.Effective_Date
		--		INNER JOIN 
		--			(SELECT srno,KPA_Weightage,KPA_Content
		--			 FROM T0060_Appraisal_EmployeeKPA 
		--			 WHERE Emp_Id=@emp_id and KPA_InitiateId<@init_id AND [status]=1)B1 
		--		ON AE.srno = B1.srno			
		--		LEFT OUTER JOIN T0040_HRMS_KPAType_Master KM ON AE.kpa_type_id=km.KPA_Type_Id 
		--		WHERE AE.Cmp_Id= @cmp_id and Emp_Id = @emp_id and AE.status=1 --AND AE.Approval_Level='EMP'
		--		RETURN
		--	END
		--ELSE
		--		BEGIN
		--			SELECT 0 AS Emp_KPA_Id,0 AS KPA_InitiateId,A.Emp_Id,A.KPA_Content,1 AS IS_DISABLE,'' AS EMP_Remarks
		--			,'EMP' AS Approval_Level,A.KPA_AchievementEmp AS EMP_Weightage,1 AS IS_ACTIVE
		--			FROM T0052_HRMS_KPA A INNER JOIN 
		--					(SELECT MAX(InitiateId)InitiateId 
		--					 FROM T0050_HRMS_InitiateAppraisal 
		--					 WHERE Emp_Id=@emp_id and 
		--							ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=2019)B 
		--				ON B.InitiateId = A.InitiateId 
		--				left join T0040_HRMS_KPAType_Master KM on A.kpa_Type_ID=KM.KPA_Type_Id
		--			WHERE A.Emp_Id=@emp_id	
		--			RETURN			
		--		END
--END

	if @kpacount >0 
	begin	
		if @type= 1
			BEGIN
				if @Score_Using_Formula = 1
					BEGIN		
					print 'j'		
						select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,isnull(KPA_Weightage,0) as KPA_Weightage
						,ISNULL(KPA_Achievement,0) as Score,KPA_Critical as Criteria, ISNULL(RM_Comments,'') as RM_Comments,
						KM.KPA_Type_Id,KM.KPA_Type ,Actual_Achievement,ISNULL(KPA_AchievementEmp,0) as KPA_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
						SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						from T0052_HRMS_KPA WITH (NOLOCK)
						left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId
						left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id  
						where T0052_HRMS_KPA.Emp_Id=@emp_id
						and T0052_HRMS_KPA.InitiateId = @init_id
					END
				
				else
					BEGIN	
					print 'r'	
						select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,isnull(KPA_Weightage,0) as KPA_Weightage
						,case when KPA_AchievementEmp is null then KPA_Achievement else KPA_AchievementEmp end as Score,KPA_Critical as Criteria,
						 ISNULL(RM_Comments,'') as RM_Comments,
						KM.KPA_Type_Id,KM.KPA_Type ,Actual_Achievement,KPA_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp, 
						SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						from T0052_HRMS_KPA WITH (NOLOCK)
						left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId
						left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id  
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
							--case when ISNULL(RM_Comments,'') ='' then ISNULL(KPA_Critical,'') else RM_Comments end as RM_Comments, -- Commented by Deepali 24052023
							 ISNULL(RM_Comments,'') as RM_Comments,  -- Added by Deepali 24052023
						
							KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
							ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,	
							
							case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
							when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
							when ISNULL(KPA_Weightage,0) > 0 then ISNULL(KPA_Weightage,0) ELSE ISNULL(KPA_Weightage,0) end as HOD_Weightage,
							
							case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
							when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
							when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) ELSE ISNULL(KPA_Achievement,0) end as GH_Weightage,
							
							case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
							case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
							when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) ELSE ISNULL(KPA_Achievement,0) end as HOD_Rating,
							
							case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
							when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
							when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
							when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) ELSE ISNULL(KPA_Achievement,0) end as GH_Rating,
							
							ISNULL(KPA_AchievementRM,KPA_AchievementEmp)as KPA_AchievementRM,
							case when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
							when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0) 
							when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) ELSE ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementHOD,
							
							case when ISNULL(KPA_AchievementGH,0) > 0 then ISNULL(KPA_AchievementGH,0)
							when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
							when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0)
							when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) ELSE ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementGH,

							HOD_Comments,GH_Comments,KPA_Performace_Measure,
							
							ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
							case when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0) else ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_RM,
							
							case when ISNULL(Achievement_Percentage_HOD,0) > 0 then ISNULL(Achievement_Percentage_HOD,0)
							when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0) 
							when ISNULL(Achievement_Percentage_Emp,0) > 0 then ISNULL(Achievement_Percentage_Emp,0) ELSE ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_HOD,
							
							case when ISNULL(Achievement_Percentage_GH,0) > 0 then ISNULL(Achievement_Percentage_GH,0)
							when ISNULL(Achievement_Percentage_HOD,0) > 0 then ISNULL(Achievement_Percentage_HOD,0)
							when ISNULL(Achievement_Percentage_RM,0) > 0 then ISNULL(Achievement_Percentage_RM,0)
							when ISNULL(Achievement_Percentage_Emp,0) > 0 then ISNULL(Achievement_Percentage_Emp,0) ELSE ISNULL(Achievement_Percentage_Emp,0) end as Achievement_Percentage_GH,
							ISNULL(SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])),'') AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,
							 	Completion_Date	,
							T0050_HRMS_InitiateAppraisal.KPA_Final	
						from T0052_HRMS_KPA WITH (NOLOCK)
							left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId  
							left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id
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
		SELECT	@finyear = Financial_Year from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where InitiateId = @init_id	
		
		IF (@prevKpa = 1) --to take the KPA of prev year to next year
			BEGIN  --if eval is in same year,ie. whether eval if first in the year
				IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = @finyear)
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
												null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,
												0 as KPA_Achievement ,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												'' as Actual_Achievement,'' AS [file_name],'' as File_Name_ID,'' as Completion_Date							
												--Actual_Achievement,SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
										WHERE A.Emp_Id=@emp_id
									END
								ELSE
									BEGIN
									print 'p'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,
												KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							 
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
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
						IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = (@finyear-1))
							BEGIN
								IF @type= 1
									BEGIN
										print 's'
										SELECT null as SApparisal_ID,0 as KPA_ID,kpa_content as KPA,kpa_target,
												ISNULL(KPA_Weightage,0) as KPA_Weightage,0 as Score,'' as Criteria,
												null as KPA_AchievementEmp,null as KPA_AchievementRM,'' as RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
												0 as KPA_Achievement  ,KPA_Performace_Measure,ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=(@finyear-1) )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
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
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=(@finyear-1) )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
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
				IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Emp_Id = @emp_id and InitiateId<@init_id and Financial_Year = @finyear)
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
												KM.KPA_Type_Id,KM.KPA_Type,0 as KPA_Achievement,KPA_Performace_Measure,
												ISNULL(Achievement_Percentage_Emp,0)Achievement_Percentage_Emp,
												--SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
												'' as Actual_Achievement,'' AS [file_name],'' as File_Name_ID,'' as Completion_Date							
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
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
										FROM T0052_HRMS_KPA A WITH (NOLOCK) INNER JOIN 
												(SELECT MAX(InitiateId)InitiateId 
												 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
												 WHERE Emp_Id=@emp_id and InitiateId<@init_id and 
														ISNULL(Financial_Year,DATEPART(YYYY,GETDATE()))=@finyear )B 
											ON B.InitiateId = A.InitiateId 
											left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on A.kpa_Type_ID=KM.KPA_Type_Id
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
		select @kpacount = count(*) FROM T0060_Appraisal_EmployeeKPA E WITH (NOLOCK) left join 
					 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = e.Emp_Id inner JOIN
					 (select isnull(max(effective_date),
							(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))effective_date,
							Emp_Id
						from T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
						where Emp_Id=@emp_id
						GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
				WHERE e.emp_id =@emp_id and InitiateId = @init_id  and E.Effective_Date <= i.SA_Startdate and isnull(E.status,1)=1
	
		IF @kpacount >0
			BEGIN 
			
				if @type = 1
					begin		
					print 'ssss'		
						select null as SApparisal_ID,Emp_KPA_Id as KPA_ID,kpa_content as KPA,kpa_target,
							   isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as score, '' as Criteria,
							   KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement,0 as KPA_Achievement,KPA_Performace_Measure,
							   0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
							   SUBSTRING([Attach_Docs], CHARINDEX('_', [Attach_Docs]) + 1, LEN([Attach_Docs])) AS [file_name],ISNULL(Attach_Docs,'') as File_Name_ID,Completion_Date							
						FROM T0060_Appraisal_EmployeeKPA E WITH (NOLOCK) left join 
							 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = e.Emp_Id inner JOIN
							 (select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))effective_date,
									Emp_Id
								from T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
								where Emp_Id=@emp_id
								GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
							left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on E.kpa_Type_ID=KM.KPA_Type_Id
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
						FROM T0060_Appraisal_EmployeeKPA E WITH (NOLOCK) left join 
							 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = e.Emp_Id inner JOIN
							 (select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))effective_date,
									Emp_Id
								from T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
								where Emp_Id=@emp_id
								GROUP by Emp_Id) E1 on E1.Emp_Id = e.Emp_Id and E.Effective_Date = e1.effective_date 
						left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on E.kpa_Type_ID=KM.KPA_Type_Id
						WHERE e.emp_id =@emp_id and InitiateId = @init_id  and E.Effective_Date <= i.SA_Startdate and isnull(E.status,1)=1
					END
			END
		ELSE	
			BEGIN  --check if employee's designation assigned any kpa				
				IF @type = 1				
					BEGIN 
					print 'w'
					print @emp_id	
					DECLARE @desig_id AS INT
					DECLARE @dept_Id AS INT
					DECLARE @Maxeffective_date AS DATETIME

					SELECT @desig_id=desig_id,@dept_Id=dept_Id FROM V0060_HRMS_EMP_MASTER_INCREMENT_GET WHERE EMP_ID=@EMP_ID
						
						SELECT @Maxeffective_date=effective_date
						FROM T0051_KPA_Master WITH (NOLOCK) 
						WHERE Cmp_Id=1 and Effective_Date <=Getdate() AND @desig_id in 
						(select Data from dbo.Split(isnull(desig_id,''),'#')) 
						and  (@dept_Id in (select Data from dbo.Split(isnull(dept_Id,''),'#')) or isnull(dept_Id,'')='') 
						--GROUP by Desig_Id,Dept_Id
					
						select DISTINCT null as SApparisal_ID,KPA_id as KPA_ID,kpa_content as KPA, kpa_target,
							  isnull(KPA_Weightage,0) as KPA_Weightage,0.0 as Score ,'' as Criteria,
							  KM.KPA_Type_Id,KM.KPA_Type,'' as Actual_Achievement,0 as KPA_Achievement ,KPA_Performace_Measure,
							  0 as Achievement_Percentage_Emp,0 as Achievement_Percentage_HOD,0 as Achievement_Percentage_RM,0 as Achievement_Percentage_GH,
							  '' AS [file_name],'' as File_Name_ID,'' as Completion_Date							
						from T0051_KPA_Master e WITH (NOLOCK) cross join T0095_INCREMENT i WITH (NOLOCK)  left JOIN 
							  T0050_HRMS_InitiateAppraisal h WITH (NOLOCK) on h.Emp_Id = i.Emp_ID  inner JOIN
							 (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID
							  FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN 
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE CMP_ID = @cmp_id 
										GROUP BY EMP_ID
									)inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 Where T0095_INCREMENT.emp_id=@emp_id)i1 on i1.INCREMENT_ID = i.Increment_ID 
							 left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on E.kpa_Type_ID=KM.KPA_Type_Id
						where  i.Emp_ID = @emp_id  
						and e.Effective_Date =@Maxeffective_date and e.Cmp_Id=@cmp_id
						and @desig_id in (select Data from dbo.Split(isnull(e.desig_id,''),'#')) 
						 and  (@dept_Id in (select Data from dbo.Split(isnull(e.dept_Id,''),'#')) or isnull(e.dept_Id,'')='') 
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
						from T0051_KPA_Master e  WITH (NOLOCK) cross join T0095_INCREMENT i WITH (NOLOCK) left JOIN 
							  T0050_HRMS_InitiateAppraisal h WITH (NOLOCK) on h.Emp_Id = i.Emp_ID  inner JOIN
							 (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID
							  FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN 
									(
										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE CMP_ID = @cmp_id 
										GROUP BY EMP_ID
									)inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 Where T0095_INCREMENT.emp_id=@emp_id)i1 on i1.INCREMENT_ID = i.Increment_ID inner JOIN
							 (
								select isnull(max(effective_date),
									(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))effective_date,
								Desig_Id,Dept_Id
								from T0051_KPA_Master WITH (NOLOCK)
								where Cmp_Id=@cmp_id
								GROUP by Desig_Id,Dept_Id
							 )e1 on e.Effective_Date = e1.effective_date
							 left join T0040_HRMS_KPAType_Master KM WITH (NOLOCK) on E.kpa_Type_ID=KM.KPA_Type_Id
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
