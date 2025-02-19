---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_KPA_Tracking_Report]
	  @cmp_id				numeric(18,0) 
     ,@from_date			datetime
	 ,@to_date				datetime
     ,@condition			varchar(max)=''
	 ,@Exp_Flag				tinyint = 0
	 ,@team_emp_id			numeric(18,0)=0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @CONDITION = ''
		SET @CONDITION = '1=1'

	if @team_emp_id =0
		set @team_emp_id=NULL
		
		PRINT @team_emp_id
    DECLARE @EMP_ID AS NUMERIC(18,0)
	DECLARE @KPA_InitiateId AS NUMERIC(18,0)
	DECLARE @STATUSNUM AS INT
	DECLARE @EMPCODE VARCHAR(50)
	DECLARE @EMP_NAME VARCHAR(100)

	IF OBJECT_ID('TEMPDB..#STATUSTBL') IS NOT NULL
		BEGIN
			DROP TABLE #STATUSTBL
		END
	
	CREATE TABLE #STATUSTBL
	(
		 EMP_ID  NUMERIC(18,0),
		 CURSTATUS VARCHAR(150),
		 CURSTATUSNUM INT,
		 KPA_InitiateId NUMERIC(18,0),
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
		KPA_InitiateId		NUMERIC(18,0),
		KPA_StartDate		DATETIME,
		EMPCODE			VARCHAR(50),
		EMP_NAME			VARCHAR(100),
		DEPT_ID			NUMERIC(18,2),
		DESIG_ID			NUMERIC(18,2),
		BRANCH_ID			NUMERIC(18,2),
		DATE_OF_JOIN	DATETIME,
		Dept_Name		VARCHAR(250),
		Desig_Name		VARCHAR(250),
		Branch_Name VARCHAR(250),
		RM_ID INT	
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
	DECLARE @KPA_ALIAS AS VARCHAR(200)
	SELECT @HOD_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'HOD'
	SELECT @GH_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Group Head/GH'
	SELECT @KPA_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'KPA'
		
	DECLARE CUR CURSOR FOR 
		SELECT EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID  AND (EMP_LEFT<>'Y' OR EMP_LEFT_DATE >= @FROM_DATE)
	OPEN CUR
	FETCH NEXT FROM CUR INTO @EMP_ID,@EMPCODE,@EMP_NAME
	WHILE @@FETCH_STATUS=0
		BEGIN	
			IF EXISTS(SELECT 1 FROM T0055_Hrms_Initiate_KPASetting I WITH (NOLOCK) WHERE I.EMP_ID=@EMP_ID AND I.CMP_ID=@CMP_ID AND I.KPA_StartDate>=@FROM_DATE AND I.KPA_StartDate <= @TO_DATE)
				BEGIN
					DECLARE CUR_INIT CURSOR FOR
						SELECT KPA_InitiateId FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND KPA_StartDate>=@FROM_DATE AND KPA_StartDate <= @TO_DATE 
					OPEN CUR_INIT
						FETCH NEXT FROM CUR_INIT INTO @KPA_InitiateId
							WHILE @@FETCH_STATUS = 0
								BEGIN
									INSERT INTO #STATUSTBL									
									SELECT DISTINCT @EMP_ID,
											(CASE 
												WHEN Initiate_Status=4 THEN 'ELIGIBLE/ '+ @KPA_ALIAS +' NOT SUBMITTED'
												WHEN Initiate_Status=0 THEN 'DRAFT'
												WHEN Initiate_Status=2 THEN 'SUBMITTED BY EMPLOYEE' 
												WHEN Initiate_Status=3 THEN 'SENT FOR EMPLOYEE REVIEW' 
												WHEN Initiate_Status=5 THEN 'APPROVED BY MANAGER' 
												WHEN Initiate_Status=6 THEN 'SENT FOR REPORTING MANAGER REVIEW' 																
												WHEN Initiate_Status=7 THEN 'APPROVED BY ' + @HOD_ALIAS 					
												WHEN Initiate_Status=8 THEN 'SENT FOR '+ @HOD_ALIAS +' REVIEW' 
												WHEN Initiate_Status=1 THEN 'APPROVED'								
											END),
											
											(CASE 
												WHEN Initiate_Status=4 THEN 1
												WHEN Initiate_Status=0 THEN 2
												WHEN Initiate_Status=2 THEN 3
												WHEN Initiate_Status=3 THEN 4
												WHEN Initiate_Status=5 THEN 5 
												WHEN Initiate_Status=6 THEN 6												
												WHEN Initiate_Status=7 THEN 7					
												WHEN Initiate_Status=8 THEN 8
												WHEN Initiate_Status=1 THEN 9
											END),
											@KPA_InitiateId,
											@EMPCODE,@EMP_NAME,
											IE.DEPT_ID,
											IE.DESIG_ID,
											IE.BRANCH_ID,
											case when ISNULL(IK.Rm_Required, 1)=1 then E1.Emp_ID else 0 end
									FROM   T0055_Hrms_Initiate_KPASetting IK WITH (NOLOCK)
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
																	) INQRY ON inqry.Increment_Effective_Date=T0095_INCREMENT.INCREMENT_EFFECTIVE_DATE AND INQRY.EMP_ID = T0095_INCREMENT.EMP_ID
																	WHERE CMP_ID = @CMP_ID
																	GROUP BY T0095_INCREMENT.EMP_ID  
																) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
													WHERE I.CMP_ID= @CMP_ID 
												)IE ON IE.EMP_ID = IK.EMP_ID LEFT OUTER JOIN (
												select	R.EMP_ID,R.R_EMP_ID 
												FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
														INNER JOIN (SELECT	MAX(R1.ROW_ID) AS ROW_ID, R1.EMP_ID
																	FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
																			INNER JOIN (SELECT	MAX(R2.EFFECT_DATE) AS EFFECT_DATE, R2.EMP_ID
																						FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																						INNER JOIN dbo.T0050_HRMS_InitiateAppraisal WITH (NOLOCK) ON R2.Emp_ID = dbo.T0050_HRMS_InitiateAppraisal.Emp_Id AND 
																						R2.Effect_Date <= dbo.T0050_HRMS_InitiateAppraisal.SA_Startdate
																						GROUP	BY R2.EMP_ID
																						) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE
																	GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
												) ERD ON IK.EMP_ID=ERD.EMP_ID 
												LEFT OUTER JOIN	dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK) ON E1.Emp_ID = ERD.R_Emp_ID 
												--INNER JOIN V0050_Initiate_EmpDetail ID on ID.Emp_ID=ie.Emp_ID 
											WHERE KPA_InitiateId = @KPA_InitiateId	AND IK.EMP_ID=@EMP_ID 
											AND (IK.HOD_Id=ISNULL(@team_emp_id,IK.HOD_Id) or IK.GH_Id=ISNULL(@team_emp_id,IK.GH_Id) or R_Emp_ID=ISNULL(@team_emp_id,R_Emp_ID))
									FETCH NEXT FROM CUR_INIT INTO @KPA_InitiateId
								END
					CLOSE CUR_INIT
					DEALLOCATE CUR_INIT		
					--select * from #STATUSTBL			
				END
			ELSE
				BEGIN
					IF @team_emp_id=0
						BEGIN
							INSERT INTO #STATUSTBL
							SELECT DISTINCT @EMP_ID ,'NOT ELIGIBLE/NOT INITIATED',0,0,@EMPCODE,@EMP_NAME,IC.DEPT_ID,IC.DESIG_ID,IC.BRANCH_ID
							FROM  T0095_INCREMENT IC WITH (NOLOCK) INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
								 FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
										SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE , EMP_ID 
											FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE CMP_ID = @CMP_ID AND EMP_ID=@EMP_ID
										GROUP BY EMP_ID
									) INQRY ON inqry.Increment_Effective_Date=T0095_INCREMENT.INCREMENT_EFFECTIVE_DATE AND INQRY.EMP_ID = T0095_INCREMENT.EMP_ID
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
	SET @KPA_InitiateId = NULL
	SET @EMP_ID = NULL	

declare cur cursor
 for
	select KPA_InitiateId,curstatusnum,emp_id from #statustbl --where curstatusnum<>0	
OPEN cur
	fetch next from cur into @KPA_InitiateId,@statusnum,@emp_id
	while @@fetch_status=0
		begin
			if 	@statusnum <>0
				begin					
					insert into #Finaltbl
					select DISTINCT	i.Emp_Id,@statusnum,i.KPA_InitiateId,i.KPA_StartDate,e.Alpha_Emp_Code,e.Emp_Full_Name,
							ie.Dept_ID,ie.Desig_Id,ie.Branch_ID,E.Date_Of_Join,dpm.Dept_Name,dm.Desig_Name,bm.Branch_Name,case when ISNULL(I.Rm_Required, 1)=1 then E1.Emp_ID else 0 end
					from   T0055_Hrms_Initiate_KPASetting I WITH (NOLOCK) INNER JOIN
						   T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id  AND E.Emp_Left <> 'Y' INNER JOIN	
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
										) inqry on inqry.Increment_Effective_Date=T0095_INCREMENT.INCREMENT_EFFECTIVE_DATE AND inqry.Emp_ID = T0095_INCREMENT.Emp_ID 
									 WHERE CMP_ID = @cmp_id
									 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
								where I.Cmp_ID= @cmp_id
							)IE on ie.Emp_ID = e.Emp_ID 
							left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on bm.Branch_ID=ie.Branch_ID
							left join T0040_DESIGNATION_MASTER dm WITH (NOLOCK) on dm.Desig_ID=ie.Desig_Id
							left join T0040_DEPARTMENT_MASTER dpm WITH (NOLOCK) on dpm.Dept_Id=ie.Dept_ID
							LEFT OUTER JOIN (
							select	R.EMP_ID,R.R_EMP_ID 
							FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
									INNER JOIN (SELECT	MAX(R1.ROW_ID) AS ROW_ID, R1.EMP_ID
												FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
														INNER JOIN (SELECT	MAX(R2.EFFECT_DATE) AS EFFECT_DATE, R2.EMP_ID
																	FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																	INNER JOIN dbo.T0050_HRMS_InitiateAppraisal WITH (NOLOCK) ON R2.Emp_ID = dbo.T0050_HRMS_InitiateAppraisal.Emp_Id AND 
																	R2.Effect_Date <= dbo.T0050_HRMS_InitiateAppraisal.SA_Startdate
																	GROUP	BY R2.EMP_ID
																	) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE
												GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
							) ERD ON I.EMP_ID=ERD.EMP_ID LEFT OUTER JOIN
							dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK) ON E1.Emp_ID = ERD.R_Emp_ID 
					where I.KPA_InitiateId = @KPA_InitiateId and I.Emp_Id = @emp_id	 
					and (I.HOD_Id=ISNULL(@team_emp_id,I.HOD_Id) or I.GH_Id=ISNULL(@team_emp_id,I.GH_Id) or R_Emp_ID=ISNULL(@team_emp_id,R_Emp_ID))
					
					--select * from #Finaltbl
				END	
			ELSE
				BEGIN			
					IF ISNULL(@team_emp_id,0)=0
						BEGIN
							insert into #Finaltbl
							select DISTINCT E.Emp_ID,@statusnum,0,NULL,e.Alpha_Emp_Code,e.Emp_Full_Name,ie.Dept_ID,ie.Desig_Id,ie.Branch_ID,E.Date_Of_Join,dpm.Dept_Name,dm.Desig_Name,bm.Branch_Name
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
										) inqry on inqry.Increment_Effective_Date=T0095_INCREMENT.INCREMENT_EFFECTIVE_DATE AND inqry.Emp_ID = T0095_INCREMENT.Emp_ID
									 WHERE CMP_ID = @cmp_id and T0095_INCREMENT.emp_id=@emp_id
									 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
								where I.Cmp_ID= @cmp_id and i.emp_id=@emp_id
							)IE on ie.Emp_ID = e.Emp_ID 
							left join T0030_BRANCH_MASTER bm WITH (NOLOCK) on bm.Branch_ID=ie.Branch_ID
							left join T0040_DESIGNATION_MASTER dm WITH (NOLOCK) on dm.Desig_ID=ie.Desig_Id
							left join T0040_DEPARTMENT_MASTER dpm WITH (NOLOCK) on dpm.Dept_Id=ie.Dept_ID
							where  E.emp_id=@emp_id  AND E.Emp_Left <> 'Y'

							
						END
				END	
			fetch next from cur into @KPA_InitiateId,@statusnum,@emp_id
		end	
CLOSE cur
DEALLOCATE cur

declare @query as varchar(max)
declare @query1 as varchar(MAX)

if @Exp_Flag = 0
	Begin
		set @query1='select count(*)TotalEmp,curstatus,curstatusnum from #statustbl '--first parent table
		exec (@query1 + ' Where ' + @condition + '  GROUP by curstatus,curstatusnum  order by curstatusnum desc')

		set @query= 'select * from #Finaltbl'
		exec (@query + ' Where ' + @condition + ' order by curstatusnum desc')
	End

if @Exp_Flag = 1
   Begin
		set @query= 'select EMPCODE as ''Employee Code'', 
							EMP_NAME as ''Employee Name'',
							Dept_Name as ''Department'',
							Desig_name as ''Designation'',
							Branch_Name as ''Brnach'',
							''="'' + convert(nvarchar,KPA_StartDate,103) + ''"'' as ''Initition Date''							
					from #Finaltbl'
					print @query
		exec (@query + ' Where ' + @condition + ' order by curstatusnum desc')
   End

DROP TABLE #statustbl
DROP TABLE #Finaltbl
END
----------------


