
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P_RPT_LEAVE_BALANCE_WITH_GRATUITY]
	@CMP_ID				Numeric
	,@From_Date			DATETIME
	,@To_Date 			DATETIME 
	,@Leave_ID			NUMERIC
	,@Branch_ID			VARCHAR(MAX) = ''
	,@Grd_ID 			VARCHAR(MAX) = ''
	,@Type_ID 			VARCHAR(MAX) = ''
	,@Dept_ID 			VARCHAR(MAX) = ''
	,@Desig_ID 			VARCHAR(MAX) = ''
	,@Emp_ID 			Numeric = 0
	,@Constraint		VARCHAR(max) = ''
	,@Cat_ID			VARCHAR(max) = ''
	,@is_column			TINYINT = 0
	,@Salary_Cycle_id	NUMERIC = 0
	,@Segment_ID		Numeric = 0 
	,@Vertical_Id		VARCHAR(MAX) = ''
	,@SubVertical_Id	VARCHAR(MAX) = ''
	,@SubBranch_Id		VARCHAR(MAX) = ''
	,@Report_Type	   	TINYINT = 0 --@Report_Type = 2 For Lubi Client 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #Emp_Cons
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	--EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical ,@SubVertical ,@subBranch,@With_Ctc=1	
	EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,
			@Constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0    
	
	

	DELETE	EC 
	FROM	#Emp_Cons EC 
	WHERE	EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK) WHERE E.Emp_Left_Date Is Not Null AND E.Emp_ID=EC.Emp_ID)
	--SELECT @Leave_ID = leave_id from T0040_LEAVE_MASTER where Cmp_ID=@CMP_ID and Leave_Name like '%privi%'

	--select * from T0100_LEAVE_CF_DETAIL where Leave_ID=@Leave_ID

	CREATE TABLE #LEAVE_ACCRUAL
	(
		EMP_ID				NUMERIC,
		Increment_ID		NUMERIC,
		Increment_ID_Sal	NUMERIC,	
		Gratuity			NUMERIC(18,2),
		MonthlyCTC			NUMERIC(18,2),
		L_OPENING			NUMERIC(18,2),
		L_CREDIT			NUMERIC(18,2),
		L_USED				NUMERIC(18,2),
		L_ENCASH			NUMERIC(18,2),
		L_CLOSING			NUMERIC(18,2),
		L_ENCASHMENT_DAY	NUMERIC(18,2),
		L_ENCASHMENT_AMOUNT NUMERIC(18,2),
		GROSS_SALARY		NUMERIC(18,2)
	)
	INSERT INTO #LEAVE_ACCRUAL(EMP_ID,Increment_ID)
	SELECT EMP_ID,Increment_ID FROM #Emp_Cons

	IF (@is_column = 0)
		BEGIN 
			UPDATE	LC
			SET		Increment_ID_Sal = I.Increment_ID
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN (SELECT	I.EMP_ID, MAX(Increment_ID) Increment_ID
								FROM	T0095_INCREMENT I WITH (NOLOCK)
										--INNER JOIN (SELECT	I1.EMP_ID, MAX(Increment_Effective_Date) AS Increment_Effective_Date 
										--			FROM	T0095_INCREMENT I1
										--					INNER JOIN #Emp_Cons EC ON I1.Emp_ID=EC.Emp_ID
										--			WHERE	I1.Increment_Effective_Date <= @To_Date
										--					AND I1.Increment_Type NOT IN ('Transfer', 'Deputation')
										--			GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_Effective_Date=I1.Increment_Effective_Date
								GROUP BY I.Emp_ID) I ON LC.EMP_ID=I.Emp_ID

			UPDATE	LC
			SET		Gratuity = I.Basic_Salary +  Isnull(SAL.M_AD_AMOUNT,0), MonthlyCTC = I.Basic_Salary +  Isnull(SAL_CTC.M_AD_AMOUNT_CTC,0),GROSS_SALARY = I.Gross_Salary
			FROM	#LEAVE_ACCRUAL LC
					Inner Join T0095_INCREMENT I On LC.Increment_ID_Sal = I.Increment_ID
					Left Outer JOIN (SELECT	MAD.Emp_ID,SUM(E_AD_AMOUNT) AS M_AD_AMOUNT, MAD.Increment_ID 
								FROM	T0100_EMP_EARN_DEDUCTION MAD WITH (NOLOCK)
										INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID  AND 1 = Case WHEN @Report_Type = 2 Then AD.AD_EFFECT_ON_LEAVE ELSE AD.AD_EFFECT_ON_GRATUITY END
										INNER JOIN #Emp_Cons EC ON MAD.Emp_ID=EC.Emp_ID
								GROUP BY MAD.Emp_ID,MAD.Increment_ID) SAL ON LC.EMP_ID=SAL.Emp_ID And LC.Increment_ID_Sal=SAL.INCREMENT_ID
					Left Outer JOIN (SELECT	MAD.Emp_ID,SUM(E_AD_AMOUNT) AS M_AD_AMOUNT_CTC, MAD.Increment_ID 
								FROM	T0100_EMP_EARN_DEDUCTION MAD WITH (NOLOCK)
										INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID  AND AD.AD_PART_OF_CTC=1
										INNER JOIN #Emp_Cons EC ON MAD.Emp_ID=EC.Emp_ID
								GROUP BY MAD.Emp_ID,MAD.Increment_ID) SAL_CTC ON LC.EMP_ID=SAL_CTC.Emp_ID And LC.Increment_ID_Sal=SAL_CTC.INCREMENT_ID



			--Updating Opening FROM Transaction
			UPDATE	LC
			SET		L_OPENING = IsNull(T.Leave_Opening,0)
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN T0140_LEAVE_TRANSACTION T ON LC.EMP_ID=T.EMP_ID
			WHERE	T.For_Date = @From_Date AND T.Leave_ID=@Leave_ID			
			
			
			UPDATE	LC
			SET		L_OPENING = IsNull(T.Leave_Closing,0)
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN T0140_LEAVE_TRANSACTION T ON LC.EMP_ID=T.EMP_ID
					--INNER JOIN T0040_LEAVE_MASTER L ON T.Leave_ID=L.Leave_ID
					INNER JOIN (SELECT	T1.Emp_ID,MAX(T1.FOR_DATE) AS FOR_DATE, T1.Leave_ID
								FROM	T0140_LEAVE_TRANSACTION T1 WITH (NOLOCK)
										INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
								WHERE	T1.For_Date < @From_Date AND T1.Leave_ID=@Leave_ID
								GROUP BY T1.Emp_ID,T1.Leave_ID) T1 ON T.Emp_ID=T1.Emp_ID AND T.For_Date=T1.FOR_DATE AND T1.Leave_ID=T.Leave_ID
			WHERE	L_OPENING IS NULL 
			
			

			--Updating ALL Leave Credit
			UPDATE	LC
			SET		L_CREDIT = IsNull(T1.Leave_Credit,0)
			FROM	#LEAVE_ACCRUAL LC		
					LEFT OUTER JOIN (SELECT	T1.Emp_ID,SUM(T1.Leave_Credit) AS Leave_Credit
									FROM	T0140_LEAVE_TRANSACTION T1	WITH (NOLOCK)						
											INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
											INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T1.Leave_ID=L.Leave_ID
									WHERE	T1.For_Date BETWEEN 
											Case When Isnull(L.Is_Advance_Leave_Balance,0)=1 Then 
												@From_Date Else DateAdd(dd,1,@From_Date) End
											AND @To_Date 
											AND T1.Leave_ID=@Leave_ID
									GROUP BY T1.Emp_ID) T1 ON T1.Emp_ID=LC.Emp_ID 


			--Updating ALL Leave Used
			UPDATE	LC
			SET		L_USED = IsNull(T1.Leave_Used,0) + IsNull(T1.Leave_Adj_L_Mark,0)
			FROM	#LEAVE_ACCRUAL LC		
					LEFT OUTER JOIN (SELECT	T1.Emp_ID,SUM(T1.Leave_Used) AS Leave_Used, SUM(T1.Leave_Adj_L_Mark) AS Leave_Adj_L_Mark
									FROM	T0140_LEAVE_TRANSACTION T1	WITH (NOLOCK)						
											INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
									WHERE	T1.For_Date BETWEEN @From_Date AND @To_Date 
											AND T1.Leave_ID=@Leave_ID
									GROUP BY T1.Emp_ID) T1 ON T1.Emp_ID=LC.Emp_ID 

			
			--Updating ALL Leave Encash
			UPDATE	LC
			SET		L_ENCASH = IsNull(T1.Leave_Encash,0)
			FROM	#LEAVE_ACCRUAL LC		
					LEFT OUTER JOIN (SELECT	T1.Emp_ID,SUM(T1.Lv_Encash_Apr_Days) AS Leave_Encash
									FROM	T0120_LEAVE_ENCASH_APPROVAL T1	WITH (NOLOCK)						
											INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
									WHERE	T1.Upto_Date BETWEEN @From_Date AND @To_Date 
											AND T1.Leave_ID=@Leave_ID
									GROUP BY T1.Emp_ID) T1 ON T1.Emp_ID=LC.Emp_ID 



			--Updating Closing FROM Transaction
			UPDATE	LC
			SET		L_CLOSING = IsNull(T.Leave_Closing ,0)
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN T0140_LEAVE_TRANSACTION T ON LC.EMP_ID=T.EMP_ID
					INNER JOIN (SELECT	T1.Emp_ID,MAX(T1.FOR_DATE) AS FOR_DATE,T1.Leave_ID
								FROM	T0140_LEAVE_TRANSACTION T1 WITH (NOLOCK)
										INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
								WHERE	T1.For_Date <= @To_Date AND T1.Leave_ID=@Leave_ID
								GROUP BY T1.Emp_ID,T1.Leave_ID) T1 ON T.Emp_ID=T1.Emp_ID AND T.For_Date=T1.FOR_DATE AND T.Leave_ID=T1.Leave_ID
								
			--CREATE TABLE #LEAVE_CF_DAYS
			--(
			--	Emp_ID		NUMERIC,
			--	FROM_DATE	DATETIME,
			--	TO_DATE		DATETIME,
			--	CF_DAYS		NUMERIC
			--)

			CREATE TABLE #LEAVE_CF_DAYS
			(
				Emp_ID			NUMERIC,
				FROM_DATE		DATETIME,
				TO_DATE			DATETIME,
				Emp_Type_ID		NUMERIC,
				DateOfJoin		DATETIME,
				Grd_ID			NUMERIC,

				/*GENRATEL SETTINGS*/
				Sal_St_Date				DATETIME,
				Is_CF_On_Sal_Days		TINYINT,
				Days_As_Per_Sal_Days	TINYINT,

				/*CF DETAIL*/
				Month_St_Date			DATETIME,
				Month_End_Date			DATETIME,
				Leave_Closing			NUMERIC(9,2),
				Leave_CF_P_Days			NUMERIC(9,2),
				Leave_Again_Present_Day	NUMERIC(9,2),
				Leave_CF_Days			NUMERIC(9,2),
				Exceed_CF_Days			NUMERIC(9,2),
				Min_Present_Days_Per_Wise NUMERIC(9,2),

				/*Salary Detail*/
				Sal_Cal_Days			NUMERIC(9,2),
				P_Days					NUMERIC(9,2),
				WO_Days					NUMERIC(9,2),
				HO_Days					NUMERIC(9,2),
				L_Paid_Days				NUMERIC(9,2),
				Alternate_Weekoff		VARCHAR(50),
				Alternate_Weekoff_Days	NUMERIC(9,2)

			)
			
			IF @Report_Type <> 2 -- Added Condition for LUBI Not Required
				EXEC P_GET_LEAVE_ESTIMATED_CF_DAYS @Cmp_ID=@Cmp_ID, @From_Date = NULL, @To_Date= @From_Date, @Leave_ID=@Leave_ID
			
			--SELECT * FROM T0050_CF_EMP_TYPE_DETAIL where Leave_ID=@Leave_ID
			UPDATE	LC
			SET		L_OPENING = IsNull(L_OPENING,0) +  IsNull(LCD.Leave_CF_Days ,0)
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN #LEAVE_CF_DAYS LCD ON LC.EMP_ID=LCD.EMP_ID

			--SELECT * FROM	#LEAVE_ACCRUAL 
			TRUNCATE TABLE #LEAVE_CF_DAYS

			EXEC P_GET_LEAVE_ESTIMATED_CF_DAYS @Cmp_ID=@Cmp_ID, @From_Date = @From_Date, @To_Date= @To_Date, @Leave_ID=@Leave_ID
			
			
			UPDATE	LC
			SET		L_CREDIT = IsNull(LCD.Leave_CF_Days ,0) --ISNULL(L_CREDIT,0) + IsNull(LCD.Leave_CF_Days ,0)
			FROM	#LEAVE_ACCRUAL LC
					INNER JOIN #LEAVE_CF_DAYS LCD ON LC.EMP_ID=LCD.EMP_ID
		

			UPDATE	LC
			SET		L_CLOSING = (IsNull(L_OPENING,0) +  IsNull(L_CREDIT ,0)) - (IsNull(L_USED,0) + IsNull(L_ENCASH,0))
			FROM	#LEAVE_ACCRUAL LC
		
			UPDATE	LC
			SET		Gratuity = IsNull(Gratuity,0),
					MonthlyCTC = IsNull(MonthlyCTC,0),
					L_OPENING = IsNull(L_OPENING,0),
					L_CREDIT = IsNull(L_CREDIT,0),
					L_USED = IsNull(L_USED,0),
					L_ENCASH = IsNull(L_ENCASH,0),
					L_CLOSING = IsNull(L_CLOSING,0)
			FROM	#LEAVE_ACCRUAL LC
		END
		
	DECLARE @SHOW_ACTUAL_DOB BIT
	SELECT	@SHOW_ACTUAL_DOB = Setting_Value FROM T0040_SETTING WITH (NOLOCK) Where Setting_Name='Display Actual Birth Date' AND Cmp_ID=@CMP_ID

	DECLARE @LEAVE_COLS VARCHAR(512)
	DECLARE @LEAVE_CODE VARCHAR(32)
	SELECT @LEAVE_CODE = Leave_Code FROM  T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID=@Leave_ID
	SET @LEAVE_COLS =	'LA.L_OPENING AS [BALANCE_' + @LEAVE_CODE + '_AS_ON_' + CONVERT(CHAR(10), @FROM_DATE, 103) +'], 
						LA.L_CREDIT AS [LEAVE_CREDITED_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						LA.L_USED AS [LEAVE_UTILISED_FROM_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						LA.L_ENCASH AS [LEAVE_ENCASHMENT_FROM_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						LA.L_CLOSING AS [LEAVE_BALANCE_AS_ON_' + CONVERT(CHAR(10), @To_Date, 103) + '] '

	DECLARE @LEAVE_COLS_SUM VARCHAR(MAX)
	SET @LEAVE_COLS_SUM =	
						'SUM(LA.L_OPENING) AS [BALANCE_' + @LEAVE_CODE + '_AS_ON_' + CONVERT(CHAR(10), @FROM_DATE, 103) +'], 
						SUM(LA.L_CREDIT) AS [LEAVE_CREDITED_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						SUM(LA.L_USED) AS [LEAVE_UTILISED_FROM_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						SUM(LA.L_ENCASH) AS [LEAVE_ENCASHMENT_FROM_' + CONVERT(CHAR(10), @FROM_DATE, 103) + '_TO_' + CONVERT(CHAR(10), @To_Date, 103) + '], 
						SUM(LA.L_CLOSING) AS [LEAVE_BALANCE_AS_ON_' + CONVERT(CHAR(10), @To_Date, 103) + '] '

	DECLARE @SQL VARCHAR(MAX)
	IF @Report_Type = 1
		Begin
			SET @SQL =	'SELECT	ROW_NUMBER() OVER(ORDER BY E.EMP_ID) AS SR_NO,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,Convert(Char(10),E.Date_Of_Birth,103) As Date_Of_Birth,
						Convert(Char(10),Date_Of_Joining, 103) As Date_Of_Joining,Gratuity As [Gratuity_Calc_On],MonthlyCTC As Monthly_CTC,
						DATEDIFF(yyyy, Date_Of_Birth,E.Date_of_Retirement) As Retirement_Age,
						' + @LEAVE_COLS + ',EC.Branch_ID
				FROM	#LEAVE_ACCRUAL LA
						INNER JOIN #Emp_Cons EC ON LA.EMP_ID=EC.Emp_ID
						INNER JOIN (SELECT	EMP_ID,Alpha_Emp_Code,Emp_Full_Name,E.Date_of_Retirement,E.Date_Of_Join As Date_Of_Joining,
											(CASE WHEN ' + CAST(@SHOW_ACTUAL_DOB AS VARCHAR(2)) + ' = 1 AND ISNULL(E.Actual_Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Actual_Date_Of_Birth WHEN ISNULL(E.Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Date_Of_Birth ELSE NULL END) AS Date_Of_Birth 
									FROM	T0080_EMP_MASTER E WITH (NOLOCK) ) E ON EC.Emp_ID=E.Emp_ID '
		End
	Else IF @Report_Type = 2
		Begin

			IF Object_ID('tempdb..#GeneralSetting') is not null
				Begin
					Drop Table #GeneralSetting
				End

			Create Table #GeneralSetting 
			(
				Branch_ID Numeric,
				Leave_Encash_Days Numeric(18,2),
				Leave_Encash_On Varchar(20)
			)

			Insert into #GeneralSetting
			Select G.Branch_ID,G.Lv_Encash_W_Day,G.Lv_Encash_Cal_On
				From T0040_GENERAL_SETTING G WITH (NOLOCK)
			Inner Join (
						SELECT MAX(For_Date) as For_Date,Branch_ID 
							FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=GetDate() AND Cmp_ID = @CMP_ID
						GROUP BY Branch_ID
						) As Qry
			ON G.Branch_ID = Qry.Branch_ID AND G.For_Date = Qry.For_Date


			Update LA
					SET  L_ENCASHMENT_DAY = G.Leave_Encash_Days, 
						 L_ENCASHMENT_AMOUNT = (
												CASE WHEN LA.L_CLOSING > 0 AND LA.Gratuity > 0 AND G.Leave_Encash_Days > 0 and G.Leave_Encash_On = 'Gross' Then 
												(GROSS_SALARY * LA.L_CLOSING)/G.Leave_Encash_Days 
												WHEN LA.L_CLOSING > 0 AND LA.Gratuity > 0 AND G.Leave_Encash_Days > 0 Then 
												(Gratuity * LA.L_CLOSING)/G.Leave_Encash_Days 
												ELSE 0 END )
				From #LEAVE_ACCRUAL LA 
			Inner Join #Emp_Cons EC ON EC.Emp_ID = LA.EMP_ID
			INNER Join #GeneralSetting G ON G.Branch_ID = EC.Branch_ID
			
			SET @SQL =	'SELECT	ROW_NUMBER() OVER(ORDER BY E.EMP_ID) AS SR_NO,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,BM.Branch_Name, Convert(Char(10),E.Date_Of_Birth,103) As Date_Of_Birth,
						Convert(Char(10),Date_Of_Joining, 103) As Date_Of_Joining,Gratuity As [Basic_Salary],MonthlyCTC As Monthly_CTC,
						DATEDIFF(yyyy, Date_Of_Birth,E.Date_of_Retirement) As Retirement_Age,
						' + @LEAVE_COLS + ',L_ENCASHMENT_AMOUNT as Encashment_Amount
				FROM	#LEAVE_ACCRUAL LA
						INNER JOIN #Emp_Cons EC ON LA.EMP_ID=EC.Emp_ID
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID
						INNER JOIN (SELECT	EMP_ID,Alpha_Emp_Code,Emp_Full_Name,E.Date_of_Retirement,E.Date_Of_Join As Date_Of_Joining,
											(CASE WHEN ' + CAST(@SHOW_ACTUAL_DOB AS VARCHAR(2)) + ' = 1 AND ISNULL(E.Actual_Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Actual_Date_Of_Birth WHEN ISNULL(E.Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Date_Of_Birth ELSE NULL END) AS Date_Of_Birth 
									FROM	T0080_EMP_MASTER E WITH (NOLOCK)) E ON EC.Emp_ID=E.Emp_ID
									
						UNION 

						SELECT	9999 AS SR_NO,''0'' AS Emp_ID,'''' As Alpha_Emp_Code,'''' As Emp_Full_Name,'''' AS Branch_Name, '''' As Date_Of_Birth,
						'''' As Date_Of_Joining,''0'' As [Basic_Salary],''0'' As Monthly_CTC,
						''0'' As Retirement_Age,
						' + @LEAVE_COLS_SUM + ',SUM(L_ENCASHMENT_AMOUNT) as ENCASHMENT_AMOUNT
						FROM	#LEAVE_ACCRUAL LA
						INNER JOIN #Emp_Cons EC ON LA.EMP_ID=EC.Emp_ID
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = EC.Branch_ID
						INNER JOIN (SELECT	EMP_ID,Alpha_Emp_Code,Emp_Full_Name,E.Date_of_Retirement,E.Date_Of_Join As Date_Of_Joining,
											(CASE WHEN ' + CAST(@SHOW_ACTUAL_DOB AS VARCHAR(2)) + ' = 1 AND ISNULL(E.Actual_Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Actual_Date_Of_Birth WHEN ISNULL(E.Date_Of_Birth,''1900-01-01'') <> ''1900-01-01'' THEN E.Date_Of_Birth ELSE NULL END) AS Date_Of_Birth 
									FROM	T0080_EMP_MASTER E WITH (NOLOCK)) E ON EC.Emp_ID=E.Emp_ID'
		End

	EXEC (@SQL);
