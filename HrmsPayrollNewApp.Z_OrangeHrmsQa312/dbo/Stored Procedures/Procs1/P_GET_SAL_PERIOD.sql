

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 31-Aug-2018
-- Description:	To get the salary Start Date & End Date
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_SAL_PERIOD]
(
	@CONSTRAINT	VarChar(Max),	--Assign the employee IDs seperated by # character (i.e. 545#95#650#784)
	@FOR_DATE	DateTime		--For Date Should Be End Of the Month
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN

	
	--declare @from_date datetime = '2016-02-01'
	DECLARE @nFromDate NUMERIC; --Condition added by Sumit  as per nimesh bhai suggestions for aashiana client query manual salary period..04052016
	SET @nFromDate = CAST(DATEADD(D, (DAY(@FOR_DATE) * -1) + 1, @FOR_DATE) AS NUMERIC) -1;
	
	Declare @HasTable BIT
	SET @HasTable = 1
	
	IF OBJECT_ID('tempdb..#EMP_SAL_PERIOD') IS NULL
		BEGIN 
			SET @HasTable = 0
			CREATE TABLE #EMP_SAL_PERIOD(EMP_ID NUMERIC, Branch_ID NUMERIC, Sal_St_Date DATETIME, Sal_End_Date DATETIME, Manual_Salary_Period TINYINT, Is_CutOff TinyInt, NormalSalCycle BIT);
		END
		
	CREATE TABLE #EMP_CONS_SAL(EMP_ID NUMERIC PRIMARY KEY, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	
	INSERT INTO #EMP_CONS_SAL (EMP_ID, BRANCH_ID, INCREMENT_ID)
	SELECT	I.Emp_ID, I.Branch_ID, I.Increment_ID
	FROM	dbo.Split(@CONSTRAINT, '#') T
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON CAST(T.DATA AS NUMERIC) = I.EMP_ID
			INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) AS Increment_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date <= @For_Date
											GROUP BY I2.EMP_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date = I2.Increment_Effective_Date 
						GROUP BY I1.EMP_ID) I1 ON I1.Increment_ID = I.Increment_ID
	WHERE	T.DATA <> '';

	SELECT	E.Branch_ID, C.EMP_ID, CM.Salary_St_Date 
	INTO	#EMP_SAL_CYCLE
	FROM	T0095_Emp_Salary_Cycle C WITH (NOLOCK)
			INNER JOIN (SELECT	Emp_ID, MAX(Effective_Date) As Effective_Date
						FROM	T0095_Emp_Salary_Cycle C1 WITH (NOLOCK)
						WHERE	Effective_Date <=  @FOR_DATE
						GROUP BY Emp_ID) C1 ON C.Emp_ID=C1.Emp_ID AND C.Effective_Date=C1.Effective_Date
			INNER JOIN T0040_Salary_Cycle_Master CM WITH (NOLOCK) ON C.SalDate_ID=CM.Tran_ID
			INNER JOIN #EMP_CONS_SAL E ON C.Emp_id=E.EMP_ID	
	
	CREATE TABLE #SAL_CYCLE(Emp_ID Numeric, Branch_ID Numeric, Sal_St_Date DateTime, Sal_End_Date DateTime, Manual_Salary_Period TinyInt, Is_CutOff TinyInt, NormalSalCycle BIT)
	

	CREATE UNIQUE CLUSTERED INDEX IX_SAL_CYCLE ON #SAL_CYCLE(EMP_ID) 
	INSERT INTO	#SAL_CYCLE
	SELECT	DISTINCT I.EMP_ID,B.Branch_ID,
			(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 AND SP.FROM_DATE IS NOT NULL THEN SP.FROM_DATE ELSE  G.Sal_St_Date END) AS Sal_St_Date, 
			(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 AND SP.FROM_DATE IS NOT NULL THEN 
					SP.END_DATE 
				ELSE 
					(CASE WHEN Year(G.Cutoffdate_salary) > 1900 THEN G.Cutoffdate_salary ELSE G.Sal_St_Date END)
			END) AS Sal_End_Date, 
			(Case When IsNull(G.Manual_Salary_Period,0) = 1 AND SP.FROM_DATE IS NOT NULL Then 1 Else 0 End) As Manual_Salary_Period, 
			(Case When Year(g.Cutoffdate_salary) > 1900 Then 1 Else 0 End) As Is_CutOff, Cast(1 As Bit) As NormalSalCycle	
	FROM	T0030_BRANCH_MASTER B WITH (NOLOCK) inner join 
			T0040_GENERAL_SETTING G WITH (NOLOCK) on B.Branch_ID=G.Branch_ID
			INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE, BRANCH_ID 
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
						WHERE	G1.For_Date <= @FOR_DATE 
						GROUP BY G1.BRANCH_ID) G1 ON G.Branch_ID=G1.BRANCH_ID AND G.FOR_DATE=G1.FOR_DATE
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON B.BRANCH_ID=I.BRANCH_ID
			INNER JOIN #EMP_CONS_SAL E ON I.Emp_id=E.EMP_ID
			LEFT OUTER JOIN #EMP_SAL_CYCLE SC ON E.EMP_ID=SC.EMP_ID
			INNER JOIN (
						SELECT	I2.EMP_ID, MAX(I2.INCREMENT_ID) AS INCREMENT_ID 
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN #EMP_CONS_SAL E ON I2.Emp_id=E.EMP_ID
								INNER JOIN (SELECT I3.EMP_ID, MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
											 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #EMP_CONS_SAL E ON I3.Emp_id=E.EMP_ID
											 WHERE I3.Increment_Effective_Date <= @FOR_DATE
											 GROUP BY I3.Emp_ID
											 ) I3 ON I2.Emp_ID=I3.EMP_ID AND I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE
						WHERE	I3.Increment_Effective_Date <= @FOR_DATE
						GROUP BY I2.Emp_ID) I2 ON I.EMP_ID=I2.EMP_ID AND I.INCREMENT_ID=I2.INCREMENT_ID
			LEFT OUTER JOIN Salary_Period SP ON SP.MONTH = MONTH(@FOR_DATE) AND SP.YEAR = YEAR(@FOR_DATE)
	--WHERE	SC.EMP_ID IS NULL	
	WHERE	(SC.EMP_ID IS NULL OR IsNull(G.Manual_Salary_Period,0) = 0)
	
	
	UPDATE	SC
	SET		NormalSalCycle = 0
	FROM	#SAL_CYCLE SC
	WHERE	Sal_St_Date <> Sal_End_Date
	
	UPDATE	SC
	SET		Sal_St_Date = DateAdd(YYYY, Year(@FOR_DATE) - Year(Sal_St_Date) , Sal_St_Date),
			Sal_End_Date = DateAdd(YYYY, Year(@FOR_DATE) - Year(Sal_End_Date) , Sal_End_Date)
	FROM	#SAL_CYCLE SC
	WHERE	Manual_Salary_Period = 0
	
	UPDATE	SC
	SET		Sal_St_Date = DateAdd(M, (Month(@FOR_DATE) - Month(Sal_St_Date)) + (Case When Day(Sal_St_Date) <> 1 THEN -1 Else 0 END), Sal_St_Date),
			Sal_End_Date = DateAdd(M, Month(@FOR_DATE) - Month(Sal_End_Date), Sal_End_Date)
	FROM	#SAL_CYCLE SC
	WHERE	Manual_Salary_Period = 0
	
	
	
	UPDATE	SC
	SET		Sal_End_Date = DateAdd(D, -1, DateAdd(M, 1, Sal_St_Date))
	FROM	#SAL_CYCLE SC
	WHERE	NormalSalCycle = 1 AND Manual_Salary_Period = 0
	
	
	DELETE ESC FROM #EMP_SAL_CYCLE ESC INNER JOIN #SAL_CYCLE SC ON ESC.Emp_id=SC.EMP_ID

	
	--SELECT * FROM #SAL_CYCLE
	
	INSERT INTO #EMP_SAL_PERIOD
	SELECT	Emp_ID,Branch_ID, Salary_St_Date AS Sal_St_Date, DateAdd(D, -1, DateAdd(M, 1, Salary_St_Date)) Sal_End_Date, 0 As Manual_Salary_Period, 0 As Is_CutOff
	, 0 As NormalSalCycle
	,0 as NoOfDays
	FROM	#EMP_SAL_CYCLE
	UNION 
	SELECT	Emp_ID,Branch_ID, Sal_St_Date, Sal_End_Date, Manual_Salary_Period, Is_CutOff, NormalSalCycle,DATEDIFF(day,Sal_St_Date, Sal_End_Date) as NoOfDays
	FROM	#SAL_CYCLE SC
			
			
	IF @HasTable = 0
		SELECT * FROM #EMP_SAL_PERIOD
END


