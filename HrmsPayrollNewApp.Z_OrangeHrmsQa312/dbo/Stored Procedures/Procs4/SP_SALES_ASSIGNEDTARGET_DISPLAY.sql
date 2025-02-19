

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 18-OCT-2016
-- Description:	DISPLAY THE IMPORTED TARGET
-- =============================================
CREATE PROCEDURE [dbo].[SP_SALES_ASSIGNEDTARGET_DISPLAY]
	@CMP_ID			NUMERIC,
	@MONTH			INTEGER,
	@YEAR			INTEGER,
	@BRANCH			VARCHAR(MAX) = '',
	@CONSTRAINT		VARCHAR(MAX) = '',
	@WEEK_ORDER		VARCHAR(20) = '',		--THIS PARAMETER WILL PASS FROM ESS SIDE
	@ROUTE_ID		NUMERIC(18,0) = 0
	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	

	DECLARE @FROM_DATE AS DATETIME
	DECLARE @TO_DATE AS DATETIME
	
	SET @FROM_DATE = dbo.GET_MONTH_ST_DATE(@MONTH , @YEAR)
	SET @TO_DATE = dbo.GET_MONTH_END_DATE(@MONTH , @YEAR)
	
	IF @WEEK_ORDER = ''
		SET @WEEK_ORDER = NULL

    IF OBJECT_ID('tempdb..#WEEK_TARGET') IS NOT NULL
		BEGIN
			DROP TABLE #WEEK_TARGET
		END

	CREATE TABLE #WEEK_TARGET
	(
		ID				INT IDENTITY,
		Target_Tran_ID	NUMERIC,
		Week_Tran_ID	NUMERIC,
		Week_st_date	DATETIME,
		Sorting_No		INT,
		Week_Target		VARCHAR(128),
		Target_Amount	NUMERIC(18,2)
	)
	
	 IF OBJECT_ID('tempdb..#RANKING') IS NOT NULL
		BEGIN
			DROP TABLE #RANKING_T
		END
		CREATE TABLE #RANKING_T
		(
			Target_Tran_Id			NUMERIC,
			Branch_Name				VARCHAR(50),
			Sales_Code				VARCHAR(50),
			Route_Name				VARCHAR(50),
			Route_Type				VARCHAR(10),
			Full_Route_Name			VARCHAR(100)
		)
	
	
	INSERT INTO #WEEK_TARGET (Target_Tran_ID,Week_Tran_ID,Week_st_date,Sorting_No,Week_Target,Target_Amount)
	SELECT Target_Tran_ID,Week_Tran_ID,Week_st_date,Sorting_No,REPLACE((Week_Order + '_' + Target_Name), ' ', '_') As Week_Target ,Target_Amount
	FROM (
			SELECT	AT.Target_Tran_ID,Wm.Week_Tran_ID,WM.Week_st_date, WM.Sorting_No , WM.Week_Order,AT.Assigned_Target,Achieved_Target,Achieved_Percent 
			FROM	T0040_Sales_Week_Master WM WITH (NOLOCK)
			LEFT OUTER JOIN T0050_Sales_Assigned_Detail AT ON WM.Week_Tran_ID=AT.Week_Tran_ID 
			Where	W_Month = @MONTH AND W_Year = @YEAR and AT.Cmp_ID = @CMP_ID and WM.Week_Order = ISNULL(@WEEK_ORDER,WM.Week_Order)
		 ) P
	UNPIVOT
		(
			Target_Amount FOR Target_Name IN (Assigned_Target,Achieved_Target,Achieved_Percent)
		) AS UP
	ORDER BY Target_Tran_ID,SORTING_NO , Week_st_date
	

	DECLARE @Target_Tran_ID INT
	SELECT TOP 1 @Target_Tran_ID = Target_Tran_ID 
									FROM (
											SELECT Target_Tran_ID, COUNT(1) AS T_COUNT FROM #WEEK_TARGET GROUP BY Target_Tran_ID
										  ) T ORDER BY T_COUNT DESC

	DECLARE @COLS VARCHAR(MAX);
	SELECT @COLS = COALESCE (@COLS + ',','')  + Week_Target 
						FROM (
								SELECT ID, Week_Target, Target_Tran_ID FROM #WEEK_TARGET 
							  ) T 
						WHERE Target_Tran_ID = @Target_Tran_ID ORDER BY ID
	
	DECLARE @QUERY VARCHAR(MAX);
	
	IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL
		BEGIN
			DROP TABLE #RESULT
		END
		

	IF 	@WEEK_ORDER IS NULL --ADMIN SIDE CODE
		BEGIN
			DECLARE @ALIAS_COLS varchar(max);
			SELECT @ALIAS_COLS = COALESCE(@ALIAS_COLS + ',','') + DATA  + ' AS [' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE( REPLACE(DATA, '_',' '), 'First', '1st '), 'Second', '2nd '), 'Third', '3rd'), 'Fourth', '4th '), 'Fifth', '5th '), 'Assigned Target', 'Asgn Trgt'), 'Achieved Target' , 'Achv Trgt'), 'Achieved Percent' , 'Achv %') + ']'
								 FROM DBO.SPLIT(@COLS, ',') T 
								 WHERE T.DATA <> ''
		END
	ELSE					--ESS SIDE CODE
		BEGIN
			SELECT @ALIAS_COLS = COALESCE(@ALIAS_COLS + ',','') + DATA  + ' as [' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE( DATA , 'First_', ''), 'Second_', ''), 'Third_', ''), 'Fourth_', ''), 'Fifth_', ''),'Monthly','Week') + ']'
								 FROM DBO.SPLIT(@COLS, ',') T 
								 WHERE T.DATA <> ''
		END
	
		
	DECLARE @BRANCH_JOIN VARCHAR(MAX);
	IF (ISNULL(@BRANCH, '') <> '')
		SET @BRANCH_JOIN = 'INNER JOIN (
										SELECT DATA FROM DBO.SPLIT(''' + @BRANCH + ''' , ''#'')
										) T ON T.Data = ST.Branch_ID'
	ELSE
		SET @BRANCH_JOIN = '';
	
			
	DECLARE @WHERE VARCHAR(MAX);
	IF (ISNULL(@CONSTRAINT, '') <> '') 
		SET @WHERE = 'WHERE SALES_CODE IN (SELECT DISTINCT SALES_CODE FROM T0040_SALES_ASSIGNED_TARGET WITH (NOLOCK) WHERE SALES_CODE LIKE ''%' + @CONSTRAINT + '%'')'
	ELSE
		SET @WHERE = '';
		
	IF (ISNULL(@ROUTE_ID, 0) <> 0)
		IF ISNULL(@WHERE,'') <> ''
			SET @WHERE = @WHERE + ' AND SRM.ROUTE_ID = '+ CAST(@ROUTE_ID as varchar(5)) +''
		ELSE
			SET @WHERE = 'WHERE SRM.ROUTE_ID = '+ CAST(@ROUTE_ID as varchar(5)) +'';
	

	DECLARE @COM_COLS VARCHAR(MAX)
	SET @COM_COLS = NULL
	
	IF CHARINDEX('[Week_Achieved_Percent]', @ALIAS_COLS) > 0	--Week_Achieved_Percent is a Column Name , that is only Generated when ESS Page is Loaded
		BEGIN	
			SET @COM_COLS = ' DENSE_RANK() OVER (ORDER BY SUM(Week_Achieved_Percent)/COUNT(Week_Achieved_Percent) DESC) as Sales_Rank , 
							  CAST(SUM(Week_Achieved_Percent)/COUNT(Week_Achieved_Percent) as Decimal(6,2)) as Avg_Percent'
		END
						
	SET @QUERY = 'SELECT * INTO #RESULT FROM
					(
						SELECT * FROM
							(
								SELECT TARGET_TRAN_ID ,TARGET_AMOUNT,WEEK_TARGET FROM #WEEK_TARGET
							) T
						PIVOT
							(
								SUM(TARGET_AMOUNT) FOR WEEK_TARGET IN (' + @COLS + ')
							) AS DATA
					) AS TAB;
					
					SELECT ST.TARGET_TRAN_ID as [Target Tran Id],BM.BRANCH_NAME AS [Branch Name], ST.SALES_CODE as [Sales Code],
					SRM.ROUTE_NAME as Route_Name , SRM.ROUTE_TYPE as Route_Type , SRM.ROUTE_NAME + '''+ ' - ( ''+' + ' '+ 'SRM.ROUTE_TYPE '+'+' + ''' )''' +' AS Full_Route_Name, 
					'+ @ALIAS_COLS + ' FROM #RESULT RES
					INNER JOIN T0040_SALES_ASSIGNED_TARGET ST WITH (NOLOCK) ON RES.TARGET_TRAN_ID = ST.TARGET_TRAN_ID
					INNER JOIN T0040_SALES_ROUTE_MASTER SRM WITH (NOLOCK) ON SRM.ROUTE_ID = ST.ROUTE_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = ST.BRANCH_ID
					'+ @BRANCH_JOIN + '
					'+ @WHERE +';'
/*
			IF @COM_COLS IS NOT NULL		--TO CALCULATE RANK OF AN EMPLOYEE , ONLY FOR ESS PANEL
				SET @QUERY = @QUERY + 'SELECT 
										' + @COM_COLS + ', BM.BRANCH_ID AS BRANCH_ID , BM.BRANCH_NAME AS BRANCH_NAME, ST.SALES_CODE as SALES_CODE 
										FROM (SELECT TARGET_TRAN_ID,'+ @ALIAS_COLS + ' FROM #RESULT) RES
										INNER JOIN T0040_SALES_ASSIGNED_TARGET ST ON RES.TARGET_TRAN_ID = ST.TARGET_TRAN_ID
										INNER JOIN T0030_BRANCH_MASTER BM ON BM.BRANCH_ID = ST.BRANCH_ID					
										GROUP BY BM.BRANCH_ID ,BM.BRANCH_NAME,ST.SALES_CODE;
										'

		*/
	--PRINT @QUERY
	EXEC (@QUERY)

END




