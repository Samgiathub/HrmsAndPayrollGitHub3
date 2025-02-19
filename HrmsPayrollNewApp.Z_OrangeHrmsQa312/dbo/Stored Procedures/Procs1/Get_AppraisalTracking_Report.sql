---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_AppraisalTracking_Report]
	  @cmp_id				numeric(18,0) 
     ,@from_date			datetime
	 ,@to_date				datetime
     ,@condition			varchar(max)=''
	 ,@Exp_Flag				tinyint = 0 -- Added by nilesh patel on 05/03/2018 for Export to excel details 
	 ,@team_emp_id				numeric(18,0)=0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	IF @CONDITION = ''
		SET @CONDITION = '1=1'

    DECLARE @EMP_ID AS NUMERIC(18,0)
	DECLARE @INITIATE_ID AS NUMERIC(18,0)
	DECLARE @STATUSNUM AS INT
	DECLARE @EMPCODE VARCHAR(50)
	DECLARE @EMP_NAME VARCHAR(100)

	if @team_emp_id =0
		set @team_emp_id=NULL
		
	IF OBJECT_ID('TEMPDB..#STATUSTBL') IS NOT NULL
		BEGIN
			DROP TABLE #STATUSTBL
		END
	
	CREATE TABLE #STATUSTBL
	(
		 EMP_ID  NUMERIC(18,0),
		 CURSTATUS VARCHAR(150),
		 CURSTATUSNUM INT,
		 INITIATE_ID NUMERIC(18,0),
		 EMPCODE	VARCHAR(50),
		 EMP_NAME	VARCHAR(100),
		 DEPT_ID	NUMERIC(18,2),
		 DESIG_ID	NUMERIC(18,2),
		 BRANCH_ID	NUMERIC(18,2),
		 RM_ID INT
	)

	IF OBJECT_ID('TEMPDB..#FINALTBL') IS NOT NULL
		BEGIN
			DROP TABLE #FINALTBL
		END
	
	CREATE TABLE #FINALTBL
	(
		EMP_ID			NUMERIC(18,0),
		CURSTATUSNUM		INT,
		INITIATE_ID		NUMERIC(18,0),
		SA_STARTDATE		DATETIME,
		EMPCODE			VARCHAR(50),
		EMP_NAME			VARCHAR(100),
		EMPSAWEIGHT		NUMERIC(18,2),
		EMPSASCORE		NUMERIC(18,2),
		EMPKPAWEIGHT		NUMERIC(18,2),
		EMPKPASCORE		NUMERIC(18,2),
		RMSASCORE			NUMERIC(18,2),
		RMKPASCORE		NUMERIC(18,2),
		RMPAATTRIBUTE		NUMERIC(18,2),
		RMPOATTRIBUTE		NUMERIC(18,2),
		OVERALL_ACHIEVEMENT NUMERIC(18,2),
		DEPT_ID			NUMERIC(18,2),
		DESIG_ID			NUMERIC(18,2),
		BRANCH_ID			NUMERIC(18,2),
		DATE_OF_JOIN	DATETIME,
		HODSASCORE		NUMERIC(18,2),
		HODKPASCORE	NUMERIC(18,2),
		HODPAATTRIBUTE	NUMERIC(18,2),
		HODPOATTRIBUTE	NUMERIC(18,2),
		FinalSASCORE		NUMERIC(18,2),
		FinalKPASCORE	NUMERIC(18,2),
		FinalPAATTRIBUTE	NUMERIC(18,2),
		FinalPOATTRIBUTE	NUMERIC(18,2),
		RM_ID INT,
		Emp_Comments VARCHAR(1000)
	)
	
	DECLARE @Self_Assessment_With_Answer as INT
	
	SELECT @Self_Assessment_With_Answer=isnull(A.Self_Assessment_With_Answer,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@To_Date
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id
	
	DECLARE @HOD_ALIAS AS VARCHAR(200)
	DECLARE @GH_ALIAS AS VARCHAR(200)
	SELECT @HOD_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'HOD'
	SELECT @GH_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Group Head/GH'
		
	DECLARE CUR CURSOR FOR 
		SELECT EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID  AND (EMP_LEFT<>'Y' OR EMP_LEFT_DATE >= @FROM_DATE)
	OPEN CUR
	FETCH NEXT FROM CUR INTO @EMP_ID,@EMPCODE,@EMP_NAME
	WHILE @@FETCH_STATUS=0
		BEGIN	
			IF EXISTS(SELECT 1 FROM T0050_HRMS_INITIATEAPPRAISAL I WITH (NOLOCK) WHERE I.EMP_ID=@EMP_ID AND I.CMP_ID=@CMP_ID AND I.SA_STARTDATE>=@FROM_DATE AND I.SA_STARTDATE <= @TO_DATE)
				BEGIN
					DECLARE CUR_INIT CURSOR FOR
						SELECT INITIATEID FROM T0050_HRMS_INITIATEAPPRAISAL WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND SA_STARTDATE>=@FROM_DATE AND SA_STARTDATE <= @TO_DATE 
					OPEN CUR_INIT
						FETCH NEXT FROM CUR_INIT INTO @INITIATE_ID
							WHILE @@FETCH_STATUS = 0
								BEGIN								
									INSERT INTO #STATUSTBL									
									SELECT DISTINCT @EMP_ID,
											(CASE 
												WHEN HI.SA_STATUS=4 THEN 'ELIGIBLE/SELF ASSESSMENT NOT SUBMITTED'
												WHEN HI.SA_STATUS=3 THEN 'SELF ASSESSMENT DRAFT BY EMPLOYEE' 
												WHEN HI.SA_STATUS=0 THEN 'SELF ASSESSMENT SUBMITTED' 
												WHEN HI.SA_STATUS=2 THEN 'SELF ASSESSMENT SENT BACK FOR REVIEW' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS IS NULL THEN 'SELF ASSESSMENT APPROVED BY REPORTING MANAGER' 
												--WHEN SA_STATUS=1 AND OVERALL_STATUS IS NULL THEN 'SELF ASSESSMENT APPROVED' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =1  THEN 'APPROVED BY ' + @GH_ALIAS 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =2  THEN 'SENT FOR REPORTING MANAGER REVIEW' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =3  THEN 'SENT FOR FINAL APPROVAL' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =4  THEN 'SENT FOR ' + @GH_ALIAS + ' REVIEW' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =6  THEN 'APPROVED BY ' + @HOD_ALIAS 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =7  THEN 'SENT FOR ' + @GH_ALIAS + ' APPROVAL BY ' + @HOD_ALIAS + '/APPROVED BY ' + @HOD_ALIAS
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5 and ISNULL(HI.Emp_Engagement_Comment,'') <> '' THEN 'APPROVED AND COMPLETED CLOSING LOOP'
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5  THEN 'APPROVED' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =0  THEN 'PERFORMANCE ASSESSMENT APPROVED' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =8  THEN 'PERFORMANCE ASSESSMENT SENT FOR REVIEW' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =9  THEN 'DRAFT BY REPORTING MANAGER' 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =10 THEN 'DRAFT BY ' + @HOD_ALIAS
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =11  THEN 'DRAFT BY ' + @GH_ALIAS												
											END),
											
											(CASE 
												WHEN HI.SA_STATUS=4 THEN 1 
												WHEN HI.SA_STATUS=3 THEN 2
												WHEN HI.SA_STATUS=0 THEN 3
												WHEN HI.SA_STATUS=2 THEN 4 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS IS NULL THEN 5 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =1 THEN 6
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS=2 THEN 7
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS=3 THEN 8
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =4  THEN 9 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =6  THEN 10
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =7 THEN 11
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5 and ISNULL(HI.Emp_Engagement_Comment,'') <> '' THEN 18
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5  THEN  12 
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =0  THEN  13 												
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =8  THEN  14  
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =9  THEN 15
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =10 THEN 16
												WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =11  THEN 17												
											END),
											@INITIATE_ID,
											@EMPCODE,@EMP_NAME,
											IE.DEPT_ID,
											IE.DESIG_ID,
											IE.BRANCH_ID,ID.Superior_id
									FROM   T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
										  INNER JOIN	
												(   
													SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.GRD_ID,I.[TYPE_ID],I.DEPT_ID
													FROM T0095_INCREMENT I WITH (NOLOCK)
													INNER JOIN (
																	SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
																	FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
																	(
																		SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE , EMP_ID 
																			FROM T0095_INCREMENT WITH (NOLOCK)
																		WHERE CMP_ID = @CMP_ID
																		GROUP BY EMP_ID
																	) INQRY ON INQRY.EMP_ID = T0095_INCREMENT.EMP_ID
																	WHERE CMP_ID = @CMP_ID
																	GROUP BY T0095_INCREMENT.EMP_ID  
																) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
													WHERE I.CMP_ID= @CMP_ID 
												)IE ON IE.EMP_ID = HI.EMP_ID
												inner join V0050_Initiate_EmpDetail ID on ID.Emp_ID=ie.Emp_ID 
												INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=HI.Emp_ID AND EM.EMP_LEFT<>'Y'
											WHERE HI.INITIATEID = @INITIATE_ID	AND HI.EMP_ID=@EMP_ID	 
											and (HI.HOD_Id=ISNULL(@team_emp_id,HI.HOD_Id) or HI.GH_Id=ISNULL(@team_emp_id,HI.GH_Id) or Superior_ID=ISNULL(@team_emp_id,Superior_ID))
											--and HOD_Id=(case when @team_emp_id > 0 then @team_emp_id end)
											--GH_Id=(case when @team_emp_id > 0 then	@team_emp_id end)						
									FETCH NEXT FROM CUR_INIT INTO @INITIATE_ID
								END
					CLOSE CUR_INIT
					DEALLOCATE CUR_INIT		
					--select * from #STATUSTBL			
				END
			ELSE
				BEGIN
					IF ISNULL(@team_emp_id,0)=0
						BEGIN
							INSERT INTO #STATUSTBL
							SELECT @EMP_ID ,'NOT ELIGIBLE/NOT INITIATED',0,0,@EMPCODE,@EMP_NAME,IC.DEPT_ID,IC.DESIG_ID,IC.BRANCH_ID,0
							FROM  T0095_INCREMENT IC WITH (NOLOCK) INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
								 FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
										SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE , EMP_ID 
											FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE CMP_ID = @CMP_ID AND EMP_ID=@EMP_ID
										GROUP BY EMP_ID
									) INQRY ON INQRY.EMP_ID = T0095_INCREMENT.EMP_ID
								 WHERE CMP_ID = @CMP_ID AND T0095_INCREMENT.EMP_ID=@EMP_ID
								 GROUP BY T0095_INCREMENT.EMP_ID  
								) QRY ON IC.EMP_ID = QRY.EMP_ID AND IC.INCREMENT_ID = QRY.INCREMENT_ID		
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=IC.Emp_ID AND EM.EMP_LEFT<>'Y'
							WHERE IC.EMP_ID = @EMP_ID
						END
				END
			FETCH NEXT FROM CUR INTO @EMP_ID,@EMPCODE,@EMP_NAME
		END	
	CLOSE CUR
	DEALLOCATE CUR
--select * from #STATUSTBL
	SET @INITIATE_ID = NULL
	SET @EMP_ID = NULL

	DECLARE @EKPAWEIGHT NUMERIC(18,2)
	DECLARE @EKPASCORE  NUMERIC(18,2)
	DECLARE @ESAWEIGHT  NUMERIC(18,2)
	DECLARE @ESASCORE   NUMERIC(18,2)
	DECLARE @RMSASCORE		NUMERIC(18,2),
			@RMKPASCORE		NUMERIC(18,2),
			@RMPAATTRIBUTE	NUMERIC(18,2),
			@RMPOATTRIBUTE	NUMERIC(18,2)
	DECLARE @HODSASCORE		NUMERIC(18,2),
			@HODKPASCORE	NUMERIC(18,2),
			@HODPAATTRIBUTE	NUMERIC(18,2),
			@HODPOATTRIBUTE	NUMERIC(18,2)
	DECLARE @FinalSASCORE		NUMERIC(18,2),
			@FinalKPASCORE	NUMERIC(18,2),
			@FinalPAATTRIBUTE	NUMERIC(18,2),
			@FinalPOATTRIBUTE	NUMERIC(18,2)
	
--select initiate_Id,curstatusnum,emp_id from #statustbl
declare cur cursor
 for
	select initiate_Id,curstatusnum,emp_id from #statustbl --where curstatusnum<>0	
OPEN cur
	fetch next from cur into @Initiate_Id,@statusnum,@emp_id
	while @@fetch_status=0
		begin
			if 	@statusnum <>0
				begin
					if @Self_Assessment_With_Answer = 1
						select @eSAWeight =isnull(sum(Weightage),0),@eSAscore=isnull(sum(Emp_Score),0),@RMSAScore=isnull(sum(Manager_Score),0) from T0052_Emp_SelfAppraisal WITH (NOLOCK) where InitiateId = @Initiate_Id and emp_id=@emp_id
					else
						select @eSAWeight =isnull(sum(Emp_Weightage),0),@eSAscore=isnull(sum(Final_Emp_Score),0),@RMSAScore=isnull(sum(Final_RM_Score),0),@HODSASCORE=isnull(sum(Final_HOD_Score),0),@FinalSASCORE=isnull(sum(Final_GH_Score),0) from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where InitiateId = @Initiate_Id and emp_id=@emp_id
											
					select @ekpaWeight =isnull(sum(KPA_Weightage),0),@ekpascore=isnull(sum(KPA_AchievementEmp),0),@RMKPAScore=isnull(sum(KPA_AchievementRM),0),@HODKPASCORE=isnull(sum(KPA_AchievementHOD),0),@FinalKPASCORE=isnull(sum(KPA_AchievementGH),0)  from T0052_HRMS_KPA WITH (NOLOCK) where InitiateId = @Initiate_Id and emp_id=@emp_id
					select @RMPAAttribute = isnull(sum(Att_Achievement),0) from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Initiation_Id = @Initiate_Id and Emp_Id = @emp_id and Att_type='PA'
					select @RMPOAttribute = isnull(sum(Att_Achievement),0) from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Initiation_Id = @Initiate_Id and Emp_Id = @emp_id and Att_type='PoA'
					
					insert into #Finaltbl
					select  DISTINCT i.Emp_Id,@statusnum,i.InitiateId,i.SA_Startdate,e.Alpha_Emp_Code,e.Emp_Full_Name,
							@eSAWeight,@eSAscore,@ekpaWeight,@ekpascore,@RMSAScore,@RMKPAScore,@RMPAAttribute,@RMPOAttribute,I.Overall_Score,
							ie.Dept_ID,ie.Desig_Id,ie.Branch_ID,E.Date_Of_Join,@HODSASCORE,@HODKPASCORE,@HODPAATTRIBUTE,@HODPOATTRIBUTE,@FinalSASCORE,@FinalKPASCORE,@FinalPAATTRIBUTE,@FinalPOATTRIBUTE,ID.Superior_id,I.Emp_Engagement_Comment
					from   T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) INNER JOIN
						   T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id AND E.Emp_Left <> 'Y' INNER JOIN	
							(
								SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
								FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
									(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
									 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
										(
											SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
											FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE CMP_ID = @cmp_id
											 GROUP BY EMP_ID
										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
									 WHERE CMP_ID = @cmp_id
									 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
								where I.Cmp_ID= @cmp_id
							)IE on ie.Emp_ID = e.Emp_ID 
							inner join V0050_Initiate_EmpDetail ID on ID.Emp_ID=ie.Emp_ID 
					where I.InitiateId = @Initiate_Id and I.Emp_Id = @emp_id and (I.HOD_Id=ISNULL(@team_emp_id,I.HOD_Id) or I.GH_Id=ISNULL(@team_emp_id,I.GH_Id)or Superior_ID=ISNULL(@team_emp_id,Superior_ID))
				END	
			ELSE
				BEGIN
					IF ISNULL(@team_emp_id,0)=0
						BEGIN
							insert into #Finaltbl
							select E.Emp_ID,@statusnum,0,NULL,e.Alpha_Emp_Code,e.Emp_Full_Name,0,0,0,0,0,0,0,0,0,ie.Dept_ID,ie.Desig_Id,ie.Branch_ID,E.Date_Of_Join,0,0,0,0,0,0,0,0,0,''
							from   T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN	
							(
								SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
								FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
									(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
									 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
										(
											SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
											FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE CMP_ID = @cmp_id and emp_id=@emp_id
											 GROUP BY EMP_ID
										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
									 WHERE CMP_ID = @cmp_id and T0095_INCREMENT.emp_id=@emp_id
									 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
								where I.Cmp_ID= @cmp_id and i.emp_id=@emp_id
							)IE on ie.Emp_ID = e.Emp_ID 
							where  E.emp_id=@emp_id AND E.Emp_Left <> 'Y'
						END
				END	
			fetch next from cur into @Initiate_Id,@statusnum,@emp_id
		end	
CLOSE cur
DEALLOCATE cur
--select * from #Finaltbl
declare @query as varchar(max)
declare @query1 as varchar(MAX)

if @Exp_Flag = 0
	Begin
		set @query1='select count(*)TotalEmp,curstatus,curstatusnum from #statustbl '--first parent table
		exec (@query1 + ' Where ' + @condition + ' GROUP by curstatus,curstatusnum  order by curstatusnum desc')

		set @query= 'select * from #Finaltbl'
		exec (@query + ' Where ' + @condition + ' order by curstatusnum desc')
	End

if @Exp_Flag = 1
   Begin
		set @query= 'select EMPCODE as ''Employee Code'', 
							EMP_NAME as ''Employee Name'',
							''="'' + convert(nvarchar,SA_STARTDATE,103) + ''"'' as ''Start Date'',
							''="'' + convert(nvarchar,DATE_OF_JOIN,103) + ''"'' as ''Date of Join'',
							EMPSAWEIGHT As ''Self Assessment Weightage'',
							EMPKPAWEIGHT As ''KRA Weightage'',
							EMPSASCORE As ''Employee Self Assessment Score'',
							EMPKPASCORE As ''Employee KRA Score'',
							RMSASCORE As ''Reporting Manager Self Assessment Score'',
							RMKPASCORE  As ''Reporting Manager KRA Score'',
							RMPAATTRIBUTE As ''Reporting Manager Performance Objectives'',
							RMPOATTRIBUTE As ''Reporting Manager Behavioural Attribute'',
							HODSASCORE	AS	''HOD Self Assessment Score'',
							HODKPASCORE	as ''HOD KRA Score'',
							HODPAATTRIBUTE as ''HOD Performance Objectives'',
							HODPOATTRIBUTE as ''HOD Behavioural Objectives'', 
							FinalSASCORE as	''Final Self Assessment Score'',
							FinalKPASCORE as ''Final KRA Score'',
							FinalPAATTRIBUTE as ''Final Performance Objectives'',
							FinalPOATTRIBUTE as ''Final Behavioural Objectives'',
							OVERALL_ACHIEVEMENT As ''Overall Achivement'',
							Emp_Comments As ''Employee Comments''
					from #Finaltbl'
					print @query
		exec (@query + ' Where ' + @condition + ' order by curstatusnum desc')
   End

DROP TABLE #statustbl
DROP TABLE #Finaltbl
END
----------------


