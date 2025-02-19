

 
 ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0500_Lead_Dashboard_Details]
		 @CmpID  numeric(18,0) = 0
		,@LoginID  numeric(18,0) = 0
		,@EmpID  numeric(18,0) = 0
		,@RoleTypeID  numeric(18,0) = 1
		,@SearchText varchar(64) = ''
		,@MonthYear varchar(32) = ''
		,@StrType char(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-- @RoleTypeID  1 For Self 
	-- @RoleTypeID  2 For My Team
	
	---- @StrType A ==== Get Dashboard Details on page Load
	---- @StrType B ==== Get Employee Self/Team Lead Details Dashboard
	---- @StrType C ==== For Employee wise Monthly Lead Status Details
	---- @StrType P ==== For Total Lead Records
	---- @StrType Q ==== For Success Lead Records
	---- @StrType R ==== For Follow Up Lead Records
	---- @StrType S ==== For Failed Lead Records
	---- @StrType T ==== For Today Follow Up Lead Records
	---- @StrType U ==== For Today Success Lead Records
	---- @StrType W ==== Binding Employee DropDown
	---- @StrType X ==== Binding Month - Year Dropdownlist
	
	Declare @FROM_DATE DateTime
	Declare @TO_DATE DateTime
	Declare @TEMP_FROM_DATE Datetime
	Declare @DropDownDATE Datetime
	DECLARE @Month int
	DECLARE @Year int

	--SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-5,GETDATE())),YEAR(DATEADD(MM,-5,GETDATE())))
	--SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))
	
	IF @MonthYear = '' 
		SET @DropDownDATE = GETDATE()
	else 
		SET @DropDownDATE = CAST(LEFT(@MonthYear,3) + ' 01 ' + RIGHT(@MonthYear,4) AS DATETIME)
		
	SET @Month = MONTH(@DropDownDATE)
	SET @Year = YEAR(@DropDownDATE)
	
	SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-5,@DropDownDATE)),YEAR(DATEADD(MM,-5,@DropDownDATE)))
	SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@DropDownDATE),YEAR(@DropDownDATE))

	If Object_ID('tempdb..#EmpCons') is not null
		Drop table #EmpCons

	Create Table #EmpCons
	(
		Emp_ID Numeric
	)

	If @RoleTypeID = 1
	   Begin
			Insert into #EmpCons Values(@LoginID)
	   End
	Else if @RoleTypeID = 2
	   Begin
			
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
				(
					SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) --ON EM.Emp_ID = RD.Emp_ID
					WHERE	EM.Emp_ID = @LoginID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
					
					UNION ALL
					
					SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
					INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
					INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
				)
	
			Insert into #EmpCons
			SELECT EMP_ID FROM Q
			 
	   End

	
	IF OBJECT_ID('TEMPDB..#LEAD_APP_DETAILS_MONTH_WISE') IS NOT NULL
		BEGIN
			DROP TABLE #LEAD_APP_DETAILS_MONTH_WISE
		END

	 CREATE TABLE #LEAD_APP_DETAILS_MONTH_WISE
	 (
		 MONTH_NAME Varchar(100),
		 Lead_Month Numeric(5,0),
		 Lead_Year Numeric(5,0),
		 Lead_Count Numeric(18,0),
		 Lead_Status_ID Numeric(5,0),
		 Lead_Status_Name Varchar(100)
	 )
	 
	 
	IF OBJECT_ID('TEMPDB..#Emp_LEAD_APP_DETAILS_MONTH_WISE') IS NOT NULL
		BEGIN
			DROP TABLE #Emp_LEAD_APP_DETAILS_MONTH_WISE
		END
 
	 CREATE TABLE #Emp_LEAD_APP_DETAILS_MONTH_WISE
	 (
		 MONTH_NAME Varchar(100),
		 Lead_Month Numeric(5,0),
		 Lead_Year Numeric(5,0),
		 Lead_Count Numeric(18,0),
		 Lead_Status_ID Numeric(5,0),
		 Lead_Status_Name Varchar(100)
	 )
			 

	IF @StrType = 'A'		--==== Get Dashboard Details on page Load
		BEGIN
			
			SELECT ISNULL(SUM(tmp.Total_Lead),0) AS 'Total_Lead'
					   ,ISNULL(SUM(tmp.Success_Lead),0) AS 'Success_Lead'
					   ,ISNULL(SUM(tmp.Followup_Lead),0) AS 'Followup_Lead'
					   ,ISNULL(SUM(tmp.Failed_Lead),0) AS 'Failed_Lead'
					   ,ISNULL(SUM(tmp.Today_Follow_Lead),0) AS 'Today_Follow_Lead'
					   ,ISNULL(SUM(tmp.Today_Success_Lead),0) AS 'Today_Success_Lead'
			FROM (
				SELECT COUNT(TLA.Lead_App_ID) AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Available')
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',COUNT(TLA.Lead_App_ID) AS 'Success_Lead',0 AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END								
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
				AND ISNULL(TLA.Lead_Status_ID,0) = 2
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',COUNT(TLA.Lead_App_ID) AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
				AND ISNULL(TLA.Lead_Status_ID,0) = 1
				 		
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
							,COUNT(TLA.Lead_App_ID) AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'					  
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Failed')
				AND ISNULL(TLA.Lead_Status_ID,0) = 3
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
					,0 AS 'Failed_Lead',COUNT(TLA.Lead_App_ID) AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				AND CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
				AND ISNULL(TLA.Lead_Status_ID,0) = 1
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead',0 AS 'Failed_Lead'
							,0 AS 'Today_Follow_Lead',COUNT(TLA.Lead_App_ID) AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				--AND MONTH(TLA.Visit_Date) = MONTH(GETDATE()) AND YEAR(TLA.Visit_Date) = YEAR(GETDATE())
				WHERE CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Visit_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
				AND ISNULL(TLA.Lead_Status_ID,0) = 2
				
			) tmp
									 
			-------------============For Monthly Lead Status Details=============-------
			 
			 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #LEAD_APP_DETAILS_MONTH_WISE
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						0,
						LS.Lead_Status_ID,
						LS.Lead_Status_Name
						From T0500_Lead_Status LS WITH (NOLOCK)
						Where Cmp_ID = @CmpID						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END


			UPDATE LAM
				SET LAM.Lead_Count = LeadCount
			FROM #LEAD_APP_DETAILS_MONTH_WISE LAM INNER JOIN
				(
					SELECT COUNT(LA.Lead_App_ID) as LeadCount, 
						   Month(LA.Visit_Date) as LeadMonth,
						   Year(LA.Visit_Date) as LeadYear,
						   LA.Lead_Status_ID
					From T0501_Lead_Application LA WITH (NOLOCK)
					Inner Join T0500_Lead_Status LS WITH (NOLOCK) ON LS.Lead_Status_ID = LA.Lead_Status_ID
					INNER JOIN #EmpCons EC ON LA.Emp_ID = EC.Emp_ID
					Where LA.Visit_Date >= @FROM_DATE AND LA.Visit_Date <= @TO_DATE --AND LA.CMP_ID = @CmpID
					--AND LA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE LA.Emp_ID END				
					GROUP BY Month(LA.Visit_Date),Year(LA.Visit_Date),LA.Lead_Status_ID
				) AS T1
			ON T1.LeadMonth = LAM.Lead_Month AND T1.LeadYear = LAM.Lead_Year and T1.Lead_Status_ID = LAM.Lead_Status_ID
			
			SELECT  MONTH_NAME, Lead_Month, Lead_Year, Lead_Count, Lead_Status_ID, Lead_Status_Name 
			FROM #LEAD_APP_DETAILS_MONTH_WISE
			--------------==========================For Monthly Lead Status Details --End==========-----------
				
			
									 
			-------------============For Employee wise Monthly Lead Status Details=============-------
			 
			
			--SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-2,GETDATE())),YEAR(DATEADD(MM,-2,GETDATE())))
			--SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))
			
			SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-2,@DropDownDATE)),YEAR(DATEADD(MM,-2,@DropDownDATE)))
			SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@DropDownDATE),YEAR(@DropDownDATE))
	
	 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #Emp_LEAD_APP_DETAILS_MONTH_WISE
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						0,
						LS.Lead_Status_ID,
						LS.Lead_Status_Name
						From T0500_Lead_Status LS WITH (NOLOCK)
						Where Cmp_ID = @CmpID						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END


			UPDATE LAM
				SET LAM.Lead_Count = LeadCount
			FROM #Emp_LEAD_APP_DETAILS_MONTH_WISE LAM INNER JOIN
				(
					SELECT COUNT(LA.Lead_App_ID) as LeadCount, 
						   Month(LA.Visit_Date) as LeadMonth,
						   Year(LA.Visit_Date) as LeadYear,
						   LA.Lead_Status_ID
					From T0501_Lead_Application LA WITH (NOLOCK)
					Inner Join T0500_Lead_Status LS WITH (NOLOCK) ON LS.Lead_Status_ID = LA.Lead_Status_ID
					INNER JOIN #EmpCons EC ON LA.Emp_ID = EC.Emp_ID
					Where LA.Visit_Date >= @FROM_DATE AND LA.Visit_Date <= @TO_DATE --AND LA.CMP_ID = @CmpID
					--AND LA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE LA.Emp_ID END				
					GROUP BY Month(LA.Visit_Date),Year(LA.Visit_Date),LA.Lead_Status_ID
				) AS T1
			ON T1.LeadMonth = LAM.Lead_Month AND T1.LeadYear = LAM.Lead_Year and T1.Lead_Status_ID = LAM.Lead_Status_ID
			
			SELECT  MONTH_NAME, Lead_Month, Lead_Year, Lead_Count, Lead_Status_ID, Lead_Status_Name 
			FROM #Emp_LEAD_APP_DETAILS_MONTH_WISE
			--------------==========================For Employee wise Monthly Lead Status Details --End==========-----------
				
				
		END
	ELSE IF @StrType = 'B'----------==== Get Employee Self/Team Lead Details Dashboard ========-------------
		BEGIN
			
			SELECT ISNULL(SUM(tmp.Total_Lead),0) AS 'Total_Lead'
					   ,ISNULL(SUM(tmp.Success_Lead),0) AS 'Success_Lead'
					   ,ISNULL(SUM(tmp.Followup_Lead),0) AS 'Followup_Lead'
					   ,ISNULL(SUM(tmp.Failed_Lead),0) AS 'Failed_Lead'
					   ,ISNULL(SUM(tmp.Today_Follow_Lead),0) AS 'Today_Follow_Lead'
					   ,ISNULL(SUM(tmp.Today_Success_Lead),0) AS 'Today_Success_Lead'
			FROM (
				SELECT COUNT(TLA.Lead_App_ID) AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Available')
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',COUNT(TLA.Lead_App_ID) AS 'Success_Lead',0 AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
				AND ISNULL(TLS.Lead_Status_ID,0) = 2
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',COUNT(TLA.Lead_App_ID) AS 'Followup_Lead'
						,0 AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
				AND ISNULL(TLS.Lead_Status_ID,0) = 1
				 		
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
							,COUNT(TLA.Lead_App_ID) AS 'Failed_Lead',0 AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'					  
				FROM T0501_Lead_Application TLA WITH (NOLOCK) 
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Failed')
				AND ISNULL(TLS.Lead_Status_ID,0) = 3
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead'
					,0 AS 'Failed_Lead',COUNT(TLA.Lead_App_ID) AS 'Today_Follow_Lead',0 AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
				AND CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
				AND ISNULL(TLS.Lead_Status_ID,0) = 1
				
				UNION ALL
				
				SELECT 0 AS 'Total_Lead',0 AS 'Success_Lead',0 AS 'Followup_Lead',0 AS 'Failed_Lead'
							,0 AS 'Today_Follow_Lead',COUNT(TLA.Lead_App_ID) AS 'Today_Success_Lead'
				FROM T0501_Lead_Application TLA WITH (NOLOCK)
				INNER JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
				INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
				--WHERE TLA.Cmp_ID = @CmpID
				--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END				
				--AND MONTH(TLA.Visit_Date) = MONTH(GETDATE()) AND YEAR(TLA.Visit_Date) = YEAR(GETDATE())
				WHERE CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Visit_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
				--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
				AND ISNULL(TLS.Lead_Status_ID,0) = 2
				
			) tmp
									 
			-------------============For Monthly Lead Status Details=============-------
			 
			 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #LEAD_APP_DETAILS_MONTH_WISE
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						0,
						LS.Lead_Status_ID,
						LS.Lead_Status_Name
						From T0500_Lead_Status LS WITH (NOLOCK)
						Where Cmp_ID = @CmpID						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END


			UPDATE LAM
				SET LAM.Lead_Count = LeadCount
			FROM #LEAD_APP_DETAILS_MONTH_WISE LAM INNER JOIN
				(
					SELECT COUNT(LA.Lead_App_ID) as LeadCount, 
						   Month(LA.Visit_Date) as LeadMonth,
						   Year(LA.Visit_Date) as LeadYear,
						   LA.Lead_Status_ID
					From T0501_Lead_Application LA WITH (NOLOCK)
					Inner Join T0500_Lead_Status LS WITH (NOLOCK) ON LS.Lead_Status_ID = LA.Lead_Status_ID
					INNER JOIN #EmpCons EC ON LA.Emp_ID = EC.Emp_ID
					Where LA.Visit_Date >= @FROM_DATE AND LA.Visit_Date <= @TO_DATE --AND LA.CMP_ID = @CmpID
					--AND LA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE LA.Emp_ID END				
					GROUP BY Month(LA.Visit_Date),Year(LA.Visit_Date),LA.Lead_Status_ID
				) AS T1
			ON T1.LeadMonth = LAM.Lead_Month AND T1.LeadYear = LAM.Lead_Year and T1.Lead_Status_ID = LAM.Lead_Status_ID
			
			SELECT  MONTH_NAME, Lead_Month, Lead_Year, Lead_Count, Lead_Status_ID, Lead_Status_Name 
			FROM #LEAD_APP_DETAILS_MONTH_WISE
			--------------==========================For Monthly Lead Status Details --End==========-----------
		END
	ELSE IF @strType = 'C'-------==== For Employee wise Monthly Lead Status Details ============---------
		BEGIN
			-------------============Employee DropDown Change then this @strType will call=============-------
			
			DELETE FROM #EmpCons
			
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
				(
					SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) --ON EM.Emp_ID = RD.Emp_ID
					WHERE	EM.Emp_ID = @EmpID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
					
					UNION ALL
					
					SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0090_EMP_REPORTING_DETAIL RD  WITH (NOLOCK)
					INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
					INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
				)
	
			Insert into #EmpCons
			SELECT EMP_ID FROM Q
			
			--SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-2,GETDATE())),YEAR(DATEADD(MM,-2,GETDATE())))
			--SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))		 
			
			SET @FROM_DATE = DBO.GET_MONTH_ST_DATE(MONTH(DATEADD(MM,-2,@DropDownDATE)),YEAR(DATEADD(MM,-2,@DropDownDATE)))
			SET @TO_DATE  =  DBO.GET_MONTH_END_DATE(MONTH(@DropDownDATE),YEAR(@DropDownDATE))
	 
			 SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT INTO #Emp_LEAD_APP_DETAILS_MONTH_WISE
						SELECT  DISTINCT
						CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)) + '-' + CAST(YEAR(@TEMP_FROM_DATE) AS VARCHAR(4)),
						MONTH(@TEMP_FROM_DATE),
						YEAR(@TEMP_FROM_DATE),
						0,
						LS.Lead_Status_ID,
						LS.Lead_Status_Name
						From T0500_Lead_Status LS WITH (NOLOCK)
						Where Cmp_ID = @CmpID						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
			UPDATE LAM
				SET LAM.Lead_Count = LeadCount
			FROM #Emp_LEAD_APP_DETAILS_MONTH_WISE LAM INNER JOIN
				(
					SELECT COUNT(LA.Lead_App_ID) as LeadCount, 
						   Month(LA.Visit_Date) as LeadMonth,
						   Year(LA.Visit_Date) as LeadYear,
						   LA.Lead_Status_ID
					From T0501_Lead_Application LA WITH (NOLOCK)
					Inner Join T0500_Lead_Status LS WITH (NOLOCK) ON LS.Lead_Status_ID = LA.Lead_Status_ID
					INNER JOIN #EmpCons EC ON LA.Emp_ID = EC.Emp_ID
					Where LA.Visit_Date >= @FROM_DATE AND LA.Visit_Date <= @TO_DATE --AND LA.CMP_ID = @CmpID
					--AND LA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE LA.Emp_ID END				
					GROUP BY Month(LA.Visit_Date),Year(LA.Visit_Date),LA.Lead_Status_ID
				) AS T1
			ON T1.LeadMonth = LAM.Lead_Month AND T1.LeadYear = LAM.Lead_Year and T1.Lead_Status_ID = LAM.Lead_Status_ID
			
			SELECT  MONTH_NAME, Lead_Month, Lead_Year, Lead_Count, Lead_Status_ID, Lead_Status_Name 
			FROM #Emp_LEAD_APP_DETAILS_MONTH_WISE
			--------------==========================For Employee wise Monthly Lead Status Details --End==========-----------
				
		END
			
	ELSE IF @StrType = 'P'	--------======Total Lead======----------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'

			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Failed')
		END
	ELSE IF @StrType = 'Q'	-----------======== Success Lead===========----------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'
			
			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
			AND ISNULL(TLS.Lead_Status_ID,0) = 2
		END
	ELSE IF @StrType = 'R'	-----------=========== Follow Up Lead ===========------------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'

			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
			AND ISNULL(TLS.Lead_Status_ID,0) = 1
		END
	ELSE IF @StrType = 'S'	-----------=========== Failed Lead ===========------------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'

			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			--AND TLA.Emp_ID = CASE WHEN ISNULL(@RoleTypeID,0) = 1 THEN @LoginID ELSE TLA.Emp_ID END
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Failed')
			AND ISNULL(TLS.Lead_Status_ID,0) = 3			
		END
	ELSE IF @StrType = 'T'	-----------=========== Today's Follow Up Lead ===========------------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'

			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			AND CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Followup')
			AND ISNULL(TLS.Lead_Status_ID,0) = 1
		END
	ELSE IF @StrType = 'U'	-----------=========== Today's Success Lead ===========------------
		BEGIN
			SELECT ISNULL(TEM.Alpha_Emp_Code,0) AS 'Employee Code', ISNULL(TEM.Emp_Full_Name,'') AS 'Employee Name' 
				, ISNULL(TLA.Cust_Name,'') AS 'Customer', ISNULL(TLA.Cust_City,'') AS 'City'
				, ISNULL(TLA.Cust_State,'') AS 'State', ISNULL(TLA.Cust_Mobile,0) AS 'Mobile'
				, ISNULL(TLA.Cust_Pincode,0) AS 'Pincode', ISNULL(TLA.Cust_Address,'') AS 'Address'
				, ISNULL(TLA.Cust_Email,'') AS 'Email'
				, ISNULL(TLT.Lead_Type_Name,'') AS 'Lead Type', ISNULL(TVT.Visit_Type_Name,'') AS 'Visit Type'
				, ISNULL(TLP.Lead_Product_Name,'') AS 'Product Type'
				, (CASE WHEN ISNULL(TLA.Visit_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Visit_Date,103) END) AS 'Visit Date'
				, ISNULL(TLS.Lead_Status_Name,'') AS 'Status'
				, (CASE WHEN ISNULL(TLA.Follow_Up_Date,'') = '1900-01-01 00:00.000' THEN '' ELSE CONVERT(VARCHAR(11),TLA.Follow_Up_Date,103) END) AS 'Follow Up Date'				
				, ISNULL(TLA.Cust_PANNO,'') AS 'Pan NO'
				, ISNULL(TLA.Collected_Amt,0) AS 'Amount', ISNULL(TLA.Remarks,'') AS 'Remarks'

			FROM T0501_Lead_Application TLA WITH (NOLOCK)
			LEFT JOIN T0500_Lead_Type TLT WITH (NOLOCK) ON TLA.Lead_Type_ID = TLT.Lead_Type_ID
			LEFT JOIN T0500_Lead_Product TLP WITH (NOLOCK) ON TLA.Lead_Product_ID = TLP.Lead_Product_ID
			LEFT JOIN T0500_Lead_Visit_Type TVT WITH (NOLOCK) ON TLA.Visit_Type_ID = TVT.Visit_Type_ID
			LEFT JOIN T0500_Lead_Status TLS WITH (NOLOCK) ON TLA.Lead_Status_ID = TLS.Lead_Status_ID
			INNER JOIN #EmpCons EC ON TLA.Emp_ID = EC.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TLA.Emp_ID = TEM.Emp_ID
			
			--WHERE TLA.Cmp_ID = @CmpID
			WHERE MONTH(TLA.Visit_Date) = @Month AND YEAR(TLA.Visit_Date) = @Year
			AND CONVERT(DATETIME,CONVERT(VARCHAR(11),TLA.Visit_Date,103),103) = CONVERT(DATETIME,CONVERT(VARCHAR(11),GETDATE(),103),103)
			--AND UPPER(ISNULL(TLS.Lead_Status_Name,'')) = Upper('Success')
			AND ISNULL(TLS.Lead_Status_ID,0) = 2
		END
		
	ELSE IF @StrType = 'W'	-----------=========== Bind Employee DropDwon list ===========------------
		BEGIN
			
			;WITH Q(CMP_ID,EMP_ID, R_EMP_ID, R_LEVEL,Alpha_Emp_Code,Emp_Full_NAME) AS
				(
					SELECT	EM.CMP_ID,EM.Emp_ID,CAST(0 AS NUMERIC) as R_Emp_ID, CAST(1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0080_EMP_MASTER EM WITH (NOLOCK) --ON EM.Emp_ID = RD.Emp_ID
					WHERE	EM.Emp_ID = @LoginID AND(EM.Emp_Left_Date IS NULL or EM.Emp_Left <> 'Y')
					
					UNION ALL
					
					SELECT	RD.CMP_ID,RD.Emp_ID,RD.R_Emp_ID, CAST(Q.R_LEVEL + 1 AS NUMERIC) AS R_LEVEL,EM.Alpha_Emp_Code,EM.Emp_Full_Name
					FROM T0090_EMP_REPORTING_DETAIL RD  WITH (NOLOCK)
					INNER JOIN V0090_EMP_REP_DETAIL_MAX EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE AND RD.Row_ID = EMP_SUP.Row_ID
					INNER JOIN Q ON RD.R_Emp_ID=Q.Emp_ID	
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = RD.Emp_ID
				)
							
			SELECT EMP_ID,Alpha_Emp_Code + ' - ' + Emp_Full_NAME AS 'Employee' FROM Q
			ORDER BY Alpha_Emp_Code,Emp_Full_NAME
		END
	ELSE IF @StrType = 'X'---------------==========Bind Month - Year Dropdown List==========-------------
		BEGIN
						
			Set @From_Date = DATEADD(mm,-11,GetDate())
			Set @To_Date = GetDate()
			
			;with cte as (
						  select convert(date,left(convert(varchar,@From_Date,112),6) + '01') startDate,
								 month(convert(date,left(convert(varchar,@From_Date,112),6) + '01')) LeadMonth, 
								 year(convert(date,left(convert(varchar,@From_Date,112),6) + '01')) LeadYear,
								 month(@From_Date) n 
						  union all
						  select dateadd(month,n,convert(date,convert(varchar,year(@From_Date)) + '0101')) startDate,
								 month(dateadd(month,n,convert(date,convert(varchar,year(@From_Date)) + '0101'))) LeadMonth, 
								 year(dateadd(month,n,convert(date,convert(varchar,year(@From_Date)) + '0101'))) LeadYear,
								(n+1) n
						  from cte
						  where n < month(@From_Date) + datediff(month,@From_Date,@To_Date)
						)
			Select ROW_NUMBER() OVER(ORDER BY n) as 'ID', LEFT(dbo.F_GET_MONTH_NAME(LeadMonth),3) + '-' + CAST(LeadYear AS VARCHAR(4)) AS 'Month' From cte
		END
END



