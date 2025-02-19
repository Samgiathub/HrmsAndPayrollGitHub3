

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 14-Aug-2015
-- Description:	Retrieving data for JV Register
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_JV_EMP_CONTRIBUTION_REGISTER] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID			numeric, 
	@From_Date		DateTime,
	@To_Date		DateTime,
	@Branch_ID		numeric = 0,
	@Cat_ID			numeric = 0,
	@Grd_ID			numeric = 0,	
	@Dept_ID		numeric = 0,
	@Desig_ID		numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	CREATE TABLE #Emp_Cons
	(
		Emp_ID			numeric,
		Branch_ID		numeric,
		Increment_ID	numeric
	)

    EXEC	[dbo].[SP_RPT_FILL_EMP_CONS]
			@Cmp_ID = @Cmp_ID,
			@From_Date = @From_Date,
			@To_Date = @To_Date,
			@Branch_ID = @Branch_ID,
			@Cat_ID = @Cat_ID,
			@Grd_ID = @Grd_ID,
			@Type_ID = 0,
			@Dept_ID = @Dept_ID,
			@Desig_ID = @Desig_ID,
			@Emp_ID = 0,
			@constraint = '',
			@Sal_Type = 0,
			@Salary_Cycle_id = 0,
			@Segment_Id = 0,
			@Vertical_Id = 0,
			@SubVertical_Id = 0,
			@SubBranch_Id = 0,
			@New_Join_emp = 0,
			@Left_Emp = 0,
			@SalScyle_Flag = 0,
			@PBranch_ID = '',
			@With_Ctc = 0,
			@Type = 0


		
	CREATE TABLE #JV
	(
		ROW_ID		NUMERIC,
		JV_DESC		VARCHAR(100),
		DR_CR		CHAR(1),
		AMOUNT		NUMERIC(18,2),
	)
	
	DECLARE @ROW_ID NUMERIC;
	DECLARE @AMOUNT NUMERIC(18,2);
	
	SET	@ROW_ID = 1;
	
	
	
	--GETTING BASIC
	SELECT	@AMOUNT = T.AMOUNT
	FROM	(
				SELECT	SUM(T.Salary_Amount) AS AMOUNT
				FROM	T0200_MONTHLY_SALARY T WITH (NOLOCK) INNER JOIN #Emp_Cons E ON T.Emp_ID=E.Emp_ID 
				WHERE	T.Cmp_ID=@CMP_ID AND (T.Month_End_Date BETWEEN @FROM_DATE AND @TO_DATE)
			) T
			
	
	INSERT INTO #JV VALUES(@ROW_ID, 'Earned Basic', 'I', ISNULL(@AMOUNT,0));
	
	
	--ALLOWANCE & DEDUCTIONS
	INSERT INTO #JV 
	SELECT (ROW_NUMBER() OVER(ORDER BY AD_FLAG DESC,AD_LEVEL) + @ROW_ID) AS ROW_ID, AD_NAME,T.AD_FLAG,T.AMOUNT
	FROM	(
				SELECT	T.AD_NAME,T.AD_LEVEL,T.AD_FLAG, SUM(T.AMOUNT) AS AMOUNT
				FROM	(
							SELECT AD.AD_NAME,AD.AD_LEVEL,AD.AD_FLAG, (M_AD_Amount + MAD.M_AREAR_AMOUNT) AS AMOUNT
							FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=AD.AD_ID 
									INNER JOIN T0200_MONTHLY_SALARY S WITH (NOLOCK) ON S.Sal_Tran_ID=MAD.Sal_Tran_ID AND S.Cmp_ID=MAD.Cmp_ID 
									INNER JOIN #Emp_Cons E ON E.Emp_ID=MAD.Emp_ID
							WHERE AD.AD_NOT_EFFECT_SALARY=0 AND (MAD.M_AD_Amount + MAD.M_AREAR_AMOUNT) > 0
						) T
				GROUP	BY T.AD_NAME,T.AD_LEVEL,T.AD_FLAG
			) T

	--PT Amount
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'PT Amount', 'D', ISNULL(SUM(PT_Amount),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Loan
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Loan Amount', 'D', ISNULL(SUM(Loan_Amount + Loan_Intrest_Amount ) ,0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Advance
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Advance Amount', 'D', ISNULL(SUM(Advance_Amount),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Revenue
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Revenue Amount', 'D', ISNULL(SUM(Revenue_amount),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--LWF Amount
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'LWF', 'D', ISNULL(SUM(LWF_Amount),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Other Deduction
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Other Deduction', 'D', ISNULL(SUM(Other_Dedu_Amount),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Deficit Deduction
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Deficit Deduction', 'D', ISNULL(SUM(Isnull(Deficit_Dedu_Amount,0)),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID
	
	--Asset Installment
	SET @ROW_ID = @ROW_ID + 1
	INSERT INTO #JV
	SELECT	@ROW_ID, 'Asset Installment', 'D', ISNULL(SUM(Asset_Installment),0)
	FROM	T0200_Monthly_salary S WITH (NOLOCK) INNER JOIN #Emp_Cons E ON S.Emp_ID=E.Emp_ID 
	WHERE	Month_End_Date BETWEEN @FROM_DATE and @TO_DATE AND S.Cmp_ID=@CMP_ID

	--GETTING NET SALARY
	SELECT @ROW_ID=COUNT(1)+1 FROM #JV
	
	INSERT INTO #JV
	SELECT	@ROW_ID,'Net Pay','D', T.AMOUNT
	FROM	(
				SELECT	SUM(T.Net_Amount + T.Net_Salary_Round_Diff_Amount) AS AMOUNT
				FROM	T0200_MONTHLY_SALARY T WITH (NOLOCK) INNER JOIN #Emp_Cons E ON T.Emp_ID=E.Emp_ID 
				WHERE	T.Cmp_ID=@CMP_ID AND (T.Month_End_Date BETWEEN @FROM_DATE AND @TO_DATE)
			) T

	SET @ROW_ID = @ROW_ID + 1;
	

	CREATE TABLE #FINAL
	(
		ROW_ID NUMERIC,
		JV_DESC VARCHAR(100),
		DEBIT NUMERIC(18,2),
		CREDIT NUMERIC(18,2)
	)
	
	INSERT INTO #FINAL	
	SELECT T.ROW_ID,T.JV_DESC,T.DEBIT,T.CREDIT
	FROM (SELECT ROW_NUMBER() OVER (ORDER BY T.DR_CR DESC,ROW_ID) AS ROW_ID, T.JV_DESC,(CASE WHEN T.DR_CR ='D' THEN AMOUNT ELSE 0 END) AS CREDIT,
					(CASE WHEN T.DR_CR ='I' THEN AMOUNT ELSE 0 END) AS DEBIT,DR_CR
			 FROM #JV T				 		 
			 ) T 	
	UNION ALL
	SELECT	T.ROW_ID,T.JV_DESC,T.DEBIT,T.CREDIT
	FROM	(
				SELECT @ROW_ID+1 AS ROW_ID, 'TOTAL' AS JV_DESC, SUM(DEBIT) AS DEBIT, SUM(CREDIT) AS CREDIT
				FROM	(SELECT (CASE WHEN T.DR_CR ='D' THEN AMOUNT ELSE 0 END) AS CREDIT,
								(CASE WHEN T.DR_CR ='I' THEN AMOUNT ELSE 0 END) AS DEBIT,T.DR_CR
						 FROM	#JV T
						 WHERE	T.AMOUNT > 0
						 ) T 									
			) T
	ORDER BY ROW_ID
	
	
	SELECT * FROM #FINAL ORDER BY ROW_ID
END

