CREATE PROCEDURE [dbo].[Rpt_Employee_KPA_Details]
     @cmp_id        numeric(18,0)
	,@From_Date     datetime 
	,@To_Date       datetime = getdate
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric(18,0)
	,@Format		int
	,@Constraint	varchar(MAX)=''
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

    CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric    
	 )  
	
	IF @Constraint <> ''
		BEGIN
			Insert Into #Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		END
	ELSE
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	IF @Format =0
		BEGIN
			CREATE TABLE #finalDetail
			(
				 Emp_Id					NUMERIC(18,0)
				,Employee_Code			VARCHAR(50)
				,Employee_Name			VARCHAR(50)
				,KPA					VARCHAR(MAX)
				,WEIGHTAGE				INT
				,SELF_RATING			FLOAT
				,MANAGER_RATING			FLOAT
				,HOD_RATING				FLOAT
				,FINAL_RATING			FLOAT
				,APPRAISEE_COMMENTS		VARCHAR(MAX)
				,MANAGER_COMMENTS		VARCHAR(MAX)
				,HOD_COMMENTS			VARCHAR(MAX)
				,OVERALL_MANAGER_COMMENTS VARCHAR(MAX)
				,OVERALL_HOD_COMMENTS VARCHAR(MAX)
				,OVERALL_FINAL_COMMENTS VARCHAR(MAX)
			)	
	
			--DECLARE @KPA_ALIAS AS VARCHAR(100)
			--SELECT @KPA_ALIAS=Alias FROM T0040_CAPTION_SETTING WHERE Cmp_Id=@CMP_ID AND AND Caption='KPA'
	
			INSERT INTO #finalDetail
			SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,HK.KPA_Content,HK.KPA_Weightage,HK.KPA_AchievementEmp,
					HK.KPA_AchievementRM,HK.KPA_AchievementHOD,
					CASE WHEN HK.KPA_AchievementGH > 0 THEN HK.KPA_AchievementGH WHEN HK.KPA_AchievementHOD > 0 THEN HK.KPA_AchievementHOD
					WHEN HK.KPA_AchievementRM >0 THEN HK.KPA_AchievementRM END,'',HK.RM_Comments,HK.HOD_Comments,
					HI.AppraiserComment,HI.HOD_Comment,HI.GH_Comment
			FROM  #Emp_Cons E INNER JOIN
					T0080_EMP_MASTER EM on EM.Emp_ID = E.Emp_ID INNER JOIN
					T0052_HRMS_KPA HK ON HK.Emp_Id=E.Emp_ID AND HK.Cmp_ID=EM.Cmp_ID INNER JOIN
					T0050_HRMS_InitiateAppraisal HI ON HI.InitiateId=HK.InitiateId AND HI.Cmp_ID=HK.Cmp_ID	
			WHERE HI.SA_Startdate >= @From_Date and HI.SA_Enddate <= @To_Date and HK.Cmp_ID=@CMP_ID

			SELECT * FROM #finalDetail
			DROP TABLE #finalDetail
		END
	ELSE
		BEGIN
			DECLARE @query VARCHAR(MAX)
			DECLARE @columns VARCHAR(MAX)
			CREATE TABLE #PMS_Details
			(	
				 Emp_Id					NUMERIC(18,0)
				,Branch_Id				NUMERIC(18,0)
				,Dept_Id				NUMERIC(18,0)
				,Employee_Code			VARCHAR(50)
				,Employee_Name			VARCHAR(250)
				,Branch					VARCHAR(350)
				,Place_Of_Posting		VARCHAR(350)
				,Department				VARCHAR(350)
				,Designation			VARCHAR(350)
				,Grade					VARCHAR(350)
				,Manager_Code			VARCHAR(50)
				,Manager_Name			VARCHAR(250)
				--,Status_Of_KPIs		VARCHAR(150)		
				--,Date_Of_Submission_By_Employee	VARCHAR(15)
				--,Date_Of_Approved_By_Manager	VARCHAR(15)				
			)	
	
			--DECLARE @KPA_ALIAS AS VARCHAR(100)
			--SELECT @KPA_ALIAS=Alias FROM T0040_CAPTION_SETTING WHERE Cmp_Id=@CMP_ID AND AND Caption='KPA'
	
			INSERT INTO #PMS_Details
			SELECT  distinct E.Emp_ID,E.Branch_ID,EM.Dept_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Branch_Name,EM.Cat_Name,EM.Dept_Name,EM.Desig_Name,EM.Grd_Name,
			left(HI.Manager_Name,CHARINDEX('-',HI.Manager_Name)-1),SUBSTRING(HI.Manager_Name,CHARINDEX('-',HI.Manager_Name)+1,LEN(HI.Manager_Name))
			--,HI.InitiateStatus,CONVERT(varchar(15),Emp_ApprovedDate,103),CONVERT(varchar(15),Rm_ApprovedDate,103)
			FROM  #Emp_Cons E INNER JOIN
				  V0060_HRMS_EMP_MASTER_INCREMENT_GET EM on EM.Emp_ID = E.Emp_ID INNER JOIN
				  V0055_Hrms_Initiate_KPASetting HI ON HI.Emp_Id=E.Emp_ID --AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status
			WHERE HI.KPA_StartDate >= @From_Date and HI.KPA_EndDate <= @To_Date and HI.Cmp_ID=@CMP_ID
			ORDER BY E.EMP_ID

			

			
			CREATE TABLE #KPADetails(
			 Sr_No int
			,Emp_id int
			,Qtr varchar(10)
			,Column_Name	varchar(500)
			,Column_Value Varchar(2000)
			,Row_No		int
			)
			
			--INSERT INTO #KPADetails
			--SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,[PERIOD],[PERIOD] +'_Start_Date', 
			--CONVERT(varchar(15),KPA_StartDate,103) FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			--INNER JOIN T0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status			

			--INSERT INTO #KPADetails
			--SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,[PERIOD],[PERIOD] +'_End_Date', 
			--CONVERT(varchar(15),KPA_EndDate,103) FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			--INNER JOIN T0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status			
								
			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,[Period],[Period] +'_KPI', 
			KPA_Content,1 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN T0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status			
			WHERE ISNULL(KPA_Content,'') <> '' and KPA_StartDate between @From_Date and @To_Date

			

			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,[Period],[Period] +'_KPI_Weightage', KPA_Weightage,2 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN T0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status		
			WHERE ISNULL(KPA_Content,'') <> '' and KPA_StartDate between @From_Date and @To_Date

			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,[Period],[Period] +'_KPI_Description', Remarks,3 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN T0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status		
			WHERE ISNULL(KPA_Content,'') <> ''	and KPA_StartDate between @From_Date and @To_Date			
			
			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,QTR_PERIOD,QTR_PERIOD +'_Date_Of_Submission_By_Employee', 
			CONVERT(varchar(15),Emp_ApprovedDate,103),4 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN V0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status	
			where KPA_StartDate between @From_Date and @To_Date		

			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,QTR_PERIOD,QTR_PERIOD +'_Date_Of_Approved_By_Manager', 
			CONVERT(varchar(15),Rm_ApprovedDate,103),5 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN V0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status	
			where KPA_StartDate between @From_Date and @To_Date		

			INSERT INTO #KPADetails
			SELECT ROW_NUMBER() OVER (PARTITION BY AE.Emp_Id,[Period] ORDER BY AE.Emp_Id),AE.Emp_Id,QTR_PERIOD,QTR_PERIOD +'_Status_Of_KPIs', 
			HI.InitiateStatus,6 FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
			INNER JOIN V0055_Hrms_Initiate_KPASetting HI WITH (NOLOCK) ON AE.Emp_Id=HI.Emp_Id AND AE.KPA_InitiateId=HI.KPA_InitiateId AND AE.[status]=HI.Initiate_Status	
			where KPA_StartDate between @From_Date and @To_Date		

			SELECT * INTO #Final_KPADetails FROM #KPADetails WHERE ISNULL(Column_Value,'') <> '' order by Row_No,EMP_ID
			--SELECT * FROM #Final_KPADetails
			--SELECT @columns = COALESCE(@columns + ',', '') + '[' + CAST(Column_Name AS VARCHAR(100)) + ']'
			--FROM #Final_KPADetails 
			--GROUP BY Column_Name

			SELECT @columns =  COALESCE(@columns + ',', '') + '[' + CAST(Column_Name AS VARCHAR(100)) + ']'				
			FROM	(SELECT ROW_NUMBER() OVER(ORDER BY Qtr,Row_No) AS ROW_ID,Column_Name 
					FROM	#Final_KPADetails
					GROUP BY Qtr,Row_No,Column_Name) T
			ORDER BY T.ROW_ID

			--ORDER BY Row_No
			--SELECT @columns
			--SELECT * FROM #KPADetails
			SET @query = 'SELECT Employee_Code,Employee_Name,Branch_Id,Dept_Id
			,Branch,Place_Of_Posting,Department,Designation,Grade,Manager_Code,Manager_Name,							
								SR_NO,'+ @columns +'
								FROM (SELECT 
										CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Employee_Code else '''' END Employee_Code																			
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Employee_Name else '''' END Employee_Name							
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Branch else '''' END Branch
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Place_Of_Posting else '''' END Place_Of_Posting
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Department else '''' END Department
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Designation else '''' END Designation
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Grade else '''' END Grade
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Manager_Code else '''' END Manager_Code	
										,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Manager_Name else '''' END Manager_Name	
										--,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Status_Of_KPIs else '''' END Status_Of_KPIs
										--,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Date_Of_Submission_By_Employee else '''' END Date_Of_Submission_By_Employee
										--,CASE WHEN ROW_NUMBER() OVER (PARTITION BY Employee_Code,Column_Name ORDER BY Employee_Code)=1 then Date_Of_Approved_By_Manager else '''' END Date_Of_Approved_By_Manager										
										,pd.Branch_Id,PD.DEPT_ID,PD.emp_id,SR_NO,Column_Value,Column_Name
										FROM #PMS_Details PD
										INNER JOIN #Final_KPADetails KP ON KP.EMP_ID=PD.EMP_ID		
										WHERE ISNULL(Column_Name,'''') <>''''
									) as s
								PIVOT
								(						 
									MAX(Column_Value)
									FOR [Column_Name] IN (' + @columns + ') 						
								)AS T ORDER BY EMP_ID,SR_NO' 
					print @query
			
					EXEC(@query)
		END
END

