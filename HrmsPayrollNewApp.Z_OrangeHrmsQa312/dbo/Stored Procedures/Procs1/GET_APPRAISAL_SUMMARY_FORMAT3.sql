

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_APPRAISAL_SUMMARY_FORMAT3]
	 @cmp_id			as numeric(18,0)
	,@From_Date			as datetime
	,@To_Date			as datetime
	,@branch_Id			as numeric(18,0)=0
	,@Cat_ID			as numeric = 0	
	,@Grd_Id			as numeric(18,0)=0
	,@Type_Id			as numeric(18,0)=0
	,@Dept_Id			as numeric(18,0)=0
	,@Desig_Id			as numeric(18,0)=0
	,@Emp_Id			as numeric(18,0)=0
	,@Constraint		as varchar(max)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
    Declare @Emp_Cons Table
	(
		 Emp_ID			NUMERIC(18,0)		
	)    
	declare @Performance_Measure int
		
	INSERT INTO @Emp_Cons
	SELECT CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')
	--SELECT InitiateId,emp_id FROM T0050_HRMS_InitiateAppraisal WHERE Cmp_ID=@cmp_id and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
	--		and Emp_Id in (SELECT CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') )
	
	--//table -1 basic employee info	
	CREATE TABLE #Table1
	(
		 Emp_Id				NUMERIC(18,0)
		,Cmp_Id				NUMERIC(18,0)
		,CompanyName		VARCHAR(100)
		,CompanyLogo		IMAGE
		,EmpCode			varchar(100)
		,Emp_Full_Name		varchar(100)
		,Department			varchar(100)
		,Designation		varchar(100)
		,Grade				varchar(100)
		,Qualification		varchar(100)
		,Dob				datetime
		,Doj				datetime
		,Location			varchar(100)		
		,Experience			varchar(200)		
	)
	
	INSERT INTO #Table1
		SELECT EM.Emp_ID,em.Cmp_ID,C.Cmp_Name,C.cmp_logo,EM.Alpha_Emp_Code,em.Emp_Full_Name,DM.Dept_Name,
			   DG.Desig_Name,GM.Grd_Name,(select STUFF((select distinct ',' + q.qual_name 
						from t0040_qualification_master as q WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq WITH (NOLOCK)
						on eq.Qual_ID=q.Qual_ID
						where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
						for XML Path (''),Type).value('.','NVARCHAR(MAX)')
						,1,1,'')qualification)as qualification
			   ,EM.Date_Of_Birth,EM.Date_Of_Join,BM.Branch_Name,ISNULL(EX.EmpExp,0)
		FROM  @Emp_Cons E INNER JOIN
			  T0080_EMP_MASTER EM WITH (NOLOCK) on E.Emp_ID = EM.Emp_ID INNER JOIN
			  T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id= EM.Cmp_ID	INNER JOIN        
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
							(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
							 FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
											SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date,EMP_ID 
											FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
									) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 WHERE CMP_ID = @cmp_id
							 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= @cmp_id 
			)IE on IE.Emp_ID = EM.Emp_ID LEFT JOIN
			T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID =IE.Desig_Id LEFT JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = IE.Dept_ID LEFT JOIN
			T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = IE.Grd_ID  LEFT JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = IE.Branch_ID LEFT JOIN
			V0090_Emp_Experiance_Detail EX on e.Emp_ID=EX.Emp_ID
	
	
	--//table -2 employee appraisal details
	
	CREATE TABLE #Table2
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			numeric(18,0)
		,stdate				datetime
		,endate				datetime
		,EvaluationType		varchar(50)
		,Duration			varchar(100)
		,Financial_year		int
		,kpascore			numeric(18,2)
		,PaScore			numeric(18,2)
		,PoAScore			numeric(18,2)
		,OverallScore		numeric(18,2)
		,RMScore			numeric(18,2)
		,HODAScore			numeric(18,2)
		,GHScore			numeric(18,2)
		,FinAppraiserComment varchar(500)
		,GHComment			varchar(500)
		,HodComment			varchar(500) 
		,Achivement_Id      numeric(18,0)
		,Promo_YesNo		varchar(50)
		,Promo_desig		varchar(50)
		,Promo_grade		varchar(50)
		,Promo_Wef			datetime
		,JR_YesNo			varchar(50)
		,JR_From			datetime
		,JR_To				datetime
		,Inc_YesNo			VARCHAR(50)
		,Inc_Reason			VARCHAR(500)
		,ReportingManager	VARCHAR(100)
		,GroupHead			VARCHAR(100)
		,Hod				VARCHAR(100)
		,Overall_Score_RM	numeric(18,2)
		,Overall_Score_HOD	numeric(18,2)
		,Overall_Score_GH	numeric(18,2)
		,Range_Level		VARCHAR(200)
		,EKPA_Weightage numeric(18,2)
		,SA_Weightage numeric(18,2)
		,Appraiser_Name	VARCHAR(250)
		,Reviewer_Name	VARCHAR(250)	
		,Is_show_Measure int	
		,Self_Assessment_With_Answer int
		,Emp_Engagement_Comment VARCHAR(100)
	)
	
	if EXISTS(SELECT 1 FROM T0040_HRMS_Range_Multiplier WITH (NOLOCK) where Cmp_ID=@cmp_id)
		set @Performance_Measure=1
	else
		set @Performance_Measure=0
	
	DECLARE @Self_Assessment_With_Answer as INT
	
	SELECT @Self_Assessment_With_Answer=isnull(A.Self_Assessment_With_Answer,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@To_Date
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id
		
	INSERT INTO #Table2
	SELECT E.Emp_ID,IA.InitiateId,IA.SA_Startdate,IA.SA_Enddate,case when isnull(IA.Final_Evaluation,1)=1 then 'Final' else 'Interim' end,
			(dbo.F_GET_MONTH_NAME(isnull(IA.Duration_FromMonth,1))+ '-' +dbo.F_GET_MONTH_NAME(isnull(IA.Duration_ToMonth,1))),
			IA.Financial_Year,IA.KPA_Final,IA.PF_Final,IA.PO_Final,IA.Overall_Score,IA.RM_Score,IA.HOD_Score,IA.Group_Head_Score,
			IA.AppraiserComment,IA.HOD_Comment,IA.GH_Comment,0,isnull(IA.Promo_YesNo,0),dg.Desig_Name,gd.Grd_Name,IA.Promo_Wef,isnull(IA.JR_YesNo,0),IA.JR_From,IA.JR_To,
			isnull(IA.Inc_YesNo,0),IA.Inc_Reason,(RE.Alpha_Emp_Code +'-'+ RE.Emp_Full_Name),'',(HODE.Alpha_Emp_Code +'-'+ HODE.Emp_Full_Name),
			ISNULL(IA.Overall_Score_RM,0),ISNULL(IA.Overall_Score_HOD,0),ISNULL(IA.Overall_Score_GH,0),RM1.Range_Level,
			AE.EKPA_Weightage,AE.SA_Weightage,
			--EM_HOD.Emp_Full_Name,EM_GH.Emp_Full_Name,
			VI.appraiser, VI.Approvedby, ---- added by Deepali 28062023
			@Performance_Measure,@Self_Assessment_With_Answer,IA.Emp_Engagement_Comment
		FROM @Emp_Cons E INNER JOIN
		 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID 
		  inner join   V0050_HRMS_InitiateAppraisal VI on VI.Emp_Id = E.Emp_ID  --Added by Deepali- 28062023
		
		 left JOIN
		 T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = IA.Promo_Desig left JOIN
		 T0040_GRADE_MASTER GD WITH (NOLOCK) on GD.Grd_ID = IA.Promo_Grade left JOIN
		 (
			select RM.Range_ID,RM.Range_Level,rm.Effective_Date
			from T0040_HRMS_RangeMaster RM WITH (NOLOCK) left JOIN
				 (
					select isnull(max(Effective_Date),(select from_date from T0010_COMPANY_MASTER WITH (NOLOCK) where cmp_id=@cmp_id))Effective_Date,Range_ID
					from T0040_HRMS_RangeMaster WITH (NOLOCK)
					where Cmp_ID=@cmp_id and Range_Type=2
					GROUP by Range_ID
				 )RM1 on rm1.Range_ID = rm.Range_ID  
			where RM.Cmp_ID = @cmp_id  and Range_Type=2 
		 )R on r.Range_ID = IA.Achivement_Id and r.Effective_Date <= ia.SA_Startdate INNER JOIN        
			(SELECT I.EMP_ID,I.R_Emp_ID
					FROM T0090_EMP_REPORTING_DETAIL I WITH (NOLOCK) INNER JOIN
							(SELECT MAX(Row_ID) AS Row_ID,T0090_EMP_REPORTING_DETAIL.EMP_ID
							 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
									(
											SELECT MAX(Effect_Date) AS Effect_Date,EMP_ID 
											FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
									) inqre on inqre.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
							 WHERE CMP_ID = @cmp_id
							 GROUP BY T0090_EMP_REPORTING_DETAIL.EMP_ID) QRE ON I.EMP_ID = QRE.EMP_ID AND I.Row_ID = QRE.Row_ID
					where I.Cmp_ID= @cmp_id 
			)RIE on RIE.Emp_ID = E.Emp_ID left JOIN
			T0080_EMP_MASTER RE WITH (NOLOCK) on re.Emp_ID= RIE.R_Emp_ID left JOIN
			T0080_EMP_MASTER HODE WITH (NOLOCK) on hode.Emp_ID = IA.HOD_Id left join
			T0040_HRMS_RangeMaster RM1 WITH (NOLOCK) on RM1.Range_ID = IA.Achivement_Id left join
			T0060_Appraisal_EmpWeightage AE WITH (NOLOCK) ON IA.Emp_Id = AE.Emp_Id and IA.Cmp_ID=AE.Cmp_Id left JOIN
			
			  (
				SELECT MAX(Effective_Date)Effective_Date,Emp_Id
				FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK)
				WHERE Effective_Date <= @To_Date
				GROUP by Emp_Id
			  )AE1 on AE.Emp_Id = AE1.Emp_Id and AE.Effective_Date = ae1.Effective_Date left JOIN
			  T0080_EMP_MASTER EM_HOD WITH (NOLOCK) on EM_HOD.Emp_ID=IA.HOD_Id left JOIN
			  T0080_EMP_MASTER EM_GH WITH (NOLOCK) on EM_GH.Emp_ID=IA.GH_Id 
	WHERE IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
	--select * from #Table2
	
	--//table -3 Self Assessment Details
	
	
	
	if @Self_Assessment_With_Answer = 1
		BEGIN
			CREATE TABLE #Table3
			(
				 Emp_Id				NUMERIC(18,0)
				,InitiateId			NUMERIC(18,0)
				,SApparisal_ID		NUMERIC(18,0)
				,SApparisal_Content VARCHAR(1000)
				,Answer				VARCHAR(2000)
				,Weightage			NUMERIC(18,2)
				,Emp_Score			NUMERIC(18,2)
				,Emp_Comments		VARCHAR(500)
				,Manager_Score		NUMERIC(18,2)
				,Manager_comments	VARCHAR(500)
			)
	
			INSERT INTO #Table3	
				SELECT E.Emp_ID,ES.InitiateId,SM.SApparisal_ID,SM.SApparisal_Content,es.Answer,es.Weightage,es.Emp_Score,es.Comments,es.Manager_Score,es.Manager_comments
				FROM @Emp_Cons E LEFT JOIN
					 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN
					 T0052_Emp_SelfAppraisal ES WITH (NOLOCK) on ES.Emp_Id = e.Emp_ID and es.InitiateId = ia.InitiateId left JOIN
					 T0040_SelfAppraisal_Master SM WITH (NOLOCK) on SM.SApparisal_ID =es.SAppraisal_ID
				WHERE IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
		END
	ELSE	
		BEGIN		
			CREATE TABLE #Table11
			(
				 Emp_Id				NUMERIC(18,0)
				,InitiateId			NUMERIC(18,0)
				,SApparisal_ID		NUMERIC(18,0)
				,SApparisal_Content VARCHAR(1000)
				,Emp_Weightage		NUMERIC(18,2)
				,Emp_Rating			NUMERIC(18,2)
				,Final_Emp_Score	NUMERIC(18,2)				
				,RM_Weightage		NUMERIC(18,2)
				,RM_Rating			NUMERIC(18,2)
				,Final_RM_Score		NUMERIC(18,2)
				,HOD_Weightage		NUMERIC(18,2)
				,HOD_Rating			NUMERIC(18,2)
				,Final_HOD_Score	NUMERIC(18,2)
				,GH_Weightage		NUMERIC(18,2)
				,GH_Rating			NUMERIC(18,2)
				,Final_GH_Score		NUMERIC(18,2)
			)
			
			INSERT INTO #Table11	
				SELECT E.Emp_ID,ES.InitiateId,SM.SApparisal_ID,SM.SApparisal_Content,
					ES.Emp_Weightage,ES.Emp_Rating,ES.Final_Emp_Score,ES.RM_Weightage,ES.RM_Rating,ES.Final_RM_Score,
					ES.HOD_Weightage,ES.HOD_Rating,ES.Final_HOD_Score,ES.GH_Weightage,ES.GH_Rating,
					ES.Final_GH_Score
				FROM @Emp_Cons E LEFT JOIN
					 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN
					 T0052_HRMS_EmpSelfAppraisal ES WITH (NOLOCK) on ES.Emp_Id = e.Emp_ID and es.InitiateId = ia.InitiateId left JOIN
					 T0040_SelfAppraisal_Master SM WITH (NOLOCK) on SM.SApparisal_ID =es.SApparisal_ID
				WHERE IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
		END
		
	
		
	CREATE TABLE #Table4
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,KPA_ID				NUMERIC(18,0)
		,KPA_Content		VARCHAR(1000)
		,KPA_Achievement	NUMERIC(18,2) 
		--,KPA_Critical		VARCHAR(1000)
		,KPA_EMP_Comments		VARCHAR(1000)  -- added by Deepali - 2802023
		,KPA_Target			VARCHAR(1000)
		,KPA_Weightage		NUMERIC(18,2) 
		,KPA_AchievementEmp	NUMERIC(18,2) 
		,KPA_AchievementRM  NUMERIC(18,2) 
		,RM_Comments		VARCHAR(MAX)
		,RM_Weightage		NUMERIC(18,2) 
		,RM_Rating		NUMERIC(18,2) 
		,HOD_Weightage	NUMERIC(18,2) 
		,HOD_Rating		NUMERIC(18,2) 
		,KPA_AchievementHOD NUMERIC(18,2) 
		,GH_Weightage	NUMERIC(18,2) 
		,GH_Rating		NUMERIC(18,2) 
		,KPA_AchievementGH NUMERIC(18,2) 
		,KPA_Type		VARCHAR(MAX)
		,Actual_Achievement VARCHAR(MAX)
		,KPA_Performace_Measure varchar(300)
		,Achieve_Perc_EMP float
		,Achieve_Perc_RM float
		,Achieve_Perc_HOD float
		,Achieve_Perc_GH float
		,Attach_Docs		varchar(500)
		,Completion_Date DATETIME
		,KRA_Caption varchar(150)
	)	 
	
	DECLARE @KRA_Caption AS VARCHAR(250)
	SELECT @KRA_Caption=Caption FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id=@cmp_id and Caption='KPA'			 
	
	INSERT INTO #Table4  
	SELECT distinct E.Emp_ID,IA.InitiateId,KP.KPA_ID,KP.KPA_Content,KP.KPA_Achievement,KP.KPA_Critical,KP.KPA_Target,
			KP.KPA_Weightage,KP.KPA_AchievementEmp,KP.KPA_AchievementRM,KP.RM_Comments,
			KP.RM_Weightage,KP.RM_Rating,KP.HOD_Weightage,KP.HOD_Rating,KP.KPA_AchievementHOD,
			KP.GH_Weightage,KP.GH_Rating,KP.KPA_AchievementGH,HKM.KPA_Type,KP.Actual_Achievement,
			ISNULL(KPA.KPA_Performace_Measure,''),ISNULL(Achievement_Percentage_Emp,0),ISNULL(Achievement_Percentage_RM,0),
			ISNULL(Achievement_Percentage_HOD,0),ISNULL(Achievement_Percentage_GH,0),
			left(SUBSTRING(KPA.Attach_Docs,CHARINDEX('_',KPA.Attach_Docs)+1,LEN(KPA.Attach_Docs)),10)+'...',KPA.Completion_Date,@KRA_Caption
	FROM  @Emp_Cons E LEFT JOIN 
		   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID  left JOIN
		     T0060_Appraisal_EmployeeKPA  KPA ON KPA.KPA_InitiateId = IA.InitiateId and IA.Emp_Id=KPA.Emp_Id  left JOIN
		   T0052_HRMS_KPA KP WITH (NOLOCK) ON KP.InitiateId = IA.InitiateId and IA.Emp_Id=KP.Emp_Id LEFT JOIN 
		   T0040_HRMS_KPATYPE_MASTER HKM WITH (NOLOCK) ON KP.KPA_Type_ID = HKM.KPA_TYPE_ID 
		 
	WHERE IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 	
	
	

	--//table -5 Performance Attributes Details	  
	CREATE TABLE #Table5
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,PA_ID				NUMERIC(18,0)
		,PA_Title			varchar(250)
		,PA_Weightage		numeric(18,0)
		,EmpAtt_ID			numeric(18,0)
		,Att_Score			varchar(50)
		,Att_Achievement	numeric(18,0)
		,Att_Critical		varchar(1000)
		,PA_Caption		varchar(150)
	)	 
	
	DECLARE @PA_Caption AS VARCHAR(250)
	SELECT @PA_Caption=Caption FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id=@cmp_id and Caption='Performance Attribute'	
	
	INSERT INTO #Table5
	SELECT E.Emp_ID,IA.InitiateId,AF.PA_ID,AM.PA_Title,AM.PA_Weightage,AF.EmpAtt_ID,AF.Att_Score,AF.Att_Achievement,AF.Att_Critical,@PA_Caption
	FROM  @Emp_Cons E LEFT JOIN
		  T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN 
		  T0052_HRMS_AttributeFeedback AF WITH (NOLOCK) ON AF.Initiation_Id = IA.InitiateId LEFT JOIN
		  T0040_HRMS_AttributeMaster AM WITH (NOLOCK) on AM.PA_ID = AF.PA_ID 
	WHERE AM.PA_Type ='PA' and IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
	
	--//table -6 Potential Attributes Details	  
	CREATE TABLE #Table6
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,PA_ID				NUMERIC(18,0)
		,PA_Title			varchar(250)
		,PA_Weightage		numeric(18,0)
		,EmpAtt_ID			numeric(18,0)
		,Att_Score			varchar(50)
		,Att_Achievement	numeric(18,0)
		,Att_Critical		varchar(1000)
		,PO_Caption		varchar(150)
	)	 
	DECLARE @PO_Caption AS VARCHAR(250)
	SELECT @PO_Caption=Caption FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id=@cmp_id and Caption='Potential Attribute'	
		
	INSERT INTO #Table6
	SELECT E.Emp_ID,IA.InitiateId,AF.PA_ID,AM.PA_Title,AM.PA_Weightage,AF.EmpAtt_ID,AF.Att_Score,AF.Att_Achievement,AF.Att_Critical,@PO_Caption
	FROM  @Emp_Cons E LEFT JOIN
		  T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN 
		  T0052_HRMS_AttributeFeedback AF WITH (NOLOCK) ON AF.Initiation_Id = IA.InitiateId LEFT JOIN
		  T0040_HRMS_AttributeMaster AM WITH (NOLOCK) on AM.PA_ID = AF.PA_ID 
	WHERE AM.PA_Type ='PoA' and IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
	
	--//table -7 Performance 
	
	CREATE TABLE #Table7
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,PerformanceF_ID    NUMERIC(18,0)
		,Performance_Name   VARCHAR(100)
		,Performance_Sort   INT   
		,PFAnswer_ID		NUMERIC(18,0)
		,Answer				VARCHAR(1000)	
	)
	
	INSERT INTO #Table7
	SELECT E.Emp_ID,IA.InitiateId,PA.PerformanceF_ID,PF.Performance_Name,PF.Performance_Sort,PA.PFAnswer_ID,PA.Answer
	FROM	@Emp_Cons E INNER JOIN
			T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN 
			T0052_HRMS_PerformanceAnswer PA WITH (NOLOCK) ON PA.InitiateId = IA.InitiateId LEFT JOIN
			T0040_PerformanceFeedback_Master PF WITH (NOLOCK) ON PA.PerformanceF_ID = PF.PerformanceF_ID	
	WHERE	IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date  
	ORDER BY Performance_Sort ASC
	
	--//table -8 Training 
	
	CREATE TABLE #Table8
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,Training_Area		VARCHAR(500)
		,TrainingType		VARCHAR(50)
	)
	--Insert Skill
	
	
	
		INSERT INTO #Table8
		SELECT E.Emp_ID,IA.InitiateId,s.Skill_Name,sa.Type
		FROM	@Emp_Cons E INNER JOIN
			T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN 
			(
				select REPLACE(At.Recommended_ThisYear,'#',',') Recommended_ThisYear,At.InitiateId,At.Type 
				from T0052_HRMS_AppTraining At 
				WITH (NOLOCK) where At.Type='Skill'
			)sa on IA.InitiateId = sa.InitiateId left JOIN
			T0040_SKILL_MASTER s WITH (NOLOCK) on s.Skill_ID in (SELECT data from dbo.Split(sa.Recommended_ThisYear,',') where Data<>'')
		Where IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
	
	
	 --Insert Training
	INSERT INTO #Table8
	SELECT E.Emp_ID,IA.InitiateId,s.Training_name,sa.Type
	FROM	@Emp_Cons E left JOIN
			T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN 
			(
				select REPLACE(At.Recommended_ThisYear,'#',',') Recommended_ThisYear,At.InitiateId,At.Type 
				from T0052_HRMS_AppTraining At
				WITH (NOLOCK) where At.Type='GM'
			)sa on IA.InitiateId = sa.InitiateId left JOIN
			T0040_Hrms_Training_master s WITH (NOLOCK) on s.Training_id in (SELECT data from dbo.Split(sa.Recommended_ThisYear,',') where Data<>'')
	Where IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date 
		   
	--Insert Support/Functional
	INSERT  INTO #Table8  
	SELECT  E.Emp_ID,IA.InitiateId,AT.TrainingAreas,AT.Type
	FROM	@Emp_Cons E LEFT JOIN
			T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN 
			T0052_HRMS_AppTrainingDetail AT WITH (NOLOCK) on At.InitiateId = IA.InitiateId	
	WHERE   IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date
	
	 --//table -9 Score Summary 
	 
	CREATE TABLE #Table9
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,EKPA_Weightage		NUMERIC(18,0)
		,SA_Weightage		NUMERIC(18,0)
		,PA_Weightage		NUMERIC(18,0)
		,PoA_Weighatge		NUMERIC(18,0)
		,Restrict_Ekpa		INT
		,Restrict_SA		INT
		,RM_Score			NUMERIC(18,0)
		,HOD_Score			NUMERIC(18,0)
		,GH_Score			NUMERIC(18,0)
		,Overall_Score		NUMERIC(18,0)
		,Achivement_Id		NUMERIC(18,0)
		,Range_Name			VARCHAR(100)
	)
	 
	INSERT INTO #Table9 
	SELECT	E.Emp_ID,IA.InitiateId,IE.EKPA_Weightage,IE.SA_Weightage,IE.PA_Weightage,IE.PoA_Weightage,IE.EKPA_RestrictWeightage,IE.SA_RestrictWeightage,
			IA.RM_Score,IA.HOD_Score,IA.Group_Head_Score,IA.Overall_Score,IA.Achivement_Id,RM.Range_Level
	FROM	@Emp_Cons E INNER JOIN
			T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID left JOIN
			(SELECT I.EMP_ID,I.EKPA_Weightage,I.Effective_Date,I.EKPA_RestrictWeightage,I.SA_Weightage,I.SA_RestrictWeightage,I.PA_Weightage,I.PoA_Weightage
					FROM T0060_Appraisal_EmpWeightage I WITH (NOLOCK) INNER JOIN
							(SELECT MAX(Emp_Weightage_Id) AS Emp_Weightage_Id,T0060_Appraisal_EmpWeightage.EMP_ID
							 FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK) INNER JOIN
									(
											SELECT MAX(Effective_Date) AS Effective_Date,EMP_ID 
											FROM T0060_Appraisal_EmpWeightage WITH (NOLOCK) WHERE CMP_ID = @cmp_id
											and Effective_Date <= @To_Date											 
											GROUP BY EMP_ID
									) inqry on inqry.Emp_ID = T0060_Appraisal_EmpWeightage.Emp_ID
							 WHERE CMP_ID = @cmp_id 
							 GROUP BY T0060_Appraisal_EmpWeightage.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID and I.Emp_Weightage_Id=qry.Emp_Weightage_Id
					where I.Cmp_ID= @cmp_id 
			)IE on IE.Emp_ID = E.Emp_ID and IE.Effective_Date<=IA.SA_Startdate LEFT JOIN
			T0040_HRMS_RangeMaster RM WITH (NOLOCK) on RM.Range_ID = IA.Achivement_Id
	WHERE   IA.SA_Startdate >= @From_Date and IA.SA_Startdate<=@To_Date
	
	--//table -10 Appraisal Summary 
	CREATE TABLE #Table10
	(
		 Emp_Id				NUMERIC(18,0)
		 ,Overall_Score		NUMERIC(18,2)
		 ,Average_Score		NUMERIC(18,2)
		 ,Achievement			VARCHAR(100)
	)
	
		
	
	INSERT INTO #Table10
	SELECT E.Emp_ID ,su.TotalScore,su.AvgScore,R.Range_Level--,RM.Effective_Date,IA.SA_Startdate
		FROM @Emp_Cons E LEFT JOIN
		 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID LEFT JOIN
		 (	
			SELECT sum(Overall_Score)TotalScore,(sum(Overall_Score)/count(InitiateId))AvgScore,Emp_Id 
			FROM #Table9 
			GROUP by Emp_Id
		 )Su on E.Emp_ID = su.Emp_Id left JOIN
		 T0040_HRMS_RangeMaster R WITH (NOLOCK) INNER JOIN
		 (
			select max(Effective_Date) Effective_Date,Range_ID
			from T0040_HRMS_RangeMaster WITH (NOLOCK)
			where Cmp_ID=@cmp_id and Range_Type=2 
			GROUP by Range_ID
		 )RM on Rm.Range_ID=r.Range_ID
		 on Range_From <= Su.AvgScore and R.Range_To >= Su.AvgScore 
		 and r.Effective_Date <= ia.SA_Startdate
		WHERE --IA.Final_Evaluation =1 and 
		r.Range_Type =2
	
		   
	SELECT   Emp_Id				
			,Cmp_Id				
			,CompanyName as CMP_NAME		
			,CompanyLogo		
			,EmpCode			
			,Emp_Full_Name		
			,Department			
			,Designation		
			,Grade			
			,Qualification		
			,convert(varchar(15),Dob,103)Dob		
			,convert(varchar(15),Doj,103)Doj			
			,Location	
			,Experience
	FROM #Table1	
	SELECT	 Emp_Id				
			,InitiateId			
			,convert(varchar(15),stdate,103) stdate				
			,convert(varchar(15),endate,103) endate				
			,EvaluationType		
			,Duration			
			,Financial_year		
			,kpascore			
			,PaScore			
			,PoAScore			
			,OverallScore		
			,RMScore			
			,HODAScore			
			,GHScore			
			,FinAppraiserComment 
			,GHComment			
			,HodComment			
			,Achivement_Id      
			,Promo_YesNo		
			,Promo_desig		
			,Promo_grade		
			,Promo_Wef			
			,JR_YesNo			
			,JR_From			
			,JR_To				
			,Inc_YesNo			
			,Inc_Reason			
			,ReportingManager	
			,GroupHead			
			,Hod	
			,Overall_Score_RM
			,Overall_Score_HOD
			,Overall_Score_GH	
			,Range_Level				
			,EKPA_Weightage
			,SA_Weightage
			,Appraiser_Name
			,Reviewer_Name
			,Is_show_Measure
			,Self_Assessment_With_Answer
			,Emp_Engagement_Comment
	FROM	#Table2		
	
	if @Self_Assessment_With_Answer=1
		SELECT * FROM #Table3	WHERE InitiateId IS NOT NULL
	ELSE
		SELECT * from #Table11 WHERE InitiateId IS NOT NULL
		
	SELECT * FROM #Table4	
	SELECT * FROM #Table5
	SELECT * FROM #Table6
	SELECT	  Emp_Id			
			,InitiateId			
			,PerformanceF_ID    
			--,Case When row_number() OVER ( PARTITION BY PerformanceF_ID  order by PerformanceF_ID ) = 1
			-- Then  cast(Performance_Name  AS varchar(100)) Else '' End Performance_Name 
			,Performance_Name
			,Performance_Sort  
			,PFAnswer_ID	
			,Answer			
	FROM #table7
	ORDER BY Performance_Sort ASC
	
	SELECT  Emp_Id				
		   ,InitiateId	
		   ,Case When Training_Area is null then NULL
			else row_number() OVER ( PARTITION BY  InitiateId order by InitiateId )  end as U_ID
		   ,Training_Area	
		   ,TrainingType	
	FROM #Table8 
	where Training_Area is not null
	ORDER BY InitiateId,Emp_Id,TrainingType
	
	SELECT   Emp_Id			
			,InitiateId			
			,isnull(EKPA_Weightage,0)EKPA_Weightage		
			,isnull(SA_Weightage,0)SA_Weightage		
			,isnull(PA_Weightage,0)PA_Weightage		
			,isnull(PoA_Weighatge,0)PoA_Weighatge		
			,Restrict_Ekpa		
			,Restrict_SA		
			,isnull(RM_Score,0)RM_Score			
			,isnull(HOD_Score,0)HOD_Score			
			,isnull(GH_Score,0)GH_Score			
			,isnull(Overall_Score,0)Overall_Score		
			,Achivement_Id		
			,Range_Name			
	FROM #Table9
	SELECT * FROM #Table10
	
	
	CREATE TABLE #Table12
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,[Action]			VARCHAR(max)
		,Justification		VARCHAR(max)		
		,TimeFrame			VARCHAR(250)
		,from_date			DATETIME
		,to_date			DATETIME
		,Promo_Desig		VARCHAR(250)
		,Is_Applicable		NUMERIC(18,0)
	)
	--select * from @Emp_Cons
	
	create table #table15
	(
		 PerformanceF_ID    numeric(18,0)
		,Performance_Name   varchar(100)
		,Performance_Sort   int   
		,PFAnswer_ID		numeric(18,0)
		,Answer				varchar(1000)
		,initiateid			numeric(18,0)
		,emp_id				numeric(18,0)
	)

	DECLARE @SendToHOD as int
	DECLARE @SA_SendToRM as INT
	DECLARE @GH_Id as INT
	DECLARE @emp_id1 as INT
	DECLARE @init_id as INT
	DECLARE @flag as varchar(15)	
	
	DECLARE other_details CURSOR FOR						
		select DISTINCT ISNULL(i.SendToHOD,0),ISNULL(i.Rm_Required,0),ISNULL(i.GH_Id,0),i.Emp_Id,i.InitiateId from T0050_HRMS_InitiateAppraisal i WITH (NOLOCK)
		inner join @Emp_Cons e1 on i.Emp_Id=e1.Emp_ID
		WHERE   i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date
	OPEN other_details
		fetch next from other_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			while @@fetch_status = 0
				Begin
				--select @SA_SendToRM,@SendToHOD,@GH_Id
					if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='Final')
						BEGIN
							set @flag='Final'
						END
					else if @GH_Id > 0
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='GH')
							set @flag='GH'
						END
					else if @SendToHOD=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='HOD')
							set @flag='HOD'
						END
					else if @SA_SendToRM=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='RM')
							set @flag='RM'
						END
						
					PRINT @flag		
									
					insert into #Table12
					SELECT hao.Emp_ID,hao.InitiateId,ao.[Action],Justification,tm.TimeFrame,hao.From_Date,hao.To_Date,ISNULL(dm.Desig_Name,''),hao.Is_Applicable					
					from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
					inner join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
					hao.InitiateId=@init_id and hao.Approval_Level=@flag
					inner join T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) on i.InitiateId=hao.InitiateId and i.Emp_Id=hao.Emp_ID
					LEFT join T0040_HRMS_TimeFrame_Master tm WITH (NOLOCK) on tm.TimeFrame_Id=hao.TimeFrame_Id
					LEFT join T0040_DESIGNATION_MASTER dm WITH (NOLOCK) on dm.Desig_ID=hao.Promo_Desig
					where hao.Cmp_ID =@cmp_id and hao.Emp_ID=@emp_id1 and hao.InitiateId=@init_id
						  and i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date 
				fetch next from other_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			End
	close other_details	
	deallocate other_details
	--select * from #Table12
	select * from #Table12 --where [Action] = 'Overall fitment in current Job Role'
	
	CREATE TABLE #Table13
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,other_assessment	VARCHAR(max)
		,column1			VARCHAR(max)
		,column2			VARCHAR(max)
		,rm_comments		VARCHAR(max)
		,hod_comments		VARCHAR(max)
		,gh_somments		VARCHAR(max)
	)
	insert into #Table13
	select DISTINCT EF.Emp_Id,EF.Initiation_Id,om.OA_Title,EF.EOA_Column1,EF.EOA_Column2,EF.RM_Comments,EF.HOD_Comments,EF.GH_Comments
	from T0050_HRMS_EmpOA_Feedback EF WITH (NOLOCK)
	inner join T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) on i.InitiateId=ef.Initiation_Id and i.Emp_Id=ef.Emp_Id
	inner join @Emp_Cons em on EF.Emp_Id=em.Emp_ID
	inner join T0040_HRMS_OtherAssessment_Master om WITH (NOLOCK) on ef.OA_ID=om.OA_Id and ef.Cmp_ID=om.Cmp_ID
	WHERE   i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date
	
	select * from #Table13
	
	CREATE TABLE #Table14
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,[plan]				VARCHAR(max)
		,area				VARCHAR(max)
		,method				VARCHAR(max)
		,timeframe			VARCHAR(max)
		,comments			VARCHAR(max)		
	)
	DECLARE plan_details CURSOR FOR						
		select DISTINCT ISNULL(i.SendToHOD,0),ISNULL(i.Rm_Required,0),ISNULL(i.GH_Id,0),i.Emp_Id,i.InitiateId from T0050_HRMS_InitiateAppraisal i WITH (NOLOCK)
		inner join @Emp_Cons e1 on i.Emp_Id=e1.Emp_ID
		WHERE   i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date
	OPEN plan_details
		fetch next from plan_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			while @@fetch_status = 0
				Begin
				--select @SA_SendToRM,@SendToHOD,@GH_Id
					if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='Final')
						BEGIN
							set @flag='Final'
						END
					else if @GH_Id > 0
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='GH')
							set @flag='GH'
						END					
					else if @SendToHOD=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='HOD')
							set @flag='HOD'
						END
					else if @SA_SendToRM=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_PlanDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='RM')
							set @flag='RM'
						END
					
					--PRINT @flag		
									
					insert into #Table14
					SELECT ap.Emp_ID,ap.InitiateId,ap.[Plan],ap.Area,hm.Method,tm.TimeFrame,ap.Comments					
					from T0110_HRMS_Appraisal_PlanDetails ap WITH (NOLOCK)
					inner join T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) on i.InitiateId=ap.InitiateId and i.Emp_Id=ap.Emp_ID
					LEFT join T0040_HRMS_TimeFrame_Master tm WITH (NOLOCK) on tm.TimeFrame_Id=ap.TimeFrame_Id
					LEFT join T0040_HRMS_Method_Master hm WITH (NOLOCK) on hm.Method_Id=ap.Method_Id
					where ap.Cmp_ID =@cmp_id and ap.Emp_ID=@emp_id1 and ap.InitiateId=@init_id and
						ap.Approval_Level=@flag and i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date
					
					insert into #table15(PerformanceF_ID,Performance_Name,Performance_Sort,emp_id,initiateid)
					(select PerformanceF_ID,Performance_Name,Performance_Sort,@emp_id1,@init_id from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Cmp_ID=@cmp_id)
					
					update #table15 set PFAnswer_ID = p.PFAnswer_ID ,Answer=p.Answer 
					From(select PFAnswer_ID,case when GH_Feedback <> '' then GH_Feedback WHEN HOD_Feedback <> '' then HOD_Feedback else Answer end Answer,
								PerformanceF_ID from T0052_HRMS_PerformanceAnswer  WITH (NOLOCK)
						 where  InitiateId= @init_id and Emp_Id=@emp_id1)p
					where  #table15.PerformanceF_ID = p.PerformanceF_ID	
				
				fetch next from plan_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			End
	close plan_details	
	deallocate plan_details
	
	select * from #Table14	
	
	select InitiateId,Emp_Id,[Action],case when Is_Applicable=0 then 'Yes' else 'No' end as Is_Applicable  
	from #Table12 where [Action] = 'Overall fitment in current Job Role'
	
	DROP TABLE #Table1
	DROP TABLE #Table2
	if @Self_Assessment_With_Answer=1
		DROP TABLE #Table3
	ELSE
		DROP TABLE #Table11
	
	create table #table16
	(
	 Range_ID			numeric(18,0)
	,Range_From			numeric(18,2)
	,Range_To			numeric(18,2)
	,Range_Level		varchar(50)
	--,Initiation_Id		numeric(18,0)
	--,Emp_Id				numeric(18,0)
	)
	
	insert into #table16(Range_ID,Range_From,Range_To,Range_Level)
	(select DISTINCT Range_ID,Range_From,Range_To,Range_Level
	from T0040_HRMS_RangeMaster HR WITH (NOLOCK)
	inner join @Emp_Cons em on HR.Cmp_ID=hr.Cmp_ID
	inner join T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) on  i.Emp_Id=em.Emp_Id
	where Range_Type = 2 and HR.Cmp_ID=@cmp_id and i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date) 
	
	
	select * from #table15
	select * from #table16
	
	DROP TABLE #Table4
	DROP TABLE #Table5
	DROP TABLE #Table6
	DROP TABLE #Table7
	DROP TABLE #Table8
	DROP TABLE #Table9
	DROP TABLE #Table10
	DROP TABLE #Table12
	DROP TABLE #Table13
	DROP TABLE #Table15
	DROP TABLE #Table16
END


