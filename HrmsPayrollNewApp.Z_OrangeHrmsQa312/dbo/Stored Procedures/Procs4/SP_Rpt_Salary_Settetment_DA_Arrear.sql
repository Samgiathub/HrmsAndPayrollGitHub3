CREATE PROCEDURE [dbo].[SP_Rpt_Salary_Settetment_DA_Arrear] @Company_id NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Grade_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_ID NUMERIC
	,@Emp_ID NUMERIC
	,@Constraint VARCHAR(max)
	,@Cat_ID NUMERIC = 0
	,@is_column NUMERIC = 0
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	IF @Branch_ID = 0
		SET @Branch_ID = NULL

	IF @Grade_ID = 0
		SET @Grade_ID = NULL

	IF @Emp_ID = 0
		SET @Emp_ID = NULL

	IF @Desig_ID = 0
		SET @Desig_ID = NULL

	IF @Dept_ID = 0
		SET @Dept_ID = NULL

	IF @Cat_ID = 0
		SET @Cat_ID = NULL

	IF @Type_id = 0
		SET @Type_id = NULL

	IF Object_ID('tempdb..#Emp_Cons') IS NOT NULL
		DROP TABLE #Emp_Cons

	CREATE TABLE #Emp_Cons (Emp_ID NUMERIC)

	IF @Constraint <> ''
	BEGIN
		INSERT INTO #Emp_Cons
		SELECT data
		FROM dbo.Split(@Constraint, '#')
	END

	IF Object_ID('tempdb..#Dynamic_Allowance') IS NOT NULL
	BEGIN
		DROP TABLE #Dynamic_Allowance
	END

	CREATE TABLE #Dynamic_Allowance (
		AD_ID NUMERIC(18, 0)
		,AD_SORT_NAME VARCHAR(100)
		,AD_Flag VARCHAR(5)
		)

	INSERT INTO #Dynamic_Allowance
	SELECT 0
		,'Basic'
		,'I'
	
	UNION
	
	SELECT 0
		,'OT_Amount'
		,'I' --Added by ronakk 18092023
	
	UNION
	
	SELECT 0
		,'WO_OT_Amount'
		,'I' --Added by ronakk 18092023
	
	UNION
	
	SELECT 0
		,'HO_OT_Amount'
		,'I' --Added by ronakk 18092023

	INSERT INTO #Dynamic_Allowance
	SELECT DISTINCT MAD.AD_ID
		,AD_SORT_NAME
		,M_AD_Flag
	FROM #Emp_Cons EC
	INNER JOIN --MAD.AD_ID,AD.AD_NAME,AD.Allowance_Type,MAD.M_AD_Flag,AD_SORT_NAME
		T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID
	INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID
	INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = MAD.AD_ID
	WHERE S_Eff_Date BETWEEN @From_Date
			AND @To_Date
		AND Isnull(MAD.S_Sal_Tran_ID, 0) <> 0
		AND M_AD_Amount <> 0

	IF OBJECT_ID('tempdb..#Temp_Salary_Sett') IS NOT NULL
	BEGIN
		DROP TABLE #Temp_Salary_Sett
	END

	CREATE TABLE #Temp_Salary_Sett (
		Cmp_ID NUMERIC
		,Emp_ID NUMERIC
		,S_Eff_Date DATETIME
		,Increment_ID NUMERIC(18, 0)
		,AD_ID NUMERIC(18, 0)
		,Label VARCHAR(500)
		,AD_Amount NUMERIC(18, 2)
		,Flag NUMERIC
		,Net_Amount NUMERIC(18, 2)
		,AD_Flag CHAR
		,Sort_Id NUMERIC(18, 0)
		,Period VARCHAR(max)
		,Branch_Name VARCHAR(500)
		)

	DECLARE @Cur_Emp_ID NUMERIC(18, 0)
	DECLARE @Cur_Cmp_ID NUMERIC(18, 0)
	DECLARE @Cur_Eff_Date DATETIME
	DECLARE @Cur_Increment_ID NUMERIC(18, 0)

	DECLARE Cur_Emp CURSOR
	FOR
	SELECT DISTINCT MS.Cmp_ID
		,EC.Emp_ID
		,MS.S_Eff_Date
		,MS.Increment_ID
	FROM #Emp_Cons EC
	INNER JOIN T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID
	WHERE S_Eff_Date BETWEEN @From_Date
			AND @To_Date

	OPEN Cur_Emp

	FETCH NEXT
	FROM Cur_Emp
	INTO @Cur_Cmp_ID
		,@Cur_Emp_ID
		,@Cur_Eff_Date
		,@Cur_Increment_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Actual_' + AD_SORT_NAME
			,0
			,1
			,0
			,AD_Flag
			,1
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'I'

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,9991
			,'Actual_Gross_Amount'
			,0
			,1
			,0
			,'G'
			,2
			,''
			,''

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Actual_' + AD_SORT_NAME
			,0
			,1
			,0
			,AD_Flag
			,3
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'D'

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Paid_' + AD_SORT_NAME
			,0
			,2
			,0
			,AD_Flag
			,1
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'I'

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,9992
			,'Paid_Gross_Amount'
			,0
			,2
			,0
			,'G'
			,2
			,''
			,''

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Paid_' + AD_SORT_NAME
			,0
			,2
			,0
			,AD_Flag
			,3
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'D'

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Diff_' + AD_SORT_NAME
			,0
			,3
			,0
			,AD_Flag
			,1
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'I'

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,9993
			,'Diff_Gross_Amount'
			,0
			,3
			,0
			,'G'
			,2
			,''
			,''

		INSERT INTO #Temp_Salary_Sett
		SELECT @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
			,AD_ID
			,'Diff_' + AD_SORT_NAME
			,0
			,3
			,0
			,AD_Flag
			,3
			,''
			,''
		FROM #Dynamic_Allowance
		WHERE AD_Flag = 'D'

		FETCH NEXT
		FROM Cur_Emp
		INTO @Cur_Cmp_ID
			,@Cur_Emp_ID
			,@Cur_Eff_Date
			,@Cur_Increment_ID
	END

	CLOSE Cur_Emp

	DEALLOCATE Cur_Emp

	UPDATE TS1
	SET Period = Qry.Month_Period
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT Cast(datename(month, Min(S_Month_End_Date)) AS VARCHAR(3)) + ' ' + cast(year(Min(S_Month_End_Date)) AS VARCHAR(4)) + ' - ' + Cast(datename(month, max(S_Month_End_Date)) AS VARCHAR(3)) + ' ' + cast(year(max(S_Month_End_Date)) AS VARCHAR(4)) AS Month_Period
			,MSS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 1
			AND ts.ad_id = 0
		GROUP BY MSS.Emp_ID
		) AS Qry ON Qry.Emp_ID = Ts1.Emp_ID

	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT (SUM(MS.Basic_Salary) + SUM(S_Basic_Salary)) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 1
			AND ts.ad_id = 0
			AND TS.Label = 'Actual_Basic'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 1
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Actual_Basic'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT (SUM(MS.OT_Amount) + SUM(S_OT_Amount)) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 1
			AND ts.ad_id = 0
			AND TS.Label = 'Actual_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 1
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Actual_OT_Amount'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT (SUM(MS.M_WO_OT_Amount) + SUM(S_WO_OT_Amount)) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 1
			AND ts.ad_id = 0
			AND TS.Label = 'Actual_WO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 1
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Actual_WO_OT_Amount'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT (SUM(MS.M_HO_OT_Amount) + SUM(S_HO_OT_Amount)) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 1
			AND ts.ad_id = 0
			AND TS.Label = 'Actual_HO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 1
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Actual_HO_OT_Amount'

	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(MS.Basic_Salary) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 2
			AND ts.ad_id = 0
			AND TS.Label = 'Paid_Basic'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 2
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Paid_Basic'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(MS.OT_Amount) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 2
			AND ts.ad_id = 0
			AND TS.Label = 'Paid_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 2
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Paid_OT_Amount'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(MS.M_WO_OT_Amount) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 2
			AND ts.ad_id = 0
			AND TS.Label = 'Paid_WO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 2
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Paid_WO_OT_Amount'

	--Added by ronakk 18092023
	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(MS.M_HO_OT_Amount) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 2
			AND ts.ad_id = 0
			AND TS.Label = 'Paid_HO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 2
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Paid_HO_OT_Amount'

	UPDATE TS1
	SET AD_Amount = Qry.basic
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(S_Basic_Salary) AS basic
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 3
			AND ts.ad_id = 0
			AND TS.Label = 'Diff_Basic'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 3
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Diff_Basic'

	UPDATE TS1
	SET AD_Amount = Qry.S_OT_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(S_OT_Amount) AS S_OT_Amount
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 3
			AND ts.ad_id = 0
			AND TS.Label = 'Diff_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 3
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Diff_OT_Amount'

	UPDATE TS1
	SET AD_Amount = Qry.S_WO_OT_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(S_WO_OT_Amount) AS S_WO_OT_Amount
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 3
			AND ts.ad_id = 0
			AND TS.Label = 'Diff_WO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 3
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Diff_WO_OT_Amount'

	UPDATE TS1
	SET AD_Amount = Qry.S_HO_OT_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(S_HO_OT_Amount) AS S_HO_OT_Amount
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MSS.Sal_Tran_ID = MS.Sal_Tran_ID
			AND MSS.Emp_ID = MS.Emp_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MSS.Emp_ID
			AND TS.S_Eff_Date = Mss.S_Eff_Date
			AND TS.Flag = 3
			AND ts.ad_id = 0
			AND TS.Label = 'Diff_HO_OT_Amount'
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 3
		AND TS1.AD_ID = 0
		AND TS1.Label = 'Diff_HO_OT_Amount'

	UPDATE TS1
	SET AD_Amount = Qry.M_AD_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(M_AD_Amount) AS M_AD_Amount
			,TS.AD_ID
			,TS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MS.Emp_ID
			AND TS.AD_ID = MAD.AD_ID
		WHERE TS.Flag = 1
		GROUP BY TS.AD_ID
			,TS.Emp_ID
		) AS Qry ON TS1.AD_ID = Qry.AD_ID
		AND TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 1

	UPDATE TS1
	SET AD_Amount = Qry.M_AD_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(M_AD_Amount) AS M_AD_Amount
			,TS.AD_ID
			,TS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MS.Emp_ID
			AND TS.AD_ID = MAD.AD_ID
		WHERE MAD.S_Sal_Tran_ID IS NULL
			AND TS.Flag = 2
		GROUP BY TS.AD_ID
			,TS.Emp_ID
		) AS Qry ON TS1.AD_ID = Qry.AD_ID
		AND TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 2

	UPDATE TS1
	SET AD_Amount = Qry.M_AD_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(M_AD_Amount) AS M_AD_Amount
			,TS.AD_ID
			,TS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MS.Emp_ID
			AND TS.AD_ID = MAD.AD_ID
		WHERE Isnull(MAD.S_Sal_Tran_ID, 0) <> 0
			AND TS.Flag = 3
		GROUP BY TS.AD_ID
			,TS.Emp_ID
		) AS Qry ON TS1.AD_ID = Qry.AD_ID
		AND TS1.Emp_ID = Qry.Emp_ID
	WHERE TS1.Flag = 3

	UPDATE ts
	SET ts.AD_Amount = 0
	FROM #Temp_Salary_Sett ts
	INNER JOIN (
		SELECT Emp_Id
			,Replace(Label, 'Diff', 'Actual') AS Actual_Lable
		FROM #Temp_Salary_Sett
		WHERE Label LIKE 'Diff%'
			AND AD_Amount = 0
			AND AD_ID <> 0
		) Qry ON ts.Emp_ID = qry.Emp_ID
		AND ts.Label = qry.Actual_Lable

	UPDATE ts
	SET ts.AD_Amount = 0
	FROM #Temp_Salary_Sett ts
	INNER JOIN (
		SELECT Emp_Id
			,Replace(Label, 'Diff', 'Paid') AS Actual_Lable
		FROM #Temp_Salary_Sett
		WHERE Label LIKE 'Diff%'
			AND AD_Amount = 0
			AND AD_ID <> 0
		) Qry ON ts.Emp_ID = qry.Emp_ID
		AND ts.Label = qry.Actual_Lable

	UPDATE TS1
	SET AD_Amount = Qry.AD_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(AD_Amount) AS AD_Amount
			,Flag
			,Emp_ID
		FROM #Temp_Salary_Sett
		WHERE AD_Flag = 'I'
		GROUP BY Flag
			,Emp_ID
		) AS Qry ON Qry.Emp_ID = TS1.Emp_ID
		AND Qry.Flag = TS1.Flag
	WHERE AD_Flag = 'G'

	UPDATE TS1
	SET Net_Amount = Qry.S_Net_Amount
	FROM #Temp_Salary_Sett TS1
	INNER JOIN (
		SELECT SUM(MS.S_Net_Amount) AS S_Net_Amount
			,MS.Emp_ID
		FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
		INNER JOIN #Temp_Salary_Sett TS ON TS.Emp_ID = MS.Emp_ID
			AND TS.S_Eff_Date = MS.S_Eff_Date
		WHERE AD_ID = 0
			AND Flag = 1
		GROUP BY MS.Emp_ID
		) AS Qry ON TS1.Emp_ID = Qry.Emp_ID

	UPDATE ES
	SET ES.Branch_Name = BM.Branch_Name
	FROM #Temp_Salary_Sett ES
	INNER JOIN (
		SELECT TI.Branch_ID
			,TI.Emp_ID
		FROM T0095_INCREMENT TI WITH (NOLOCK)
		INNER JOIN (
			SELECT Max(I.Increment_Effective_Date) AS EffectiveDate
				,Emp_ID
			FROM T0095_INCREMENT I WITH (NOLOCK)
			WHERE Increment_Effective_Date <= @To_Date
			GROUP BY Emp_ID
			) AS qry_1 ON qry_1.EffectiveDate = TI.Increment_Effective_Date
			AND qry_1.Emp_ID = TI.Emp_ID
		) AS qry ON qry.Emp_ID = ES.Emp_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = qry.Branch_ID

	DECLARE @colsPivot_Add VARCHAR(max)

	SET @colsPivot_Add = ''

	SELECT @colsPivot_Add = coalesce(@colsPivot_Add + ' ', ' ') + Label + ','
	FROM (
		SELECT DISTINCT t.Label
			,ISNULL(ad.AD_LEVEL, T.AD_ID) AS AD_LEVEL
			,T.AD_ID
			,T.Flag
			,T.Sort_Id
		FROM #Temp_Salary_Sett t
		LEFT OUTER JOIN T0050_AD_MASTER ad WITH (NOLOCK) ON t.AD_ID = ad.AD_ID
		) T
	ORDER BY T.FLAG
		,T.Sort_Id
		,T.AD_LEVEL

	SET @colsPivot_Add = LEFT(@colsPivot_Add, LEN(@colsPivot_Add) - 1)

	DECLARE @colsPivot_Sum VARCHAR(max)

	SET @colsPivot_Sum = ''

	SELECT @colsPivot_Sum = coalesce(@colsPivot_Sum + ' ', ' ') + ('NULL' + ' AS ' + Label) + ','
	FROM (
		SELECT DISTINCT t.Label
			,ISNULL(ad.AD_LEVEL, T.AD_ID) AS AD_LEVEL
			,T.AD_ID
			,T.Flag
			,T.Sort_Id
		FROM #Temp_Salary_Sett t
		LEFT OUTER JOIN T0050_AD_MASTER ad WITH (NOLOCK) ON t.AD_ID = ad.AD_ID
		) T
	ORDER BY T.FLAG
		,T.Sort_Id
		,T.AD_LEVEL

	DECLARE @query VARCHAR(max)

	SET @query = ''

	IF @is_column = 1
	BEGIN
		SET @query = 'select TOP 1 0 as flag, Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Period,' + @colsPivot_Add + ',Net_Amount
			from (select EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Net_Amount,Period,Branch_Name from #Temp_Salary_Sett TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
			as data pivot
			( sum(AD_Amount)
			for Label in (' + @colsPivot_Add + ') ) p'

		EXEC (@query)
	END
	ELSE
	BEGIN
		SET @query = 'select 0 as flag, Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Period, ' + @colsPivot_Add + ',Net_Amount
			from (select EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Net_Amount,Period,Branch_Name from #Temp_Salary_Sett TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
			as data pivot
			( sum(AD_Amount)
			for Label in (' + @colsPivot_Add + ') ) p
			union
			select 1 as flag, '''' as Alpha_Emp_Code,'''' as Emp_Full_Name,'''' as Branch_Name,''Total Net Amount'' as Period,' + @colsPivot_Sum + ' SUM(Net_Amount) as Net_Amount
			from (select EM.Alpha_Emp_Code,EM.Emp_Full_Name,Label, AD_Amount,Net_Amount,Period,Branch_Name from #Temp_Salary_Sett TS inner join T0080_Emp_Master EM WITH (NOLOCK) ON TS.EMP_ID = EM.Emp_ID)
			as data pivot
			( sum(AD_Amount)
			for Label in (' + @colsPivot_Add + ') ) p
			order by Net_Amount,Period'

		EXEC (@query)
	END
			/*
Declare @val Varchar(max)
Set @val = ''
Declare @Columns Varchar(1000)
Declare @Allowance_Name Varchar(100)
Set @Allowance_Name = ''
Declare @AD_NAME_DYN Varchar(100)
Set @AD_NAME_DYN = ''
Set @val = @val + 'Alter table #Temp_Salary_Sett Add newBasic numeric(18,2) default 0 not null; '
Exec(@val);
Set @val = ''
Declare Cur_Allow_Earn Cursor For
Select DISTINCT AD_SORT_NAME From #Emp_Cons EC Inner join --MAD.AD_ID,AD.AD_NAME,AD.Allowance_Type,MAD.M_AD_Flag,AD_SORT_NAME
T0201_MONTHLY_SALARY_SETT MS ON EC.Emp_ID = MS.Emp_ID
Inner Join T0210_MONTHLY_AD_DETAIL MAD On MAD.Sal_Tran_ID = MS.Sal_Tran_ID
Inner Join T0050_AD_MASTER AD ON AD.AD_ID = MAD.AD_ID
Where S_Eff_Date Between @From_Date AND @To_Date
and Isnull(MAD.S_Sal_Tran_ID,0) <> 0 and M_AD_Amount <> 0 and MAD.M_AD_Flag = 'I'
Open Cur_Allow_Earn
fetch next from Cur_Allow_Earn into @Allowance_Name
While @@FETCH_STATUS = 0
Begin
Set @AD_NAME_DYN = 'new'+Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Allowance_Name)),'+','_'),'''','_'),',','_'),'.','_'),' ',' '),'%',''),'-',' '),'@',''),'(',''),')',
''),' ','_'),'__','_'),'__','_'),'/','')
Set @val = @val + 'Alter table #Temp_Salary_Sett Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null; '
Set @Columns = @Columns + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
fetch next from Cur_Allow_Earn into @Allowance_Name
End
close Cur_Allow_Earn
deallocate Cur_Allow_Earn
exec (@val);
Set @val = ''
Set @val = @val + 'Alter table #Temp_Salary_Sett Add newTotal numeric(18,2) default 0 not null; '
exec (@val);
Set @val = ''
Declare Cur_Allow_Dedu Cursor For
Select DISTINCT AD_SORT_NAME From #Emp_Cons EC Inner join --MAD.AD_ID,AD.AD_NAME,AD.Allowance_Type,MAD.M_AD_Flag,AD_SORT_NAME
T0201_MONTHLY_SALARY_SETT MS ON EC.Emp_ID = MS.Emp_ID
Inner Join T0210_MONTHLY_AD_DETAIL MAD On MAD.Sal_Tran_ID = MS.Sal_Tran_ID
Inner Join T0050_AD_MASTER AD ON AD.AD_ID = MAD.AD_ID
Where S_Eff_Date Between @From_Date AND @To_Date
and Isnull(MAD.S_Sal_Tran_ID,0) <> 0 and M_AD_Amount <> 0 and MAD.M_AD_Flag = 'D'
Open Cur_Allow_Dedu
fetch next from Cur_Allow_Dedu into @Allowance_Name
While @@FETCH_STATUS = 0
Begin
Set @AD_NAME_DYN = 'new'+Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Allowance_Name)),'+','_'),'''','_'),',','_'),'.','_'),' ',' '),'%',''),'-',' '),'@',''),'(',''),')',
''),' ','_'),'__','_'),'__','_'),'/','')
Set @val = @val + 'Alter table #Temp_Salary_Sett Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null; '
Set @Columns = @Columns + REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
fetch next from Cur_Allow_Dedu into @Allowance_Name
End
close Cur_Allow_Dedu
deallocate Cur_Allow_Dedu
exec (@val);*/
END
