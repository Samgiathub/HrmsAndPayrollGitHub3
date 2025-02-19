
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_SALES_DOWNLINE_SUMMARY]
	@CMP_ID AS NUMERIC,
	@MANAGER_EMP_ID AS NUMERIC,
	@Level as Numeric = 0,
	@MONTH			INTEGER,
	@YEAR			INTEGER,
	@WEEK_ORDER		VARCHAR(20) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	DECLARE @DOWN_EMP_ID NUMERIC
	DECLARE @DOWN_BRANCH_ID NUMERIC
	DECLARE @DOWN_SALESCODE  VARCHAR(50)
	
	if @WEEK_ORDER = ''	
	  Set @WEEK_ORDER = NULL
	
	IF OBJECT_ID('tempdb..#DOWNLINE') IS NULL
		BEGIN
			CREATE TABLE #DOWNLINE
			(
				MANAGER_ID	NUMERIC,
				EMP_ID		NUMERIC,
				BRANCH_ID	NUMERIC,
				SALES_CODE	VARCHAR(50),
				S_LEVEL		NUMERIC
			)
		END

		DECLARE CUR_DOWN CURSOR FOR
			SELECT		RD.EMP_ID , I.BRANCH_ID , I.SALES_CODE 
			FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
			INNER JOIN (
							SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							WHERE EFFECT_DATE <= GETDATE()
							GROUP BY EMP_ID
						) AS EMP_SUP ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE	
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = RD.Emp_ID	
			INNER JOIN (
							SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
							FROM T0095_INCREMENT I WITH (NOLOCK)
							INNER JOIN 
							(
								SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM T0095_INCREMENT I3 WITH (NOLOCK)
								WHERE I3.Increment_effective_Date <= GETDATE()
								GROUP BY I3.EMP_ID  
							) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
							WHERE I.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I.Cmp_ID = @CMP_ID
							GROUP BY I.emp_ID  
						) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
			WHERE RD.R_EMP_ID = @MANAGER_EMP_ID and RD.CMP_ID = @CMP_ID
			GROUP BY RD.EMP_ID , I.BRANCH_ID , I.SALES_CODE 
			ORDER BY RD.EMP_ID  
		OPEN CUR_DOWN
			FETCH NEXT FROM CUR_DOWN INTO @DOWN_EMP_ID ,@DOWN_BRANCH_ID, @DOWN_SALESCODE
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					IF @DOWN_SALESCODE = ''
						BEGIN
							if Not Exists(Select 1 From #DOWNLINE Where MANAGER_ID = @MANAGER_EMP_ID and EMP_ID = @DOWN_EMP_ID)
								BEGIN
									INSERT INTO #DOWNLINE 
									(MANAGER_ID , EMP_ID ,BRANCH_ID, SALES_CODE , S_LEVEL )
									VALUES
										(@MANAGER_EMP_ID , @DOWN_EMP_ID ,@DOWN_BRANCH_ID, @DOWN_SALESCODE , @Level)
									EXEC SP_SALES_DOWNLINE_SUMMARY @CMP_ID = @CMP_ID, @MANAGER_EMP_ID = @DOWN_EMP_ID , @Level = @Level , @MONTH = @MONTH , @YEAR = @YEAR , @WEEK_ORDER= @WEEK_ORDER
									--SET @Level = @Level + 1;
								End
						END
					ELSE
						BEGIN
							if Not Exists(Select 1 From #DOWNLINE Where MANAGER_ID = @MANAGER_EMP_ID and EMP_ID = @DOWN_EMP_ID)
								BEGIN
									INSERT INTO #DOWNLINE 
										(MANAGER_ID , EMP_ID ,BRANCH_ID, SALES_CODE , S_LEVEL )
									VALUES
										(@MANAGER_EMP_ID , @DOWN_EMP_ID ,@DOWN_BRANCH_ID, @DOWN_SALESCODE , @Level)
								End
							
						END
					
					FETCH NEXT FROM CUR_DOWN INTO @DOWN_EMP_ID ,@DOWN_BRANCH_ID, @DOWN_SALESCODE
				END
		CLOSE CUR_DOWN
		DEALLOCATE CUR_DOWN
	
	if (@Level = 1)
		BEGIN
			--NOW FETCHING THE TARGETS OF ALL EMPLOYEES
			
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
			
			INSERT INTO #WEEK_TARGET (Target_Tran_ID,Week_Tran_ID,Week_st_date,Sorting_No,Week_Target,Target_Amount)
			SELECT Target_Tran_ID,Week_Tran_ID,Week_st_date,Sorting_No,REPLACE((Week_Order + '_' + Target_Name), ' ', '_') As Week_Target ,Target_Amount
			FROM (
					SELECT	AT.Target_Tran_ID,Wm.Week_Tran_ID,WM.Week_st_date, WM.Sorting_No , WM.Week_Order,AT.Assigned_Target,Achieved_Target,Achieved_Percent 
					FROM	T0040_Sales_Week_Master WM WITH (NOLOCK)
					LEFT OUTER JOIN T0050_Sales_Assigned_Detail AT WITH (NOLOCK) ON WM.Week_Tran_ID=AT.Week_Tran_ID 
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
			DECLARE @ALIAS_COLS varchar(max);
			DECLARE @QUERY VARCHAR(MAX);
			
			SELECT @COLS = COALESCE (@COLS + ',','')  + Week_Target 
								FROM (
										SELECT ID, Week_Target, Target_Tran_ID FROM #WEEK_TARGET 
									  ) T 
								WHERE Target_Tran_ID = @Target_Tran_ID ORDER BY ID
			
			
			
			SELECT @ALIAS_COLS = COALESCE(@ALIAS_COLS + ',','') + DATA  + ' as [' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE( DATA , 'First_', ''), 'Second_', ''), 'Third_', ''), 'Fourth_', ''), 'Fifth_', ''),'Monthly','Week') + ']'
										 FROM DBO.SPLIT(@COLS, ',') T 
										 WHERE T.DATA <> ''
			
			IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL
				BEGIN
					DROP TABLE #RESULT
				END
			IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL
				BEGIN
					DROP TABLE #RESULT
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
							
							SELECT DM.MANAGER_ID , DM.EMP_ID , DM.BRANCH_ID , ST.SALES_CODE,DM.S_LEVEL,
							'+ @ALIAS_COLS + '
							INTO #SUMMARY
							FROM #RESULT RES
							INNER JOIN T0040_SALES_ASSIGNED_TARGET ST WITH (NOLOCK) ON RES.TARGET_TRAN_ID = ST.TARGET_TRAN_ID
							INNER JOIN T0040_SALES_ROUTE_MASTER SRM WITH (NOLOCK) ON SRM.ROUTE_ID = ST.ROUTE_ID
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = ST.BRANCH_ID
							LEFT OUTER JOIN #DOWNLINE DM ON DM.SALES_CODE = ST.SALES_CODE AND DM.BRANCH_ID = ST.BRANCH_ID
														
							SELECT Manager_ID , Emp_ID , Branch_ID , Sales_Code , S_LEVEL,
							SUM(Week_Assigned_Target) AS Week_Assigned_Target,SUM(Week_Achieved_Target) AS Week_Achieved_Target,(SUM(Week_Achieved_Percent)/Count(Week_Achieved_Percent)) as Week_Achieved_Percent
							FROM #SUMMARY
							GROUP BY MANAGER_ID , EMP_ID , BRANCH_ID , SALES_CODE , S_LEVEL
							
							
							;'		
			EXEC (@QUERY)
		END	
	Else if @Level = 2
		Begin
			SELECT SUM(SAD.Assigned_Target) as Assigned_Target,
			SUM(SAD.Achieved_Target) as Achieved_Target,
			Emp_ID FROM T0040_Sales_Assigned_Target SA WITH (NOLOCK) Inner join #DOWNLINE DL
			ON SA.Sales_Code = DL.SALES_CODE
			Inner JOIN T0050_Sales_Assigned_Detail SAD WITH (NOLOCK) ON SAD.Target_Tran_ID = SA.Target_Tran_ID
			LEFT OUTER JOIN	T0040_Sales_Week_Master WM WITH (NOLOCK) ON WM.Week_Tran_ID=SAD.Week_Tran_ID
			Where Target_Month = @MONTH AND Target_Year = @YEAR and WM.Week_Order = ISNULL(@WEEK_ORDER,WM.Week_Order) 
			Group by DL.EMP_ID
		End
  		 
END

