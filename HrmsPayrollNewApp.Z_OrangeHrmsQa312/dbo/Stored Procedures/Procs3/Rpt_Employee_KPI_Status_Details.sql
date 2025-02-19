---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Employee_KPI_Status_Details]
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
	,@Constraint	varchar(MAX)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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

	CREATE TABLE #finalDetail
	(	
		 Sr_No					INT
		,Emp_Id					NUMERIC(18,0)
		,Branch_Id				NUMERIC(18,0)
		,Dept_Id				NUMERIC(18,0)
		,Employee_Code			VARCHAR(50)
		,Employee_Name			VARCHAR(250)
		,Branch					VARCHAR(350)
		,Category				VARCHAR(350)
		,Department				VARCHAR(350)
		,Designation			VARCHAR(350)
		,Grade					VARCHAR(350)
		,Manager_Code			VARCHAR(50)
		,Manager_Name			VARCHAR(250)
		,Qtr_Period				VARCHAR(10)
		,[Start_Date]			VARCHAR(15)
		,[End_Date]				VARCHAR(15)
		,Status_Of_KPIs			VARCHAR(150)		
		,Date_Of_Submission_By_Employee	VARCHAR(15)
		,Date_Of_Approved_By_Manager	VARCHAR(15)
	)	
	
	--DECLARE @KPA_ALIAS AS VARCHAR(100)
	--SELECT @KPA_ALIAS=Alias FROM T0040_CAPTION_SETTING WHERE Cmp_Id=@CMP_ID AND AND Caption='KPA'
	
	INSERT INTO #finalDetail
	SELECT DISTINCT  ROW_NUMBER() OVER (ORDER BY E.Emp_ID),E.Emp_ID,E.Branch_ID,EM.Dept_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Branch_Name,EM.Cat_Name,EM.Dept_Name,EM.Desig_Name,EM.Grd_Name,
	left(HI.Manager_Name,CHARINDEX('-',HI.Manager_Name)-1),SUBSTRING(HI.Manager_Name,CHARINDEX('-',HI.Manager_Name)+1,LEN(HI.Manager_Name)),
	hi.QTR_PERIOD,CONVERT(varchar(15),hi.KPA_StartDate,103),CONVERT(varchar(15),hi.KPA_EndDate,103),HI.InitiateStatus,CONVERT(varchar(15),Emp_ApprovedDate,103),CONVERT(varchar(15),Rm_ApprovedDate,103)
	FROM  #Emp_Cons E INNER JOIN
		  V0060_HRMS_EMP_MASTER_INCREMENT_GET EM on EM.Emp_ID = E.Emp_ID INNER JOIN
		  V0055_Hrms_Initiate_KPASetting HI ON HI.Emp_Id=E.Emp_ID
	WHERE HI.KPA_StartDate >= @From_Date and HI.KPA_EndDate <= @To_Date and HI.Cmp_ID=@CMP_ID
	ORDER BY Alpha_Emp_Code 

	SELECT  * FROM #finalDetail
	DROP TABLE #finalDetail
END

