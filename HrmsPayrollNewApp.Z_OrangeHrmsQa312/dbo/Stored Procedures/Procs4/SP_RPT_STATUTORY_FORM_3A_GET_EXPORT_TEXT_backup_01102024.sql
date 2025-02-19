create PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_3A_GET_EXPORT_TEXT_backup_01102024] @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID VARCHAR(max) = '' --Added By Jaina 5-11-2015 Start
	,@Cat_ID VARCHAR(max) = ''
	,@Grd_ID VARCHAR(max) = ''
	,@Type_ID VARCHAR(max) = ''
	,@Dept_ID VARCHAR(max) = ''
	,@Desig_ID VARCHAR(max) = '' --Added By Jaina 5-11-2015 End
	,@Emp_ID NUMERIC
	,@constraint VARCHAR(MAX)
	,@Segment_Id VARCHAR(max) = '' --Added By Jaina 5-11-2015 Start
	,@Vertical_Id VARCHAR(max) = ''
	,@SubVertical_Id VARCHAR(max) = ''
	,@SubBranch_Id VARCHAR(max) = '' --Added By Jaina 5-11-2015 End    
	,@Format TINYINT = 2 --Added By Jimit 03012016 End   
	,@Export_Type VARCHAR(100) = '' --added by chetan 031017 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @PF_LIMIT AS NUMERIC
DECLARE @PF_DEF_ID AS NUMERIC
DECLARE @Edli_charge AS NUMERIC(18, 2) -- Added by rohit for Edli employee wise.
DECLARE @Admin_Charge_Empwise AS NUMERIC(18, 2) --Added By Ramiz on 21/10/2018

SET @PF_LIMIT = 15000
SET @PF_DEF_ID = 2

IF @Branch_ID = '0'
	OR @Branch_ID = ''
	SET @Branch_ID = NULL

IF @Cat_ID = '0'
	OR @Cat_ID = ''
	SET @Cat_ID = NULL

IF @Grd_ID = '0'
	OR @Grd_ID = ''
	SET @Grd_ID = NULL

IF @Type_ID = '0'
	OR @Type_ID = ''
	SET @Type_ID = NULL

IF @Dept_ID = '0'
	OR @Dept_ID = ''
	SET @Dept_ID = NULL

IF @Desig_ID = '0'
	OR @Desig_ID = ''
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL

IF @Segment_Id = '0'
	OR @Segment_Id = '' --Added By Jaina 5-11-2015 Start 
	SET @Segment_Id = NULL

IF @Vertical_Id = '0'
	OR @Vertical_Id = ''
	SET @Vertical_Id = NULL

IF @SubVertical_Id = '0'
	OR @SubVertical_Id = ''
	SET @SubVertical_Id = NULL

IF @SubBranch_Id = '0'
	OR @SubBranch_Id = '' --Added By Jaina 5-11-2015 End 
	SET @SubBranch_Id = NULL

CREATE TABLE #Emp_Cons (
	Emp_ID NUMERIC
	,Branch_ID NUMERIC
	,--Added By Jaina 5-11-2015
	Increment_ID NUMERIC --Added By Jaina 5-11-2015   
	)

--Added By Mukti(17022017)start
DECLARE @EMP_SALARY_Challan TABLE (
	Cmp_ID NUMERIC
	,Total_NonPF_Subscriber NUMERIC
	,Total_NonPF_Wages NUMERIC(18, 2)
	,Total_Subscriber NUMERIC
	,Total_Wages_Due NUMERIC(18, 2)
	,Total_PF_Diff_Limit NUMERIC(18, 2)
	,AC1_1 NUMERIC(18, 2) DEFAULT 0
	,AC1_2 NUMERIC(18, 2) DEFAULT 0
	,AC2_3 NUMERIC(18, 2) DEFAULT 0
	,AC10_1 NUMERIC(18, 2) DEFAULT 0
	,AC21_1 NUMERIC(18, 2) DEFAULT 0
	,AC22_3 NUMERIC(18, 2) DEFAULT 0
	,AC22_4 NUMERIC(18, 2) DEFAULT 0
	,For_Date DATETIME
	,Payment_Date DATETIME
	,PF_Limit NUMERIC
	,Total_Family_Pension_Subscriber NUMERIC(18, 0)
	,Total_Family_Pension_Wages_Amount NUMERIC(18, 0)
	,Total_EDLI_Subscriber NUMERIC(18, 0)
	,Total_EDLI_Wages_Amount NUMERIC(18, 0)
	,VPF NUMERIC(18, 0)
	)
DECLARE @Total_Wages_Due AS NUMERIC(18, 2)
DECLARE @Total_Subscriber AS NUMERIC
DECLARE @Total_PF_Diff_Limit AS NUMERIC
DECLARE @dblAC1_1 AS NUMERIC(22, 2)
DECLARE @dblAC1_2 AS NUMERIC(22, 2)
DECLARE @dblAC2_3 AS NUMERIC(22, 2)
DECLARE @dblAC10_1 AS NUMERIC(22, 2)
DECLARE @dblAC21_1 AS NUMERIC(22, 2)
DECLARE @dblAC22_3 AS NUMERIC(22, 2)
DECLARE @dblAC22_4 NUMERIC
DECLARE @dbl833 AS NUMERIC(22, 2)
DECLARE @dbl367 AS NUMERIC(22, 2)
DECLARE @Total_PF_Amount AS NUMERIC
DECLARE @MONTH NUMERIC
DECLARE @Year NUMERIC
DECLARE @Total_Family_Pension_Subscriber NUMERIC(18, 0)
DECLARE @Total_Family_Pension_Wages_Amount NUMERIC(18, 0)
DECLARE @Total_EDLI_Subscriber NUMERIC(18, 0)
DECLARE @Total_EDLI_Wages_Amount NUMERIC(18, 0)
DECLARE @VPF AS NUMERIC(18, 0)
DECLARE @AC_2_3 NUMERIC(10, 2)
DECLARE @AC_21_1 NUMERIC(10, 2)
DECLARE @AC_22_3 NUMERIC(10, 4)
DECLARE @AC_22_4 NUMERIC(10, 4)
DECLARE @Payment_Date DATETIME
DECLARE @Sal_St_Date DATETIME
DECLARE @Sal_end_Date DATETIME
DECLARE @IS_NCP_PRORATA AS INT
--Added By Mukti(17022017)end
DECLARE @PF_Pension_Age AS NUMERIC(18, 2)
DECLARE @manual_salary_period AS NUMERIC(18, 0)
DECLARE @Total_NonPF_Subcriber AS NUMERIC
DECLARE @Total_NonPF_Wages AS NUMERIC(18, 2)

--Added By Jaina 5-11-2015
EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID
	,@From_Date
	,@To_Date
	,@Branch_ID
	,@Cat_ID
	,@Grd_ID
	,@Type_ID
	,@Dept_ID
	,@Desig_ID
	,@Emp_ID
	,@constraint
	,0
	,0
	,@Segment_Id
	,@Vertical_Id
	,@SubVertical_Id
	,@SubBranch_Id
	,0
	,0
	,0
	,''
	,0
	,0

SET @IS_NCP_PRORATA = 0

IF @Branch_ID IS NULL
BEGIN
	SELECT TOP 1 @Sal_St_Date = Sal_st_Date
		,@PF_LIMIT = PF_LIMIT
		,@IS_NCP_PRORATA = IS_NCP_PRORATA
		,@EDLI_CHARGE = ISNULL(GD.ACC_21_1, 0)
		,@Admin_Charge_Empwise = ISNULL(GD.ACC_21_1, 0)
		,@PF_Pension_Age = ISNULL(GD.PF_PENSION_AGE, 0)
		,@manual_salary_period = isnull(Manual_Salary_Period, 0)
	FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)
	INNER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) ON GS.Gen_ID = GD.GEN_ID
		AND GS.Cmp_ID = GD.CMP_ID
	WHERE GS.Cmp_ID = @cmp_ID
		AND For_Date = (
			SELECT max(For_Date)
			FROM T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE For_Date <= @From_Date
				AND Cmp_ID = @Cmp_ID
			)
END
ELSE
BEGIN
	--select @Sal_St_Date  =Sal_st_Date, @PF_LIMIT =  PF_LIMIT , @IS_NCP_PRORATA = IS_NCP_PRORATA,@Edli_charge=GD.ACC_21_1
	--  from T0040_GENERAL_SETTING GS Inner Join T0050_GENERAL_DETAIL GD On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID
	--  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=GS.Branch_ID 
	--  where GS.Cmp_ID = @cmp_ID 
	--  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING G1
	--  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T1 ON T1.Branch_ID=G1.Branch_ID 
	--  where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)
	SELECT @Sal_St_Date = Sal_st_Date
		,@PF_LIMIT = PF_LIMIT
		,@IS_NCP_PRORATA = IS_NCP_PRORATA
		,@EDLI_CHARGE = ISNULL(GD.ACC_21_1, 0)
		,@Admin_Charge_Empwise = ISNULL(GD.ACC_21_1, 0)
		,@PF_Pension_Age = ISNULL(GD.PF_PENSION_AGE, 0)
		,@manual_salary_period = isnull(Manual_Salary_Period, 0)
	FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)
	INNER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) ON GS.GEN_ID = GD.GEN_ID
	WHERE GS.CMP_ID = @CMP_ID
		AND EXISTS (
			SELECT Data
			FROM dbo.Split(ISNULL(@Branch_ID, gs.Branch_ID), '#') B
			WHERE cast(B.data AS NUMERIC) = Isnull(Branch_ID, 0)
			) --Added By Jaina 5-11-2015
		AND For_Date IN (
			SELECT MAX(For_Date)
			FROM T0040_GENERAL_SETTING G WITH (NOLOCK)
			WHERE G.Cmp_Id = @cmp_Id
				AND G.For_Date <= @To_Date
				AND EXISTS (
					SELECT Data
					FROM dbo.Split(ISNULL(@Branch_ID, G.Branch_ID), '#') B
					WHERE cast(B.data AS NUMERIC) = Isnull(G.Branch_ID, 0)
					) --Added By Jaina 5-11-2015
			)
END

IF ISNULL(@Sal_St_Date, '') = ''
BEGIN
	SET @From_Date = @From_Date
	SET @To_Date = @To_Date
END
ELSE IF day(@Sal_St_Date) = 1 --and month(@Sal_St_Date)=1    
BEGIN
	SET @From_Date = @From_Date
	SET @To_Date = @To_Date
END
ELSE IF @Sal_St_Date <> ''
	AND day(@Sal_St_Date) > 1
BEGIN
	--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	--set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	--set @From_Date = @Sal_St_Date
	--Set @To_Date = @Sal_end_Date   
	IF @manual_salary_period = 0
	BEGIN
		SET @Sal_St_Date = cast(cast(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + cast(datename(mm, dateadd(m, - 1, @From_Date)) AS VARCHAR(10)) + '-' + cast(year(dateadd(m, - 1, @From_Date)) AS VARCHAR(10)) AS SMALLDATETIME)
		SET @Sal_End_Date = dateadd(d, - 1, dateadd(m, 1, @Sal_St_Date))
		SET @From_Date = @Sal_St_Date
		SET @To_Date = @Sal_End_Date
	END
	ELSE
	BEGIN
		SELECT @Sal_St_Date = from_date
			,@Sal_End_Date = end_date
		FROM salary_period
		WHERE month = month(@To_Date)
			AND YEAR = year(@To_Date)

		SET @From_Date = @Sal_St_Date
		SET @To_Date = @Sal_End_Date
	END
END

--------
DECLARE @TEMP_DATE AS DATETIME
DECLARE @PF_REPORT TABLE (
	MONTH NUMERIC
	,YEAR NUMERIC
	,FOR_DATE DATETIME
	)

SET @TEMP_DATE = @FROM_DATE

WHILE @TEMP_DATE <= @TO_DATE
BEGIN
	INSERT INTO @PF_REPORT (
		MONTH
		,YEAR
		,FOR_DATE
		)
	VALUES (
		MONTH(@TEMP_DATE)
		,YEAR(@TEMP_DATE)
		,@TEMP_DATE
		)

	SET @TEMP_DATE = DATEADD(m, 1, @TEMP_DATE)
END

IF Object_ID('tempdb..#EMP_PF_REPORT') IS NOT NULL
BEGIN
	DROP TABLE #EMP_PF_REPORT
END

CREATE TABLE #EMP_PF_REPORT (
	CMP_ID NUMERIC
	,EMP_CODE NUMERIC
	,EMP_ID NUMERIC
	,EMP_NAME VARCHAR(85) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,PF_NO VARCHAR(85) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,MONTH NUMERIC
	,YEAR NUMERIC
	,FOR_DATE DATETIME
	)

INSERT INTO #EMP_PF_REPORT
SELECT QRY.CMP_ID
	,QRY.EMP_CODE
	,QRY.EMP_ID
	,Emp_Name
	,CASE 
		WHEN CHARINDEX('/', PF_NO, 1) > 0
			THEN Right(Right(PF_NO, CHARINDEX('/', Reverse(PF_NO), 1) - 1), 7)
		ELSE Left(PF_NO, 50)
		END
	,t.month
	,t.year
	,t.for_Date
FROM @PF_Report t
CROSS JOIN (
	SELECT DISTINCT SG.CMP_ID
		,SG.EMP_ID
		,E.EMP_CODE
		,Replace(Replace(Replace(Replace(ISNULL(E.EmpName_Alias_PF, E.Emp_First_Name + ' ' + E.Emp_Second_Name + ' ' + E.Emp_Last_Name), 'Mr. ', ''), 'Ms. ', ''), 'Dr. ', ''), 'Mrs. ', '') AS Emp_Name
		,E.SSN_No AS PF_NO
	FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK)
	INNER JOIN (
		SELECT Emp_ID
			,M_AD_Percentage AS PF_PER
			,M_AD_Amount AS PF_Amount
			,sal_Tran_ID
		FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
		WHERE AD_DEF_ID = @PF_DEF_ID
			AND ad_not_effect_salary <> 1
			AND AD.CMP_ID = @CMP_ID
		) MAD ON SG.Emp_ID = MAD.Emp_ID
		AND SG.Sal_Tran_ID = MAD.Sal_Tran_ID
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID
	INNER JOIN #EMP_CONS E_S ON E.Emp_ID = E_S.Emp_ID
	WHERE e.CMP_ID = @CMP_ID
		AND SG.Month_St_Date >= @From_Date
		AND SG.Month_End_Date <= @To_Date
	) QRY

IF Object_ID('tempdb..#EMP_DETAIL') IS NOT NULL
BEGIN
	DROP TABLE #EMP_DETAIL
END

CREATE TABLE #EMP_DETAIL (
	CMP_ID NUMERIC
	,EMP_ID NUMERIC
	,FATHER_HUSBAND_NAME VARCHAR(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,RELATION VARCHAR(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,DOB VARCHAR(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,GENDER VARCHAR(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,DOJ VARCHAR(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,LEFT_DATE VARCHAR(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,LEFT_REASON VARCHAR(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)

INSERT INTO #EMP_DETAIL
SELECT QRY.CMP_ID
	,QRY.EMP_ID
	,CASE 
		WHEN Month(Date_Of_Join) = Month(@To_Date)
			AND Year(Date_Of_Join) = Year(@To_Date)
			THEN ISNULL(Father_name, '') + '#~#' --Add ISNULL Condition --Ankit 19012015
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Date_Of_Join) = Month(@To_Date)
			AND Year(Date_Of_Join) = Year(@To_Date)
			THEN CASE 
					WHEN Gender = 'F'
						AND Marital_Status = 1
						THEN 'S#~#'
					ELSE 'F#~#'
					END
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Date_Of_Join) = Month(@To_Date)
			AND Year(Date_Of_Join) = Year(@To_Date)
			THEN isnull(Convert(VARCHAR(10), Date_Of_Birth, 103), '') + '#~#'
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Date_Of_Join) = Month(@To_Date)
			AND Year(Date_Of_Join) = Year(@To_Date)
			THEN Gender + '#~#'
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Date_Of_Join) = Month(@To_Date)
			AND Year(Date_Of_Join) = Year(@To_Date)
			THEN Convert(VARCHAR(10), Date_Of_Join, 103) + '#~#'
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Emp_Left_Date) = Month(@To_Date)
			AND Year(Emp_Left_Date) = Year(@To_Date)
			THEN Convert(VARCHAR(10), Emp_Left_Date, 103) + '#~#'
		ELSE '#~#'
		END
	,CASE 
		WHEN Month(Emp_Left_Date) = Month(@To_Date)
			AND Year(Emp_Left_Date) = Year(@To_Date)
			THEN CASE 
					WHEN Is_Death = 1
						THEN 'D'
					ELSE 'C'
					END
		ELSE ''
		END
FROM (
	SELECT TOP 1 *
	FROM @PF_Report
	) t
CROSS JOIN (
	SELECT DISTINCT SG.CMP_ID
		,SG.EMP_ID
		,E.EMP_CODE
		,E.Emp_First_Name + ' ' + E.Emp_Last_Name AS Emp_Name
		,SSN_NO AS PF_NO
		,E.Father_name
		,E.Date_Of_Join
		,E.Date_Of_Birth
		,E.Gender
		,E.Marital_Status
		,E.Emp_Left_Date
		,LE.Is_Death
	FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK)
	INNER JOIN (
		SELECT Emp_ID
			,M_AD_Percentage AS PF_PER
			,M_AD_Amount AS PF_Amount
			,sal_Tran_ID
		FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
		WHERE AD_DEF_ID = @PF_DEF_ID
			AND ad_not_effect_salary <> 1
			AND AD.CMP_ID = @CMP_ID
		) MAD ON SG.Emp_ID = MAD.Emp_ID
		AND SG.Sal_Tran_ID = MAD.Sal_Tran_ID
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID
	INNER JOIN #EMP_CONS E_S ON E.Emp_ID = E_S.Emp_ID
	LEFT OUTER JOIN T0100_LEFT_EMP LE WITH (NOLOCK) ON E.Emp_ID = LE.Emp_ID
	WHERE e.CMP_ID = @CMP_ID
		AND SG.Month_St_Date >= @From_Date
		AND SG.Month_End_Date <= @To_Date
	) QRY

IF Object_ID('tempdb..#EMP_SALARY') IS NOT NULL
BEGIN
	DROP TABLE #EMP_SALARY
END

CREATE TABLE #EMP_SALARY (
	EMP_ID NUMERIC
	,MONTH NUMERIC
	,YEAR NUMERIC
	,SALARY_AMOUNT NUMERIC
	,OTHER_PF_SALARY NUMERIC
	,MONTH_ST_DATE DATETIME
	,MONTH_END_DATE DATETIME
	,PF_PER NUMERIC(18, 2)
	,PF_AMOUNT NUMERIC
	,PF_SALARY_AMOUNT NUMERIC
	,PF_LIMIT NUMERIC
	,PF_367 NUMERIC
	,PF_833 NUMERIC
	,PF_DIFF_6500 NUMERIC
	,VPF NUMERIC
	,Emp_Age NUMERIC(10, 2)
	,--Change the size by ronak 1102023 
	Sal_Cal_Day NUMERIC(18, 2)
	,-- Added by Falak on 09-MAY-2011
	Absent_days NUMERIC
	,Is_Sett TINYINT DEFAULT 0
	,--Nikunj 25-04-2011
	Sal_Effec_Date DATETIME DEFAULT GetDate()
	,--Nikunj 25-04-2011
	EDLI_Wages NUMERIC
	,Arear_Day NUMERIC(18, 2)
	,arrear_days NUMERIC(18, 1)
	,VPF_PER NUMERIC(18, 2)
	,Arrear_Wages NUMERIC
	,--Hardik 17/04/2012
	Arrear_PF_Amount NUMERIC
	,--Hardik 17/04/2012
	Arrear_PF_833 NUMERIC
	,--Hardik 17/04/2012
	Arrear_PF_367 NUMERIC
	,--Hardik 17/04/2012,
	Nationality VARCHAR(100)
	,cmp_full_pf TINYINT
	,Arear_M_AD_Amount NUMERIC(18, 2)
	,Arear_M_AD_Calculated_Amount NUMERIC(18, 2)
	,Arrear_Wages_833 NUMERIC DEFAULT 0
	,--Hardik 12/01/2017
	Gross_Salary NUMERIC(18, 2)
	,--Mukti(18022017)
	Arrear_VPF_Amount NUMERIC(18, 2)
	,--Hardik 26/12/2017
	PF_Admin_Charge_Empwise NUMERIC(18, 2)
	,--Ramiz 20/10/2018
	Edli_Charge_EmpWise NUMERIC(18, 2)
	,--Ramiz 20/10/2018
	Arrear_PF_Admin_Charge_Empwise NUMERIC(18, 2)
	,Arrear_Edli_Charge_EmpWise NUMERIC(18, 2)
	--PFsettID		integer
	,Pension_Not_Applicable NUMERIC(18, 2)
	,CMP_PF NUMERIC(18, 2) -- Added by ronakk 10082023
	)

DECLARE @String AS VARCHAR(max)

INSERT INTO #EMP_SALARY
SELECT
	--m_ad_Calculated_Amount a,sg.basic_salary b, Isnull(Qr_1.M_AREAR_AMOUNT1,0) c,
	--m_ad_Calculated_Amount + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) end,
	SG.EMP_ID
	,MONTH(MONTH_ST_DATe)
	,YEAR(MONTH_ST_DATE)
	,SG.Salary_Amount
	,0
	,sg.Month_st_Date
	,SG.Month_End_date
	,MAD.PF_PER
	,MAD.PF_AMOUNT
	,--(m_ad_Calculated_Amount + Arear_Basic) as m_ad_Calculated_Amount,
	--(m_ad_Calculated_Amount )--+ Isnull(Basic_Salary_Arear_cutoff,0)) --+ isnull(Other_PF_Calculate,0)) 
	CASE 
		WHEN @Format IN (8)
			THEN
				--Arear_Basic  + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end 
				CASE 
					WHEN (
							Arear_Basic + CASE 
								WHEN OAB.basic_salary < @PF_Limit
									THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
								ELSE 0
								END + Arear_M_AD_Calculated_Amount
							) < @PF_LIMIT
						THEN Arear_Basic + CASE 
								WHEN OAB.basic_salary < @PF_Limit
									THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
								ELSE 0
								END
					ELSE CASE 
							WHEN Arear_M_AD_Calculated_Amount < @PF_Limit
								AND OAB.Basic_Salary < @PF_LIMIT
								THEN @PF_LIMIT - Arear_M_AD_Calculated_Amount
							ELSE Arear_Basic + CASE 
									WHEN OAB.basic_salary < @PF_Limit
										THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
									ELSE 0
									END
							END
					END
		WHEN @Format IN (
				4
				,5
				,10
				,2
				)
			THEN m_ad_Calculated_Amount + CASE 
					WHEN sg.basic_salary < @PF_Limit
						THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
					ELSE 0
					END
		ELSE m_ad_Calculated_Amount
		END AS m_ad_Calculated_Amount
	,
	--m_ad_Calculated_Amount as m_ad_Calculated_Amount,
	@PF_Limit
	,0
	,0
	,0
	,isnull(CMD.VPF, 0)
	,dbo.F_GET_AGE(Date_of_Birth, MONTH_ST_DATE, 'N', 'N')
	,SG.Sal_Cal_Days
	,0
	,0
	,NULL
	,0
	,Isnull(sg.Arear_Day, 0) -- Added by Falak on 09-MAY-2011
	,SG.arear_day
	,VPF_PER
	,-- added by mitesh on 18/02/2012
	CASE 
		WHEN @Format IN (
				3
				,8
				,4
				,10
				,2
				)
			THEN
				--(Isnull(Arear_Basic,0)) + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end  
				CASE 
					WHEN (
							Arear_Basic + CASE 
								WHEN OAB.basic_salary < @PF_Limit
									THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
								ELSE 0
								END + Arear_M_AD_Calculated_Amount
							) < @PF_LIMIT
						THEN Arear_Basic + CASE 
								WHEN OAB.basic_salary < @PF_Limit
									THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
								ELSE 0
								END
					ELSE CASE 
							WHEN Arear_M_AD_Calculated_Amount < @PF_Limit
								AND OAB.Basic_Salary < @PF_LIMIT
								THEN @PF_LIMIT - Arear_M_AD_Calculated_Amount
							ELSE Arear_Basic + CASE 
									WHEN OAB.basic_salary < @PF_Limit
										THEN Isnull(Qr_1.M_AREAR_AMOUNT1, 0)
									ELSE 0
									END
							END
					END
		ELSE (Isnull(Arear_Basic, 0))
		END AS Arear_Basic --+ Isnull(Basic_Salary_Arear_cutoff,0) + isnull(Other_PF_Calculate,0) ) as Arear_Basic 
	,Isnull(M_AREAR_AMOUNT, 0)
	,0
	,0
	,Nationality
	,isnull(emp_auto_vpf, 0) --added by hasmukh on 06 08 2013 for company full pf
	,ISNULL(Qry_arear.Arear_M_AD_Amount, 0)
	,ISNULL(Qry_arear.Arear_M_AD_Calculated_Amount, 0) + Isnull(Other_Arear_Basic, 0) - Isnull(Arear_Basic, 0)
	,0
	,SG.Gross_Salary
	,VPF_Arear
	,0
	,0
	,0
	,0
	,isnull(inc.Is_1time_PF_Member, 0)
	,(
		SELECT (m_ad_Amount + isnull(M_AREAR_AMOUNT_Cutoff, 0)) AS PF_Amount
		FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
		INNER JOIN t0200_monthly_salary MS WITH (NOLOCK) ON AD.sal_tran_id = ms.sal_tran_id
		WHERE ad_DEF_id = 5
			AND AD.CMP_ID = @Cmp_ID
			AND AD.sal_tran_id = SG.Sal_Tran_ID
		)
FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK)
INNER JOIN (
	SELECT ad.Emp_ID
		,m_ad_Percentage AS PF_PER
		,--(m_ad_Amount + M_AREAR_AMOUNT) as PF_Amount,
		(m_ad_Amount + isnull(M_AREAR_AMOUNT_Cutoff, 0)) AS PF_Amount
		,(isnull(M_AREAR_AMOUNT, 0)) AS M_AREAR_AMOUNT --+isnull(M_AREAR_AMOUNT_Cutoff,0)) as M_AREAR_AMOUNT ,  + ISNULL(Arear_Basic,0)
		,m_ad_Calculated_Amount + CASE 
			WHEN @Format IN (
					4
					,5
					,2
					)
				THEN ISNULL(Arear_Basic, 0)
			ELSE 0
			END + (
			CASE 
				WHEN isnull(ad.M_AREAR_AMOUNT_Cutoff, 0) = 0
					THEN 0
				ELSE MS.Basic_Salary_Arear_cutoff
				END
			) AS m_ad_Calculated_Amount
		,ad.SAL_tRAN_ID
		,M_AREAR_AMOUNT_Cutoff
	FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
	INNER JOIN t0200_monthly_salary MS WITH (NOLOCK) ON AD.sal_tran_id = ms.sal_tran_id
	WHERE ad_DEF_id = @PF_DEF_ID
		AND ad_not_effect_salary <> 1
		AND sal_type <> 1
		AND AD.CMP_ID = @CMP_ID
	) MAD ON SG.Emp_ID = MAD.Emp_ID
	AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID
INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID
INNER JOIN t0095_increment inc WITH (NOLOCK) ON Sg.increment_id = inc.increment_id
INNER JOIN #EMP_CONS E_S ON E.Emp_ID = E_S.Emp_ID
LEFT OUTER JOIN (
	SELECT Emp_ID
		,M_AD_Amount AS VPF
		,isnull(M_AREAR_AMOUNT, 0) + isnull(M_AREAR_AMOUNT_Cutoff, 0) AS VPF_Arear
		,SAL_tRAN_ID
		,AD.M_AD_Percentage AS VPF_PER
	FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
	WHERE ad_DEF_id = 4
		AND ad_not_effect_salary <> 1
		AND sal_type <> 1
		AND AD.CMP_ID = @CMP_ID
	) CMD ON SG.Emp_ID = CMD.Emp_ID
	AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID
LEFT OUTER JOIN (
	SELECT Emp_ID
		,(isnull(M_AREAR_AMOUNT, 0) + isnull(M_AREAR_AMOUNT_Cutoff, 0)) AS Other_PF_Calculate
		,SAL_tRAN_ID
	FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
	WHERE AD.ad_id = (
			SELECT TOP 1 EAM.AD_ID
			FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK) --Added By Jaina 5-11-2015 (Top 1)
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EAM.Effect_AD_ID = AM.AD_ID
				AND EAM.CMP_ID = AM.CMP_ID
			WHERE AM.AD_DEF_ID = @PF_DEF_ID
				AND Am.Cmp_ID = @Cmp_ID
			)
		AND ad_not_effect_salary <> 1
		AND sal_type <> 1
		AND AD.CMP_ID = @CMP_ID
	) CMD_new ON SG.Emp_ID = CMD_new.Emp_ID
	AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID
LEFT OUTER JOIN (
	SELECT MAD1.Emp_ID
		,m_ad_Amount AS arear_m_ad_Amount
		,m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount
		,MAD1.For_Date
		,MAD1.To_date
	FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID
	INNER JOIN #EMP_CONS Qry1 ON MAD1.Emp_ID = Qry1.Emp_ID
	WHERE ad_DEF_id = @PF_DEF_ID
		AND ad_not_effect_salary <> 1
		AND sal_type <> 1
	) Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID
	AND Qry_arear.For_Date >= CASE 
		WHEN SG.Arear_Month <> 0
			THEN dbo.GET_MONTH_ST_DATE(SG.Arear_Month, SG.Arear_Year)
		ELSE dbo.GET_MONTH_ST_DATE(NULL, NULL)
		END
	AND Qry_arear.to_date <= CASE 
		WHEN SG.Arear_Month <> 0
			THEN dbo.GET_MONTH_END_DATE(SG.Arear_Month, SG.Arear_Year)
		ELSE dbo.GET_MONTH_END_DATE(NULL, NULL)
		END
LEFT OUTER JOIN (
	SELECT MS.Emp_ID
		,Sum(MS.Arear_Basic) AS Other_Arear_Basic
		,MS.Arear_Month
		,MS.Arear_Year
		,basic_salary
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #EMP_CONS EC1 ON MS.Emp_ID = EC1.Emp_ID
	WHERE Isnull(MS.Arear_Month, 0) <> 0
		AND Isnull(MS.Arear_Year, 0) <> 0
		AND MS.Month_End_Date <= @To_Date
	GROUP BY MS.Emp_ID
		,MS.Arear_Month
		,MS.Arear_Year
		,basic_salary
	) OAB ON SG.Emp_ID = OAB.Emp_ID
	AND SG.Arear_Month = OAB.Arear_Month
	AND SG.Arear_Year = OAB.Arear_Year
LEFT OUTER JOIN (
	SELECT MAD1.EMP_ID
		,ISNULL(SUM(M_AREAR_AMOUNT), 0) + ISNULL(SUM(M_AREAR_AMOUNT_Cutoff), 0) AS M_AREAR_AMOUNT1
		,MONTH(MAD1.To_DATE) AS monthArrear
		,Year(MAD1.To_DATE) AS YearArrear
	FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID
	INNER JOIN #EMP_CONS Qry1 ON MAD1.Emp_ID = Qry1.Emp_ID
	WHERE MONTH(MAD1.To_DATE) = MONTH(@TO_DATE)
		AND YEAR(MAD1.To_DATE) = YEAR(@To_Date)
		AND ad_not_effect_salary = 0
		AND AD_FLAG = 'I' --and M_AREAR_AMOUNT <> 0 -- Commented by Hardik 07/08/2020 for WHFL Case, cutoff Allowance minus amounts not adding in PF Wages
		AND AM.ad_id IN (
			SELECT EAM.AD_ID
			FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EAM.Effect_AD_ID = AM.AD_ID
				AND EAM.CMP_ID = AM.CMP_ID
			WHERE AM.AD_DEF_ID = @PF_DEF_ID
				AND Am.Cmp_ID = @Cmp_ID
			)
	GROUP BY MAD1.Emp_ID
		,Mad1.To_date
	) Qr_1 ON Qr_1.EMP_ID = SG.Emp_id --and SG.Arear_Month=Qr_1.monthArrear And SG.Arear_Year=Qr_1.YearArrear
WHERE e.CMP_ID = @CMP_ID --changed by Falak on 04-JAN-2010 due error in condition and more than one record for same emp binds.
	AND SG.Month_St_Date >= @From_Date
	AND SG.Month_End_Date <= @To_Date

--select Arrear_Wages,PF_SALARY_AMOUNT,* from #EMP_SALARY--mansi
--In form 3a you have to saw March Challn Paid in April.for This Setting you can see in Report Leval Formula.Nikunj
-----By nikunj 25-04-2011 For Settlement Pf Effect In Form 3A--------------------------Start
IF EXISTS (
		SELECT S_Sal_Tran_Id
		FROM dbo.T0201_monthly_salary_sett WITH (NOLOCK)
		WHERE S_Eff_Date BETWEEN @From_Date
				AND @To_Date
			AND Cmp_Id = @Cmp_Id
		)
BEGIN
	-- print 222---mansi
	INSERT INTO #EMP_SALARY
	SELECT SG.EMP_ID
		,MONTH(S_MONTH_ST_DATe)
		,YEAR(S_MONTH_ST_DATE)
		,SG.s_Salary_Amount
		,0
		,sg.S_Month_st_Date
		,SG.S_Month_End_date
		,MAD.PF_PER
		,MAD.PF_AMOUNT
		,m_ad_Calculated_Amount
		,@PF_Limit
		,0
		,0
		,0
		,0 --isnull(CMD.VPF,0)
		,dbo.F_GET_AGE(Date_of_Birth, S_MONTH_ST_DATE, 'N', 'N')
		,
		--SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0, -- Added by Falak on 09-MAY-2011
		SG.S_Sal_Cal_Days
		,0
		,1
		,SG.S_Eff_date
		,0
		,0
		,0
		,VPF_PER
		,-- Added by Falak on 09-MAY-2011 --Hardik 26/12/2017
		0
		,(ISNULL(M_AREAR_AMOUNT, 0)) AS M_AREAR_AMOUNT
		,0
		,0
		,Nationality
		,isnull(emp_auto_vpf, 0) --added by hasmukh on 06 08 2013 for company full pf
		,ISNULL(Qry_arear.Arear_M_AD_Amount, 0)
		,ISNULL(Qry_arear.Arear_M_AD_Calculated_Amount, 0)
		,0
		,SG.S_Gross_Salary
		,VPF_Arear
		,0
		,0
		,0
		,0
		,isnull(inc.Is_1time_PF_Member, 0)
	--,0 --added mansi
	FROM t0201_monthly_salary_sett SG WITH (NOLOCK)
	INNER JOIN (
		SELECT Emp_ID
			,m_ad_Percentage AS PF_PER
			,--(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as PF_Amount
			m_ad_Amount AS PF_Amount
			,(isnull(M_AREAR_AMOUNT, 0) + isnull(M_AREAR_AMOUNT_Cutoff, 0)) AS M_AREAR_AMOUNT
			,m_ad_Calculated_Amount
			,S_SAL_tRAN_ID
		FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
		WHERE ad_DEF_id = @PF_DEF_ID
			AND ad_not_effect_salary <> 1
			AND ad.sal_type = 1
			AND AD.CMP_ID = @CMP_ID
			AND m_ad_Amount <> 0 ---- Greter Than Zero Condition --Ankit 06062016
		) MAD ON SG.Emp_ID = MAD.Emp_ID
		AND SG.S_SAL_tRAN_ID = MAD.S_SAL_TRAN_ID
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID
	INNER JOIN t0095_increment inc WITH (NOLOCK) ON Sg.increment_id = inc.increment_id
	INNER JOIN #EMP_CONS E_S ON E.Emp_ID = E_S.Emp_ID
	LEFT OUTER JOIN
		--Change Condition from Sal_Tran_Id to S_Sal_Tran_Id by Hardik 03/12/2016 for Wonder case for Twice Salary Settlement
		--(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
		(
		SELECT Emp_ID
			,(m_ad_Amount + isnull(M_AREAR_AMOUNT, 0) + isnull(M_AREAR_AMOUNT_Cutoff, 0)) AS VPF_Arear
			,AD.S_Sal_Tran_ID
			,AD.M_AD_Percentage AS VPF_PER
		FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID
		WHERE ad_DEF_id = 4
			AND ad_not_effect_salary <> 1
			AND sal_type = 1
			AND AD.CMP_ID = @CMP_ID
		) CMD ON SG.Emp_ID = CMD.Emp_ID
		AND SG.S_Sal_Tran_ID = CMD.S_Sal_Tran_ID
	LEFT OUTER JOIN --Get Arear Calculated Amount --Ankit 06042016
		(
		SELECT MAD1.Emp_ID
			,m_ad_Amount AS arear_m_ad_Amount
			,m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount
			,MAD1.For_Date
			,MAD1.To_date
			,Sal_Tran_ID
		FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID
		INNER JOIN #EMP_CONS Qry1 ON MAD1.Emp_ID = Qry1.Emp_ID
		WHERE ad_DEF_id = @PF_DEF_ID
			AND ad_not_effect_salary <> 1
			AND sal_type <> 1
		) Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID
		AND SG.Sal_Tran_ID = Qry_arear.Sal_Tran_ID
	WHERE e.CMP_ID = @CMP_ID
		AND S_Eff_Date BETWEEN @From_Date
			AND @To_Date

	--and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date 
	---Ankit----
	UPDATE #EMP_SALARY
	SET PF_833 = PF_SALARY_AMOUNT * 0.0833
		,PF_367 = PF_AMOUNT - (PF_SALARY_AMOUNT * 0.0833)
	WHERE Is_Sett = 1

	UPDATE #EMP_SALARY
	SET Arrear_PF_833 = CASE 
			WHEN (PF_833 + ROUND(Arear_M_AD_Calculated_Amount * 0.0833, 2)) > 1250
				THEN 1250 - ROUND((Arear_M_AD_Calculated_Amount * 0.0833), 2)
			ELSE PF_833
			END
		,Arrear_PF_367 = (PF_Amount) - CASE 
			WHEN (PF_833 + ROUND(Arear_M_AD_Calculated_Amount * 0.0833, 2)) > 1250
				THEN 1250 - ROUND((Arear_M_AD_Calculated_Amount * 0.0833), 2)
			ELSE PF_833
			END
	WHERE Round((Arear_M_AD_Calculated_Amount * 0.0833), 0) < 1250
		AND Is_Sett = 1
		AND Arear_M_AD_Calculated_Amount <> 0

	UPDATE #EMP_SALARY
	SET Arrear_PF_833 = 0
		,Arrear_PF_367 = (PF_Amount)
	WHERE ROUND((Arear_M_AD_Calculated_Amount * 0.0833), 0) >= 1250
		AND Is_Sett = 1

	---Ankit ----
	--Update #EMP_SALARY Set 
	--Salary_Amount= ES.Salary_Amount+Qry.Salary_Amount,
	--PF_Amount=ES.PF_Amount+Qry.PF_Amount,
	--PF_Salary_Amount=ES.PF_Salary_Amount+Qry.PF_Salary_Amount, 
	--VPF = es.VPF + qry.VPF From 
	--#EMP_SALARY As ES INNER JOIN
	--(Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,SUM(VPF) as VPF,Emp_Id,Sal_Effec_Date From #EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)
	UPDATE #EMP_SALARY
	SET Arrear_Wages_833 = CASE 
			WHEN isnull(Arear_M_AD_Calculated_Amount, 0) + PF_SALARY_AMOUNT <= PF_Limit
				THEN -- Chnage SALARY_AMOUNT to PF_SALARY_AMOUNT BY Hardik 26/09/2018 for Daimines
					PF_SALARY_AMOUNT
			WHEN PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount, 0)
				THEN PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount, 0)
			ELSE 0
			END
		,Arrear_PF_833 = round((
				CASE 
					WHEN isnull(Arear_M_AD_Calculated_Amount, 0) + PF_SALARY_AMOUNT <= PF_Limit
						THEN PF_SALARY_AMOUNT
					WHEN PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount, 0)
						THEN PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount, 0)
					ELSE 0
					END
				) * 0.0833, 0)
	WHERE Is_Sett = 1

	--select  Arrear_Wages,PF_SALARY_AMOUNT,* from #EMP_SALARY--mansi
	--- Commented above code by Hardik and Add below code by Hardik 03/01/2013 for Settlement Amount show in Arear Columns
	UPDATE #EMP_SALARY
	SET Arrear_Wages = Isnull(Arrear_Wages, 0) + Isnull(Qry.PF_Salary_Amount, 0)
		,Arrear_PF_Amount = Isnull(Arrear_PF_Amount, 0) + Isnull(Qry.PF_Amount, 0)
		--VPF = es.VPF + qry.VPF --Hardik 26/12/2017
		,Arrear_PF_833 = qry.Arrear_PF_833
		,Arrear_PF_367 = qry.Arrear_PF_367
		,PF_833 = 0
		,PF_367 = 0
		,is_sett = 2
		,Arrear_Wages_833 = Qry.Arrear_Wages_833
		,Arrear_VPF_Amount = Qry.Arrear_VPF_Amount --Hardik 26/12/2017
	FROM #EMP_SALARY AS ES
	INNER JOIN (
		SELECT SUM(Salary_Amount) AS Salary_Amount
			,SUM(PF_Amount) AS PF_Amount
			,SUM(PF_Salary_Amount) AS PF_Salary_Amount
			,SUM(VPF) AS VPF
			,Emp_Id
			,Sal_Effec_Date
			,SUM(Arrear_PF_833) AS Arrear_PF_833
			,SUM(Arrear_PF_367) AS Arrear_PF_367
			,Sum(Arrear_Wages_833) AS Arrear_Wages_833
			,SUM(Arrear_VPF_Amount) AS Arrear_VPF_Amount
		FROM #EMP_SALARY
		WHERE Is_Sett = 1
		GROUP BY Emp_Id
			,Sal_Effec_Date
		) AS Qry ON ES.Emp_Id = Qry.Emp_ID
		AND ES.Month = Month(Qry.Sal_Effec_Date)
		AND ES.Year = Year(Qry.Sal_Effec_Date)

	DELETE
	FROM #EMP_SALARY
	WHERE Is_Sett = 1
END

------------------------------------------------------------------------------------------End
--select  Arrear_Wages,PF_SALARY_AMOUNT,* from #EMP_SALARY--mansi
DECLARE @PF_NOT_FUll_AMT AS NUMERIC(18, 2)
DECLARE @PF_541 AS NUMERIC(18, 2)

--DECLARE @PF_Pension_Age as numeric(18,2)
--SELECT TOP 1 @PF_Pension_Age = isnull(GD.PF_PENSION_AGE,0)
--FROM T0040_General_setting gs 
--	INNER JOIN T0050_General_Detail gd on gs.gen_Id =gd.gen_ID     
--WHERE gs.Cmp_Id=@cmp_Id
--	AND EXISTS (select Data from dbo.Split(ISNULL(@Branch_ID,gs.Branch_ID), '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))  --Added By Jaina 5-11-2015
--	AND For_Date IN ( SELECT MAX(For_Date) FROM T0040_General_setting  g
--					  --INNER JOIN  T0050_General_Detail d on g.gen_Id = d.gen_ID		--Commented By Ramiz , as it is not Required ( 20/10/2018)
--					  WHERE g.Cmp_Id = @cmp_Id AND For_Date <= @To_Date 
--					  AND EXISTS (select Data from dbo.Split(ISNULL(@Branch_ID,branch_ID), '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))  --Added By Jaina 5-11-2015
--					) 
SET @PF_541 = 0
SET @PF_NOT_FUll_AMT = 0
SET @PF_541 = round(@PF_Limit * 0.0833, 0)
SET @PF_NOT_FUll_AMT = round(@PF_Limit * 12 / 100, 0)

UPDATE #EMP_SALARY
SET PF_833 = round(PF_SALARY_AMOUNT * 0.0833, 0)
	,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833, 0)
WHERE PF_SALARY_AMOUNT <= PF_Limit

UPDATE #EMP_SALARY
SET Arrear_Wages_833 = CASE 
		WHEN isnull(Arear_M_AD_Calculated_Amount, 0) + Arrear_Wages <= PF_Limit
			THEN Arrear_Wages
		WHEN PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount, 0)
			THEN PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount, 0)
		ELSE 0
		END
	,Arrear_PF_833 = round((
			CASE 
				WHEN isnull(Arear_M_AD_Calculated_Amount, 0) + Arrear_Wages <= PF_Limit
					THEN Arrear_Wages
				WHEN PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount, 0)
					THEN PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount, 0)
				ELSE 0
				END
			) * 0.0833, 0)
WHERE Is_Sett <> 2

UPDATE #EMP_SALARY
SET Arrear_PF_367 = Arrear_PF_Amount - Arrear_PF_833

--Case When Round(PF_Limit*0.0833,0) <= round(PF_SALARY_AMOUNT * 0.0833,0) + round(Arrear_Wages * 0.0833,0) Then
--	Arrear_PF_Amount - Arrear_PF_833
--Else
--	round(Arrear_Wages * 0.0367,0)
--End
--where isnull(Arear_M_AD_Calculated_Amount,0) + Arrear_Wages  <= PF_Limit
--- When give Version to AIA, Comment below porting, Hardik 22/05/2018
--Update #EMP_SALARY
--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
--	,PF_833 = @PF_541
--	,PF_367 = PF_Amount - @PF_541
--	,Arrear_PF_833 = ROUND(Arrear_PF_833,0) --0
--	,Arrear_PF_367 = CASE WHEN Arrear_PF_833 <> 0 THEN ROUND(Arrear_PF_367,0) ELSE Arrear_PF_Amount END 
--	--,Arrear_PF_367 =Arrear_PF_Amount 
--where PF_SALARY_AMOUNT > PF_Limit
-- Deepal 10102022 
UPDATE #EMP_SALARY
SET PF_Diff_6500 = CASE 
		WHEN PF_SALARY_AMOUNT > PF_Limit
			THEN PF_SALARY_AMOUNT - PF_Limit
		ELSE 0
		END -- Deepal add case when condition 10102022
	--set PF_Diff_6500 =  PF_SALARY_AMOUNT - PF_Limit -- Deepal add case when condition 10102022
	,PF_833 = CASE 
		WHEN Pension_Not_Applicable = 1
			THEN 0
		ELSE @PF_541
		END --@PF_541
	,PF_367 = CASE 
		WHEN Pension_Not_Applicable = 1
			THEN PF_Amount
		ELSE PF_Amount - @PF_541
		END
	,Arrear_PF_833 = ROUND(Arrear_PF_833, 0) --0
	,Arrear_PF_367 = CASE 
		WHEN Arrear_PF_833 <> 0
			THEN ROUND(Arrear_PF_367, 0)
		ELSE Arrear_PF_Amount
		END
--,Arrear_PF_367 =Arrear_PF_Amount 
WHERE Pension_Not_Applicable = 1 -- PF_SALARY_AMOUNT > PF_Limit -- Deepal add case when condition 10102022

--Update #EMP_SALARY
--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
--	,PF_833 = case when Pension_Not_Applicable = 1 then 0 else @PF_541 end  --@PF_541
--	,PF_367 = case when Pension_Not_Applicable = 1 then PF_Amount else  PF_Amount - @PF_541 end
--	,Arrear_PF_833 = ROUND(Arrear_PF_833,0) --0
--	,Arrear_PF_367 = CASE WHEN Arrear_PF_833 <> 0 THEN ROUND(Arrear_PF_367,0) ELSE Arrear_PF_Amount END 
--	--,Arrear_PF_367 =Arrear_PF_Amount 
--where PF_SALARY_AMOUNT > PF_Limit
UPDATE #EMP_SALARY
--set PF_Diff_6500 = case when  PF_SALARY_AMOUNT  > PF_Limit then PF_SALARY_AMOUNT - PF_Limit else 0 END -- Deepal add case when condition 10102022
SET PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit -- Deepal add case when condition 10102022
	,PF_833 = CASE 
		WHEN Pension_Not_Applicable = 1
			THEN 0
		ELSE @PF_541
		END --@PF_541
	,PF_367 = CASE 
		WHEN Pension_Not_Applicable = 1
			THEN PF_Amount
		ELSE PF_Amount - @PF_541
		END
	,Arrear_PF_833 = ROUND(Arrear_PF_833, 0) --0
	,Arrear_PF_367 = CASE 
		WHEN Arrear_PF_833 <> 0
			THEN ROUND(Arrear_PF_367, 0)
		ELSE Arrear_PF_Amount
		END
--,Arrear_PF_367 =Arrear_PF_Amount 
WHERE Pension_Not_Applicable = 0
	AND PF_SALARY_AMOUNT > PF_Limit -- Deepal add case when condition 10102022

--- When give Version to AIA, Uncomment below porting and Comment Above Portion, Hardik 22/05/2018
/*
		Update #EMP_SALARY
		SET PF_Diff_6500 = PF_SALARY_AMOUNT  + Arrear_Wages - PF_Limit
			,PF_833 = @PF_541
			,PF_367 = PF_Amount - @PF_541
			,Arrear_PF_833 = 0
			,Arrear_PF_367 = Arrear_PF_Amount
		where PF_SALARY_AMOUNT + Arrear_Wages > PF_Limit
		*/
UPDATE #EMP_SALARY
SET PF_833 = 0
	,PF_367 = PF_Amount
	,PF_LIMIT = 0
	,Arrear_PF_833 = 0
	,Arrear_PF_367 = Arrear_PF_Amount
WHERE Emp_Age >= @PF_PEnsion_Age
	AND @PF_PEnsion_Age > 0

UPDATE #EMP_SALARY
SET PF_LIMIT = PF_SALARY_AMOUNT
WHERE PF_SALARY_AMOUNT < @PF_LIMIT

UPDATE #EMP_SALARY
SET PF_833 = 0
	,PF_LIMIT = 0
--,Arrear_PF_833 = 0    Added By Jimit 08032018 as case at WCl Arrear amount is set to 0 when regular PF amount is 0
WHERE PF_833 = 0

UPDATE #EMP_SALARY
SET EDLI_Wages = PF_SALARY_AMOUNT

UPDATE #EMP_SALARY
SET EDLI_Wages = @PF_LIMIT
WHERE PF_SALARY_AMOUNT > @PF_LIMIT

-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013
--Update #EMP_SALARY
--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
--	,PF_833 = @PF_541
--	,PF_367 = round(PF_Limit * 12/100,0) - @PF_541
--where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0
--Update #EMP_SALARY    
--set PF_833 = 0    
--	,PF_367 = PF_AMOUNT--@PF_NOT_FUll_AMT	---Set Actual PF Amount (Employee arear case)--Ankit 10082015 
--	,PF_LIMIT =0   
--where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 and PF_Amount > @PF_NOT_FUll_AMT and cmp_full_pf = 0 
UPDATE #EMP_SALARY --PF 8.33 and 3.67 Calculate On actual PF Amount deduct ----Condition Add By Ankit After discuss with Hardikbhai 10082015
SET PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
	,PF_833 = round((PF_LIMIT * 8.33) / 100, 0)
	,PF_367 = PF_Amount - round((PF_LIMIT * 8.33) / 100, 0)
WHERE PF_SALARY_AMOUNT > PF_Limit
	AND cmp_full_pf = 0
	AND PF_Limit > 0

UPDATE #EMP_SALARY
SET PF_833 = 0
	,PF_367 = PF_AMOUNT -- round(PF_LIMIT * 12/100,0) --@PF_NOT_FUll_AMT  ---Set Actual PF Amount (Employee arear case)--Ankit 10082015
	,PF_LIMIT = 0
WHERE Emp_Age >= @PF_PEnsion_Age
	AND @PF_PEnsion_Age > 0
	AND PF_Amount > @PF_NOT_FUll_AMT
	AND cmp_full_pf = 0

-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013
--Added by Hardik for Foreign Employee who pay full PF on 17/05/2012
UPDATE #EMP_SALARY
SET PF_833 = round(PF_SALARY_AMOUNT * 0.0833, 0)
	,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833, 0)
	,PF_DIFF_6500 = 0
	,PF_LIMIT = 0
WHERE Nationality NOT LIKE 'India%'
	AND Nationality <> ''
	AND Nationality NOT LIKE 'BHARAT%' ---added By Deepali on 21nov2021

--Update #EMP_SALARY 
--set PF_Amount = PF_Amount + ISNULL(VPF,0)
UPDATE #EMP_SALARY
SET Arrear_Wages = 0
WHERE Isnull(Arrear_PF_Amount, 0) = 0

-- Added by rohit on 14042016 for Pf trust Employee pf amount and other then pension fund transfer to pf trust account.	
UPDATE #EMP_SALARY
SET PF_AMOUNT = 0
	,PF_367 = 0
FROM #EMP_SALARY ES
INNER JOIN T0080_EMP_MASTER Em ON Es.EMP_ID = Em.Emp_ID
WHERE isnull(is_PF_Trust, 0) = 1

-- Ended by rohit on 14042016 for Pf trust Employee pf amount and other then pension fund transfer to pf trust account.
--HNB
IF @Format IN (
		2
		,3
		)
	UPDATE #EMP_SALARY
	SET --PF_SALARY_AMOUNT = PF_SALARY_AMOUNT + Arrear_Wages,
		Arrear_Wages = 0
		,PF_AMOUNT = PF_AMOUNT + Arrear_PF_Amount
		,Arrear_PF_Amount = 0
		,
		--PF_833 = PF_833 + Arrear_PF_833,
		Arrear_PF_833 = 0
		,PF_367 = (PF_AMOUNT + Arrear_PF_Amount) - PF_833
		,Arrear_PF_367 = 0 --,
		--PF_LIMIT = PF_LIMIT + Arrear_Wages_833,
		--Arrear_Wages_833 = 0
	WHERE Arrear_PF_Amount < 0

--Added By Ramiz on 20/10/2018--( As discussed By Hardik bhai , Admin Charge for PF and Arrear PF will be Same , so taking in single Variable )
UPDATE #EMP_SALARY
SET PF_Admin_Charge_Empwise = ROUND(((PF_SALARY_AMOUNT * @Admin_Charge_Empwise) / 100), 2)
	,Edli_Charge_EmpWise = ROUND(((EDLI_Wages * @Edli_charge) / 100), 2)
	,Arrear_PF_Admin_Charge_Empwise = ROUND(((Arrear_Wages * @Admin_Charge_Empwise) / 100), 2)
	,Arrear_Edli_Charge_EmpWise = ROUND(((Arrear_Wages_833 * @Edli_charge) / 100), 2)

/*************************************************************************
							FORMATS STARTS FROM 3 FOR PDF AND 0,1 & 2 ARE FOR EXCEL
							MAX FORMAT USED :- 10
		*************************************************************************/
--	-- Deepal 14122021 PF And Pension setting 
--update #EMP_SALARY 
--set pf_833 = case when PFsettID = 1 then 0 else pf_833 end ,
--PF_367 = case when PFsettID = 1 then PF_367 + pf_833 else PF_367 end 
----ENd Deepal 14122021 PF And Pension setting 
---Hardik 10/01/2017		
IF @Format = 3
BEGIN
	DELETE #EMP_PF_REPORT
	FROM #EMP_PF_REPORT EPR
	INNER JOIN #EMP_SALARY ES ON EPR.EMP_ID = ES.EMP_ID
	WHERE Isnull(ES.Arrear_PF_Amount, 0) = 0

	DELETE #EMP_SALARY
	WHERE Isnull(Arrear_PF_Amount, 0) = 0
END

--ELSE 
IF @Format = 4 ---For PF Statement Consolidated
BEGIN
	PRINT 111 --ronak

	SELECT EPF.*
		,(PF_AMOUNT) + Isnull(Arrear_PF_Amount, 0) AS PF_AMOUNT
		,PF_PER
		,PF_Limit AS PF_Limit --+ Isnull(Es.Arrear_Wages_833,0) as PF_Limit   --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		,EDLI_Wages AS EDLI_Wages
		,--+ Isnull(es.Arrear_Wages_833,0) as EDLI_Wages, --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		PF_SALARY_AMOUNT AS PF_SALARY_AMOUNT
		,--+ Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT,  --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		PF_833 AS PF_833 --+ Isnull(Arrear_PF_833,0) as PF_833
		--,PF_367 + Isnull(Arrear_PF_367,0) as PF_367
		,(PF_AMOUNT) + Isnull(Arrear_PF_Amount, 0) - ISNULL(PF_833, 0) AS PF_367
		--,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,
		,PF_Diff_6500
		,EMP_SECOND_NAME
		,ES.VPF + Isnull(ES.Arrear_VPF_Amount, 0) AS VPF
		,E.Basic_Salary
		,E.Emp_code
		,--Hardik 26/12/2017
		UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
					WHEN isnull(Emp_Second_Name, '') <> ''
						THEN + ' ' + Emp_Second_Name
					END + CASE 
					WHEN isnull(Emp_Last_Name, '') <> ''
						THEN + ' ' + Emp_Last_Name
					END)) AS Emp_Full_Name
		,Grd_Name
		,Type_Name
		,dept_Name
		,Desig_Name
		,Cmp_Name
		,Cmp_Address
		,cm.PF_No AS CPF_NO
		,@From_Date P_From_Date
		,@To_Date P_To_Date
		,Father_Name
		,Le.Left_Date
		,Le.Left_Reason
		,CAST((
				CASE 
					WHEN (@IS_NCP_PRORATA = 1)
						THEN
							--[dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)
							Ms.Absent_Days
					ELSE Ms.Absent_Days
					END
				) AS NUMERIC(18, 2)) AS Absent_Days
		,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)
		,ES.arrear_days
		,ES.VPF_PER
		,BM.Branch_Name
		,date_of_join
		,E.Alpha_Emp_Code
		,E.Emp_First_Name --added jimit 25052015
		,dgm.Desig_Dis_No --added jimit 25092015
		,(EDLI_Wages + Isnull(es.Arrear_Wages_833, 0)) * @Edli_charge / 100 AS EDLI
		,vs.Vertical_Name
		,sv.SubVertical_name
		,Isnull(E.UAN_No, '') AS UAN_No
		,'' AS Format_Type
		,ES.Gross_Salary AS Gross_Salary --added jimit 02072016
		,BM.Branch_Address -- Added By Sajid 21122021
	FROM #EMP_PF_REPORT EPF
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
	LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
	LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
		AND EPF.MONTH = ES.MONTH
		AND EPF.YEAR = ES.YEAR
	LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
		AND ES.MONTH = month(MS.Month_St_Date)
		AND ES.YEAR = year(MS.Month_St_Date)
	INNER JOIN (
		SELECT I.Branch_ID
			,I.Grd_ID
			,I.Dept_ID
			,I.Desig_ID
			,I.Emp_ID
			,Type_ID
			,Wages_Type
			,I.Vertical_ID
			,I.SubVertical_ID
		FROM T0095_Increment I WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) Q_I ON E.EMP_ID = Q_I.EMP_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
	LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
	INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
	LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
	LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
	INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
	--where Pf_Amount	 <> 0 --Added By Jimit 25052018
	ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
END
		--Added By Mukti(start)16022017
ELSE IF @Format = 7 ---For PF Statement Regular Salary
BEGIN
	SELECT EPF.*
		--,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) as PF_AMOUNT	
		--PF_Limit + Isnull(Es.Arrear_Wages_833,0) as PF_Limit,EDLI_Wages + Isnull(es.Arrear_Wages_833,0) as EDLI_Wages, 
		--PF_SALARY_AMOUNT + Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT
		--,PF_833 + Isnull(Arrear_PF_833,0) as PF_833
		--,PF_367 + Isnull(Arrear_PF_367,0) as PF_367
		,(PF_AMOUNT) AS PF_AMOUNT
		,PF_PER
		,PF_Limit AS PF_Limit
		,EDLI_Wages AS EDLI_Wages
		,PF_SALARY_AMOUNT AS PF_SALARY_AMOUNT
		,PF_833 AS PF_833
		,PF_367 AS PF_367
		,PF_Diff_6500
		,EMP_SECOND_NAME
		,ES.VPF
		,E.Basic_Salary
		,E.Emp_code
		,UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
					WHEN isnull(Emp_Second_Name, '') <> ''
						THEN + ' ' + Emp_Second_Name
					END + CASE 
					WHEN isnull(Emp_Last_Name, '') <> ''
						THEN + ' ' + Emp_Last_Name
					END)) AS Emp_Full_Name
		,Grd_Name
		,Type_Name
		,dept_Name
		,Desig_Name
		,Cmp_Name
		,Cmp_Address
		,cm.PF_No AS CPF_NO
		,@From_Date P_From_Date
		,@To_Date P_To_Date
		,Father_Name
		,Le.Left_Date
		,Le.Left_Reason
		,CAST((
				CASE 
					WHEN (@IS_NCP_PRORATA = 1)
						THEN [dbo].[F_Get_NCP_Days](/*@From_Date,@To_Date*/ MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days)
					ELSE Ms.Absent_Days
					END
				) AS NUMERIC(18, 2)) AS Absent_Days
		,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)
		,ES.arrear_days
		,ES.VPF_PER
		,BM.Branch_Name
		,date_of_join
		,E.Alpha_Emp_Code
		,E.Emp_First_Name --added jimit 25052015
		,dgm.Desig_Dis_No --added jimit 25092015
		--,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI
		,(EDLI_Wages + Isnull(es.Arrear_Wages_833, 0)) * @Edli_charge / 100 AS EDLI
		,vs.Vertical_Name
		,sv.SubVertical_name
		,Isnull(E.UAN_No, '') AS UAN_No
		,'Regular Salary' AS Format_Type
		,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross, 0) + ISNULL(Ms.Settelement_Amount, 0))) AS Gross_Salary
	--0 as Gross_Salary--added jimit 02072016
	FROM #EMP_PF_REPORT EPF
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
	LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
	LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
		AND EPF.MONTH = ES.MONTH
		AND EPF.YEAR = ES.YEAR
	LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
		AND ES.MONTH = month(MS.Month_St_Date)
		AND ES.YEAR = year(MS.Month_St_Date)
	INNER JOIN (
		SELECT I.Branch_ID
			,I.Grd_ID
			,I.Dept_ID
			,I.Desig_ID
			,I.Emp_ID
			,Type_ID
			,Wages_Type
			,I.Vertical_ID
			,I.SubVertical_ID
		FROM T0095_Increment I WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) Q_I ON E.EMP_ID = Q_I.EMP_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
	LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
	INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
	LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
	LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
	INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
	ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
END
ELSE IF @Format = 8 ---For PF Statement Arrear Salary
BEGIN
	--print 456--mansi
	SELECT EPF.*
		,Isnull(Arrear_PF_Amount, 0) AS PF_AMOUNT
		,PF_PER
		,(
			CASE 
				WHEN Emp_Age >= @PF_PEnsion_Age
					AND @PF_PEnsion_Age > 0
					THEN 0
				ELSE (
						CASE 
							WHEN Pension_Not_Applicable = 1
								THEN 0
							ELSE Isnull(Es.Arrear_Wages_833, 0)
							END
						)
				END
			) AS PF_Limit --Change by ronakk 14072023
		,Isnull(es.Arrear_Wages_833, 0) AS EDLI_Wages
		,Isnull(ES.Arrear_Wages, 0) AS PF_SALARY_AMOUNT
		,(
			CASE 
				WHEN Pension_Not_Applicable = 1
					THEN 0
				ELSE Isnull(Arrear_PF_833, 0)
				END
			) AS PF_833 --Change by ronakk 14072023
		,(
			CASE 
				WHEN Pension_Not_Applicable = 1
					THEN Isnull(Arrear_PF_367, 0) + Isnull(Arrear_PF_833, 0)
				ELSE Isnull(Arrear_PF_367, 0)
				END
			) AS PF_367 --Change by ronakk 14072023
		,PF_Diff_6500
		,EMP_SECOND_NAME
		,Isnull(ES.Arrear_VPF_Amount, 0) AS VPF
		,E.Basic_Salary
		,E.Emp_code
		,--Hardik 26/12/2017
		UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
					WHEN isnull(Emp_Second_Name, '') <> ''
						THEN + ' ' + Emp_Second_Name
					END + CASE 
					WHEN isnull(Emp_Last_Name, '') <> ''
						THEN + ' ' + Emp_Last_Name
					END)) AS Emp_Full_Name
		,Grd_Name
		,Type_Name
		,dept_Name
		,Desig_Name
		,Cmp_Name
		,Cmp_Address
		,cm.PF_No AS CPF_NO
		,@From_Date P_From_Date
		,@To_Date P_To_Date
		,Father_Name
		,Le.Left_Date
		,Le.Left_Reason
		,CAST((
				CASE 
					WHEN (@IS_NCP_PRORATA = 1)
						THEN [dbo].[F_Get_NCP_Days](/*@From_Date,@To_Date*/ MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days)
					ELSE Ms.Absent_Days
					END
				) AS NUMERIC(18, 2)) AS Absent_Days
		,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)
		,ES.arrear_days
		,ES.VPF_PER
		,BM.Branch_Name
		,date_of_join
		,E.Alpha_Emp_Code
		,E.Emp_First_Name --added jimit 25052015
		,dgm.Desig_Dis_No --added jimit 25092015
		,(EDLI_Wages + Isnull(es.Arrear_Wages_833, 0)) * @Edli_charge / 100 AS EDLI
		,vs.Vertical_Name
		,sv.SubVertical_name
		,Isnull(E.UAN_No, '') AS UAN_No
		,'Arrear Salary' AS Format_Type
		--,ES.Gross_Salary --added jimit 02072016
		,(
			SELECT sum(S_Gross_Salary)
			FROM T0201_MONTHLY_SALARY_SETT
			WHERE Emp_ID = EPF.EMP_ID
				AND S_Eff_Date = MS.Month_St_Date
			) AS Gross_Salary --Change by ronakk 14072023
	FROM #EMP_PF_REPORT EPF
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
	LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
	LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
		AND EPF.MONTH = ES.MONTH
		AND EPF.YEAR = ES.YEAR
	LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
		AND ES.MONTH = month(MS.Month_St_Date)
		AND ES.YEAR = year(MS.Month_St_Date)
	INNER JOIN (
		SELECT I.Branch_ID
			,I.Grd_ID
			,I.Dept_ID
			,I.Desig_ID
			,I.Emp_ID
			,Type_ID
			,Wages_Type
			,I.Vertical_ID
			,I.SubVertical_ID
		FROM T0095_Increment I WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) Q_I ON E.EMP_ID = Q_I.EMP_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
	LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
	INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
	LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
	LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
	INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
	WHERE Isnull(ES.Arrear_PF_Amount, 0) <> 0 --Mukti(16022017)
	ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
END
		--Added By Mukti(end)16022017
ELSE IF @Format = 5 ---For PF Challan
BEGIN
	--------------------------------------------- PF CHALLAN CALCULATION 
	--declare @EMP_SALARY_Challan table --commented By Mukti(17022017)start   
	-- (    
	--  Cmp_ID     numeric,    
	--  Total_Subscriber   numeric ,    
	--  Total_Wages_Due    numeric(18,2),    
	--  Total_PF_Diff_Limit   numeric(18,2),    
	--  AC1_1      numeric(18,2) default 0,    
	--  AC1_2      numeric(18,2) default 0,    
	--  AC2_3      numeric(18,2) default 0,    
	--  AC10_1      numeric(18,2) default 0,    
	--  AC21_1      numeric(18,2) default 0,    
	--  AC22_3      numeric(18,2) default 0,    
	--  AC22_4      numeric(18,2) default 0,    
	--  For_Date     datetime,
	--  Payment_Date datetime,    
	--  PF_Limit     numeric,    
	--  Total_Family_Pension_Subscriber  numeric(18, 0),    
	--  Total_Family_Pension_Wages_Amount numeric(18, 0),    
	--  Total_EDLI_Subscriber    numeric(18, 0),    
	--  Total_EDLI_Wages_Amount    numeric(18, 0)  ,
	--  VPF  numeric(18,0)  
	-- )    
	-- declare @Total_Wages_Due as numeric(18,2)    
	-- declare @Total_Subscriber as numeric    
	-- Declare @Total_PF_Diff_Limit as numeric    
	-- Declare @dblAC1_1 as numeric(22,2)    
	-- Declare @dblAC1_2 as numeric(22,2)    
	-- Declare @dblAC2_3 as numeric(22,2)    
	-- Declare @dblAC10_1 as numeric(22,2)    
	-- Declare @dblAC21_1 as numeric(22,2)    
	-- Declare @dblAC22_3 as numeric(22,2)    
	-- Declare @dblAC22_4 numeric     
	-- Declare @dbl833 as numeric (22,2)    
	-- Declare @dbl367 as numeric (22,2)    
	-- declare @Total_PF_Amount as numeric     
	-- DEclare @MONTH numeric      
	-- Declare @Year numeric     
	-- Declare @Total_Family_Pension_Subscriber  numeric(18, 0)    
	-- Declare @Total_Family_Pension_Wages_Amount  numeric(18, 0)    
	-- Declare @Total_EDLI_Subscriber     numeric(18, 0)    
	-- Declare @Total_EDLI_Wages_Amount    numeric(18, 0)  
	-- Declare @VPF as numeric(18,0) 
	-- Declare @AC_2_3 numeric(10,2)
	-- Declare @AC_21_1 numeric(10,2)    
	-- Declare @AC_22_3 numeric(10,4)    
	-- Declare @AC_22_4 numeric(10,4)--commented By Mukti(17022017)end
	SELECT @Total_NonPF_Subcriber = count(MS.Emp_ID)
		,@Total_NonPF_Wages = Sum(isnull(ms.Gross_Salary, 0))
	FROM #EMP_CONS EC
	INNER JOIN T0200_MONTHLY_SALARY MS ON Ec.Emp_ID = MS.Emp_id
	INNER JOIN T0210_MONTHLY_AD_DETAIL MD ON ms.Sal_Tran_ID = MD.Sal_Tran_ID
		AND ms.Emp_ID = md.Emp_ID
		AND Month_St_Date = @FROM_DATE
		AND Month_End_Date = @To_Date
		AND AD_ID IN (68)
		AND md.M_AD_Amount = 0

	SELECT TOP 1 @AC_2_3 = ACC_2_3
		,@AC_22_3 = ACC_22_3
		,@PF_Limit = ACC_10_1_Max_Limit
		,@AC_21_1 = ACC_21_1
		,@PF_Pension_Age = isnull(PF_Pension_Age, 0)
	FROM T0040_General_setting gs WITH (NOLOCK)
	INNER JOIN T0050_General_Detail gd WITH (NOLOCK) ON gs.gen_Id = gd.gen_ID
	WHERE gs.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		AND Branch_ID IN (
			SELECT CAST(DATA AS NUMERIC)
			FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
			)
		AND For_Date IN (
			SELECT max(For_Date)
			FROM T0040_General_setting g WITH (NOLOCK)
			INNER JOIN T0050_General_Detail d WITH (NOLOCK) ON g.gen_Id = d.gen_ID
			WHERE g.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
				AND Branch_ID IN (
					SELECT CAST(DATA AS NUMERIC)
					FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
					)
				AND For_Date <= @To_Date
			)

	UPDATE E
	SET E.PF_SALARY_AMOUNT = E.PF_SALARY_AMOUNT --+ case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end 
		,E.PF_LIMIT = CASE 
			WHEN E.PF_LIMIT + Isnull(E.Arrear_Wages_833, 0) < @PF_LIMIT
				THEN E.PF_LIMIT + Isnull(E.Arrear_Wages_833, 0)
			ELSE @PF_LIMIT
			END
		,E.EDLI_Wages = CASE 
			WHEN E.EDLI_Wages + Isnull(E.Arrear_Wages_833, 0) < @PF_LIMIT
				THEN E.EDLI_Wages + Isnull(E.Arrear_Wages_833, 0)
			ELSE @PF_LIMIT
			END
	--E.Arrear_Wages = E.Arrear_Wages + case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end,
	--E.Arrear_Wages_833 = E.Arrear_Wages_833 + case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end
	FROM #EMP_SALary E
	LEFT OUTER JOIN (
		SELECT MAD1.EMP_ID
			,ISNULL(SUM(M_AREAR_AMOUNT), 0) M_AREAR_AMOUNT1
			,MONTH(MAD1.To_DATE) AS monthArrear
			,Year(MAD1.To_DATE) AS YearArrear
		FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID
		INNER JOIN #EMP_CONS Qry1 ON MAD1.Emp_ID = Qry1.Emp_ID
		WHERE MONTH(MAD1.To_DATE) = MONTH(@TO_DATE)
			AND YEAR(MAD1.To_DATE) = YEAR(@To_Date)
			AND ad_not_effect_salary = 0
			AND AD_FLAG = 'I'
			AND M_AREAR_AMOUNT <> 0
			AND AM.ad_id IN (
				SELECT EAM.AD_ID
				FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EAM.Effect_AD_ID = AM.AD_ID
					AND EAM.CMP_ID = AM.CMP_ID
				WHERE AM.AD_DEF_ID = @PF_DEF_ID
					AND Am.Cmp_ID = @Cmp_ID
				)
		GROUP BY MAD1.Emp_ID
			,Mad1.To_date
		) Q ON Q.EMP_Id = E.EMP_ID
	INNER JOIN T0200_MONTHLY_SALARY SG WITH (NOLOCK) ON Sg.Emp_ID = Q.Emp_ID
		AND month(Sg.Month_End_Date) = monthArrear
		AND YEAR(Sg.Month_End_Date) = YearArrear

	SET @TEMP_DATE = @FROM_DATE

	WHILE @TEMP_DATE <= @TO_DATE
	BEGIN
		SET @Total_Subscriber = 0
		SET @Total_Wages_Due = 0
		SET @Total_PF_Diff_Limit = 0
		SET @Total_PF_Amount = 0
		SET @dblAC1_1 = 0
		SET @dblAC1_2 = 0
		SET @dblAC2_3 = 0
		SET @dblAC10_1 = 0
		SET @dblAC21_1 = 0
		SET @dblAC22_3 = 0
		SET @dbl833 = 0
		SET @dbl367 = 0
		SET @dblAC22_4 = 0
		SET @MONTH = MONTH(@TEMP_DATE)
		SET @YEAR = YEAR(@TEMP_DATE)
		SET @Total_Family_Pension_Subscriber = 0
		SET @Total_Family_Pension_Wages_Amount = 0
		SET @Total_EDLI_Subscriber = 0
		SET @Total_EDLI_Wages_Amount = 0

		SELECT @Total_Subscriber = count(1)
			,@Total_Wages_Due = isnull(sum(PF_Salary_Amount), 0) -- + isnull(sum(Arrear_Wages ),0)    
			,@Total_PF_Amount = isnull(sum(PF_Amount), 0) + isnull(sum(Arrear_PF_Amount), 0)
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year

		SELECT @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500), 0)
			,@dbl833 = round(sum(PF_833), 0)
			,--+ sum(Isnull(Arrear_PF_833,0)), 
			--@dbl367 = round(sum(PF_367),0 )+ sum(Isnull(Arrear_PF_367,0)),
			@dbl367 = round(sum(PF_AMOUNT), 0) + sum(Isnull(Arrear_PF_Amount, 0)) - sum(ISNULL(PF_833, 0))
			,@VPF = ISNULL(Sum(VPF), 0) + Isnull(Sum(Arrear_VPF_Amount), 0) --Added By jimit 05012018
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year
			AND (
				PF_Amount > 0
				OR Arrear_PF_Amount > 0
				) --change By Jimit 09032018

		SELECT @Total_Family_Pension_Subscriber = count(emp_ID)
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0

		--select PF_833,* from #EMP_SALARY where EMP_ID = 1741
		--Ankit 09052016
		SELECT @Total_Family_Pension_Wages_Amount = sum(PF_LIMIT) --+  Isnull(sum(Arrear_Wages_833),0) 
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0 -- and Arear_Month_Salary_exists = 0

		SELECT @Total_EDLI_Wages_Amount = sum(EDLI_Wages) --+  Isnull(sum(Arrear_Wages_833),0)
		FROM #EMP_SALARY

		-- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0
		--Ankit 09052016
		SET @Total_EDLI_Subscriber = @Total_Subscriber
		--set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit 
		SET @dbl833 = isnull(@dbl833, 0)
		SET @Total_Wages_Due = @Total_Wages_Due
		SET @Total_PF_Amount = @Total_PF_Amount
		SET @dblAC1_1 = @dbl367
		SET @dblAC10_1 = @dbl833
		SET @dblAC1_2 = @Total_PF_Amount + @VPF
		SET @dblAC2_3 = round(@Total_Wages_Due * @AC_2_3 / 100, 0)
		SET @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1 / 100, 0)

		--select @AC_22_3
		--if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
		--set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)    
		--else    
		--set @dblAC22_3 = 2    
		--set @dblAC22_4 =  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0)    
		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500
		IF @dblAC2_3 < 500
			SET @dblAC2_3 = 500

		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 2 to 200
		--if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
		IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_3 = Round((@AC_22_3 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 0
				SET @dblAC22_3 = 200
		END

		IF (@AC_22_4 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_4 = Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0) > 0
				SET @dblAC22_4 = 200
		END

		-- DEclare @Payment_Date Datetime 
		--Added By Falak on 19-MAY-2011
		SELECT @Payment_Date = Payment_Date
		FROM T0220_PF_CHALLAN WITH (NOLOCK)
		WHERE [Month] = Month(@TEMP_DATE)
			AND [YEAR] = YEAR(@Temp_Date)

		IF @Total_Subscriber > 0
		BEGIN
			INSERT INTO @EMP_SALARY_Challan (
				Cmp_ID
				,Total_NonPF_Subscriber
				,Total_NonPF_Wages
				,Total_Subscriber
				,Total_Wages_Due
				,Total_PF_Diff_Limit
				,AC1_1
				,AC1_2
				,AC2_3
				,AC10_1
				,AC21_1
				,AC22_3
				,For_Date
				,Payment_Date
				,PF_Limit
				,AC22_4
				,Total_Family_Pension_Subscriber
				,Total_Family_Pension_Wages_Amount
				,Total_EDLI_Subscriber
				,Total_EDLI_Wages_Amount
				,VPF
				)
			VALUES (
				@Cmp_ID
				,@Total_NonPF_Subcriber
				,@Total_NonPF_Wages
				,@Total_Subscriber
				,@Total_Wages_Due
				,@Total_PF_Diff_Limit
				,isnull(@dblAC1_1, 0)
				,@dblAC1_2
				,@dblAC2_3
				,@dblAC10_1
				,@dblAC21_1
				,@dblAC22_3
				,@Temp_DAte
				,@Payment_Date
				,@PF_Limit
				,@dblAC22_4
				,@Total_Family_Pension_Subscriber
				,@Total_Family_Pension_Wages_Amount
				,@Total_EDLI_Subscriber
				,@Total_EDLI_Wages_Amount
				,@VPF
				)
		END

		SET @TEMP_DATE = DATEADD(M, 1, @TEMP_DATE)
	END

	-- print 'm'
	SELECT *
	FROM @EMP_SALARY_Challan ES
	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ES.Cmp_ID = CM.Cmp_Id
END
ELSE IF @Format = 9 ---For PF Challan(Regular Salary)
BEGIN
	--------------------------------------------- PF CHALLAN CALCULATION 
	SELECT TOP 1 @AC_2_3 = ACC_2_3
		,@AC_22_3 = ACC_22_3
		,@PF_Limit = ACC_10_1_Max_Limit
		,@AC_21_1 = ACC_21_1
		,@PF_Pension_Age = isnull(PF_Pension_Age, 0)
	FROM T0040_General_setting gs WITH (NOLOCK)
	INNER JOIN T0050_General_Detail gd WITH (NOLOCK) ON gs.gen_Id = gd.gen_ID
	WHERE gs.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		AND Branch_ID IN (
			SELECT CAST(DATA AS NUMERIC)
			FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
			)
		AND For_Date IN (
			SELECT max(For_Date)
			FROM T0040_General_setting g WITH (NOLOCK)
			INNER JOIN T0050_General_Detail d WITH (NOLOCK) ON g.gen_Id = d.gen_ID
			WHERE g.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
				AND Branch_ID IN (
					SELECT CAST(DATA AS NUMERIC)
					FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
					)
				AND For_Date <= @To_Date
			)

	SET @TEMP_DATE = @FROM_DATE

	WHILE @TEMP_DATE <= @TO_DATE
	BEGIN
		SET @Total_Subscriber = 0
		SET @Total_Wages_Due = 0
		SET @Total_PF_Diff_Limit = 0
		SET @Total_PF_Amount = 0
		SET @dblAC1_1 = 0
		SET @dblAC1_2 = 0
		SET @dblAC2_3 = 0
		SET @dblAC10_1 = 0
		SET @dblAC21_1 = 0
		SET @dblAC22_3 = 0
		SET @dbl833 = 0
		SET @dbl367 = 0
		SET @dblAC22_4 = 0
		SET @MONTH = MONTH(@TEMP_DATE)
		SET @YEAR = YEAR(@TEMP_DATE)
		SET @Total_Family_Pension_Subscriber = 0
		SET @Total_Family_Pension_Wages_Amount = 0
		SET @Total_EDLI_Subscriber = 0
		SET @Total_EDLI_Wages_Amount = 0

		SELECT @Total_Subscriber = count(*)
			,@Total_Wages_Due = isnull(sum(PF_Salary_Amount), 0)
			,@Total_PF_Amount = isnull(sum(PF_Amount), 0)
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year

		SELECT @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500), 0)
			,@dbl833 = round(sum(PF_833), 0)
			,@dbl367 = round(sum(PF_367), 0)
			,@VPF = ISNULL(Sum(VPF), 0)
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year
			AND PF_Amount > 0

		SELECT @Total_Family_Pension_Subscriber = count(emp_ID)
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0

		--Ankit 09052016
		SELECT --@Total_Family_Pension_Wages_Amount =  sum(PF_LIMIT)+ + Isnull(sum(Arrear_Wages_833),0) 
			@Total_Family_Pension_Wages_Amount = sum(PF_LIMIT)
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0 --  and Arear_Month_Salary_exists = 0

		SELECT --@Total_EDLI_Wages_Amount = sum(EDLI_Wages)+ + Isnull(sum(Arrear_Wages_833),0)
			@Total_EDLI_Wages_Amount = sum(EDLI_Wages)
		FROM #EMP_SALARY

		-- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0
		--Ankit 09052016			    
		--   print @AC_21_1
		--   print @Total_EDLI_Wages_Amount	
		--print @Total_PF_Amount				    			    
		--print @VPF
		SET @Total_EDLI_Subscriber = @Total_Subscriber
		--set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit 
		SET @dbl833 = isnull(@dbl833, 0)
		SET @Total_Wages_Due = @Total_Wages_Due
		SET @Total_PF_Amount = @Total_PF_Amount
		SET @dblAC1_1 = @dbl367
		SET @dblAC10_1 = @dbl833
		SET @dblAC1_2 = @Total_PF_Amount + @VPF
		SET @dblAC2_3 = round(@Total_Wages_Due * @AC_2_3 / 100, 0)
		SET @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1 / 100, 0)

		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500
		IF @dblAC2_3 < 500
			SET @dblAC2_3 = 500

		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 2 to 200
		--if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
		IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_3 = Round((@AC_22_3 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 0
				SET @dblAC22_3 = 200
		END

		IF (@AC_22_4 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_4 = Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0) > 0
				SET @dblAC22_4 = 200
		END

		-- DEclare @Payment_Date Datetime 
		--Added By Falak on 19-MAY-2011
		SELECT @Payment_Date = Payment_Date
		FROM T0220_PF_CHALLAN WITH (NOLOCK)
		WHERE [Month] = Month(@TEMP_DATE)
			AND [YEAR] = YEAR(@Temp_Date)

		IF @Total_Subscriber > 0
		BEGIN
			INSERT INTO @EMP_SALARY_Challan (
				Cmp_ID
				,Total_Subscriber
				,Total_Wages_Due
				,Total_PF_Diff_Limit
				,AC1_1
				,AC1_2
				,AC2_3
				,AC10_1
				,AC21_1
				,AC22_3
				,For_Date
				,Payment_Date
				,PF_Limit
				,AC22_4
				,Total_Family_Pension_Subscriber
				,Total_Family_Pension_Wages_Amount
				,Total_EDLI_Subscriber
				,Total_EDLI_Wages_Amount
				,VPF
				)
			VALUES (
				@Cmp_ID
				,@Total_Subscriber
				,@Total_Wages_Due
				,@Total_PF_Diff_Limit
				,isnull(@dblAC1_1, 0)
				,@dblAC1_2
				,@dblAC2_3
				,@dblAC10_1
				,@dblAC21_1
				,@dblAC22_3
				,@Temp_DAte
				,@Payment_Date
				,@PF_Limit
				,@dblAC22_4
				,@Total_Family_Pension_Subscriber
				,@Total_Family_Pension_Wages_Amount
				,@Total_EDLI_Subscriber
				,@Total_EDLI_Wages_Amount
				,@VPF
				)
		END

		SET @TEMP_DATE = DATEADD(M, 1, @TEMP_DATE)
	END

	SELECT *
	FROM @EMP_SALARY_Challan ES
	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ES.Cmp_ID = CM.Cmp_Id
END
ELSE IF @Format = 10 ---For PF Challan(Arrear Salary)
BEGIN
	--------------------------------------------- PF CHALLAN CALCULATION 
	SELECT TOP 1 @AC_2_3 = ACC_2_3
		,@AC_22_3 = ACC_22_3
		,@PF_Limit = ACC_10_1_Max_Limit
		,@AC_21_1 = ACC_21_1
		,@PF_Pension_Age = isnull(PF_Pension_Age, 0)
	FROM T0040_General_setting gs WITH (NOLOCK)
	INNER JOIN T0050_General_Detail gd WITH (NOLOCK) ON gs.gen_Id = gd.gen_ID
	WHERE gs.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		AND Branch_ID IN (
			SELECT CAST(DATA AS NUMERIC)
			FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
			)
		AND For_Date IN (
			SELECT max(For_Date)
			FROM T0040_General_setting g WITH (NOLOCK)
			INNER JOIN T0050_General_Detail d WITH (NOLOCK) ON g.gen_Id = d.gen_ID
			WHERE g.Cmp_Id = @cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
				AND Branch_ID IN (
					SELECT CAST(DATA AS NUMERIC)
					FROM dbo.Split(ISNULL(Cast(@Branch_ID AS VARCHAR(1000)), ISNULL(Branch_ID, 0)), '#')
					)
				AND For_Date <= @To_Date
			)

	SET @TEMP_DATE = @FROM_DATE

	WHILE @TEMP_DATE <= @TO_DATE
	BEGIN
		SET @Total_Subscriber = 0
		SET @Total_Wages_Due = 0
		SET @Total_PF_Diff_Limit = 0
		SET @Total_PF_Amount = 0
		SET @dblAC1_1 = 0
		SET @dblAC1_2 = 0
		SET @dblAC2_3 = 0
		SET @dblAC10_1 = 0
		SET @dblAC21_1 = 0
		SET @dblAC22_3 = 0
		SET @dbl833 = 0
		SET @dbl367 = 0
		SET @dblAC22_4 = 0
		SET @MONTH = MONTH(@TEMP_DATE)
		SET @YEAR = YEAR(@TEMP_DATE)
		SET @Total_Family_Pension_Subscriber = 0
		SET @Total_Family_Pension_Wages_Amount = 0
		SET @Total_EDLI_Subscriber = 0
		SET @Total_EDLI_Wages_Amount = 0

		SELECT @Total_Subscriber = count(*)
			,@Total_Wages_Due = isnull(sum(Arrear_Wages), 0)
			,@Total_PF_Amount = isnull(sum(Arrear_PF_Amount), 0)
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year
			AND Arrear_PF_Amount > 0

		SELECT @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500), 0)
			,
			--@dbl833 = round(sum(Isnull(Arrear_PF_833,0))), 
			--@dbl367 = sum(Isnull(Arrear_PF_367,0)),
			@dbl833 = round(sum(Arrear_PF_833), 0)
			,@dbl367 = round(sum(Arrear_PF_367), 0)
			,@VPF = ISNULL(Sum(Arrear_VPF_Amount), 0) --change By Jimit 08022018
		FROM #EMP_SALARY
		WHERE [month] = @month
			AND [year] = @year
			AND (
				PF_Amount > 0
				OR Arrear_PF_Amount > 0
				) --change By Jimit 09032018

		SELECT @Total_Family_Pension_Subscriber = count(emp_ID)
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0
			AND Arrear_PF_Amount > 0

		--Ankit 09052016
		SELECT @Total_Family_Pension_Wages_Amount = Isnull(sum(Arrear_Wages_833), 0)
		FROM #EMP_SALARY
		WHERE isnull(Emp_Age, 0) < @PF_PEnsion_Age
			AND @PF_PEnsion_Age > 0 --  and Arear_Month_Salary_exists = 0

		SELECT @Total_EDLI_Wages_Amount = Isnull(sum(Arrear_Wages_833), 0)
		FROM #EMP_SALARY

		-- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0
		--Ankit 09052016			    
		--   print @AC_21_1
		--   print @Total_EDLI_Wages_Amount	
		--print @Total_PF_Amount				    			    
		--print @VPF
		SET @Total_EDLI_Subscriber = @Total_Subscriber
		--set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit 
		SET @dbl833 = isnull(@dbl833, 0)
		SET @Total_Wages_Due = @Total_Wages_Due
		SET @Total_PF_Amount = @Total_PF_Amount
		SET @dblAC1_1 = @dbl367
		SET @dblAC10_1 = @dbl833
		SET @dblAC1_2 = @Total_PF_Amount + @VPF
		SET @dblAC2_3 = round(@Total_Wages_Due * @AC_2_3 / 100, 0)
		SET @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1 / 100, 0)

		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500
		--If @dblAC2_3 < 500     (Commented By Jimit 07042018 as Rule change rule that if Amount less than 500 then set actual Amount)
		--Set @dblAC2_3 = 500				    
		--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 2 to 200
		--if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
		IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_3 = Round((@AC_22_3 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF (@AC_22_3 * @Total_EDLI_Wages_Amount) / 100 > 0
				SET @dblAC22_3 = 200
		END

		IF (@AC_22_4 * @Total_EDLI_Wages_Amount) / 100 > 200
		BEGIN
			SET @dblAC22_4 = Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0)
		END
		ELSE
		BEGIN
			IF Round((@AC_22_4 * @Total_EDLI_Wages_Amount) / 100, 0) > 0
				SET @dblAC22_4 = 200
		END

		--Added By Falak on 19-MAY-2011
		SELECT @Payment_Date = Payment_Date
		FROM T0220_PF_CHALLAN WITH (NOLOCK)
		WHERE [Month] = Month(@TEMP_DATE)
			AND [YEAR] = YEAR(@Temp_Date)

		IF @Total_Subscriber > 0
		BEGIN
			INSERT INTO @EMP_SALARY_Challan (
				Cmp_ID
				,Total_Subscriber
				,Total_Wages_Due
				,Total_PF_Diff_Limit
				,AC1_1
				,AC1_2
				,AC2_3
				,AC10_1
				,AC21_1
				,AC22_3
				,For_Date
				,Payment_Date
				,PF_Limit
				,AC22_4
				,Total_Family_Pension_Subscriber
				,Total_Family_Pension_Wages_Amount
				,Total_EDLI_Subscriber
				,Total_EDLI_Wages_Amount
				,VPF
				)
			VALUES (
				@Cmp_ID
				,@Total_Subscriber
				,@Total_Wages_Due
				,@Total_PF_Diff_Limit
				,isnull(@dblAC1_1, 0)
				,@dblAC1_2
				,@dblAC2_3
				,@dblAC10_1
				,@dblAC21_1
				,@dblAC22_3
				,@Temp_DAte
				,@Payment_Date
				,@PF_Limit
				,@dblAC22_4
				,@Total_Family_Pension_Subscriber
				,@Total_Family_Pension_Wages_Amount
				,@Total_EDLI_Subscriber
				,@Total_EDLI_Wages_Amount
				,@VPF
				)
		END

		SET @TEMP_DATE = DATEADD(M, 1, @TEMP_DATE)
	END

	SELECT *
	FROM @EMP_SALARY_Challan ES
	INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ES.Cmp_ID = CM.Cmp_Id
END
ELSE IF @Format = 6 -- For Left Employee text file generation
BEGIN
	SELECT month(@To_Date) AS Month
		,year(@To_Date) AS Year
		,Isnull(E.UAN_No, '') + '#~#' + isnull(Convert(VARCHAR(10), LE.Left_Date, 103), '') + '#~#' + Isnull(LE.LeftReasonValue, 0) AS Text_String
		,Grd_Name
		,Type_Name
		,dept_Name
		,Desig_Name
		,Cmp_Name
		,Cmp_Address
		,Alpha_Emp_Code
		,Desig_Dis_No
		,Emp_First_Name
	FROM T0080_EMP_MASTER E WITH (NOLOCK)
	INNER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
	INNER JOIN (
		SELECT I.Branch_ID
			,I.Grd_ID
			,I.Dept_ID
			,I.Desig_ID
			,I.Emp_ID
			,Type_ID
			,Wages_Type
		FROM T0095_Increment I WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) Q_I ON E.EMP_ID = Q_I.EMP_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
	LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
	INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
	INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
	WHERE (
			E.Emp_Left = 'Y'
			OR Emp_Left_Date IS NOT NULL
			)
		AND LE.Left_Date BETWEEN @From_Date
			AND @To_Date
	--Where PF_Amount > 0
	ORDER BY RIGHT(REPLICATE(N' ', 500) + E.Alpha_Emp_Code, 500)

	RETURN
END
ELSE IF @Format = 11 -- For consolidated Report ( Regual + Arrear Amt) Without Limit --Added by Jaina 16-09-2020
BEGIN
	SELECT EPF.*
		,(PF_AMOUNT) + Isnull(Arrear_PF_Amount, 0) AS PF_AMOUNT
		,PF_PER
		,PF_Limit AS PF_Limit --+ Isnull(Es.Arrear_Wages_833,0) as PF_Limit   --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		,EDLI_Wages AS EDLI_Wages
		,--+ Isnull(es.Arrear_Wages_833,0) as EDLI_Wages, --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		PF_SALARY_AMOUNT AS PF_SALARY_AMOUNT
		,--+ Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT,  --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.
		PF_833 + Arrear_PF_833 AS PF_833 --+ Isnull(Arrear_PF_833,0) as PF_833
		--,PF_367 + Isnull(Arrear_PF_367,0) as PF_367
		--,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) - ISNULL(PF_833,0) as PF_367
		,PF_367 + Arrear_PF_367 AS PF_367
		--,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,
		,PF_Diff_6500
		,EMP_SECOND_NAME
		,ES.VPF + Isnull(ES.Arrear_VPF_Amount, 0) AS VPF
		,E.Basic_Salary
		,E.Emp_code
		,--Hardik 26/12/2017
		UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
					WHEN isnull(Emp_Second_Name, '') <> ''
						THEN + ' ' + Emp_Second_Name
					END + CASE 
					WHEN isnull(Emp_Last_Name, '') <> ''
						THEN + ' ' + Emp_Last_Name
					END)) AS Emp_Full_Name
		,Grd_Name
		,Type_Name
		,dept_Name
		,Desig_Name
		,Cmp_Name
		,Cmp_Address
		,cm.PF_No AS CPF_NO
		,@From_Date P_From_Date
		,@To_Date P_To_Date
		,Father_Name
		,Le.Left_Date
		,Le.Left_Reason
		,CAST((
				CASE 
					WHEN (@IS_NCP_PRORATA = 1)
						THEN [dbo].[F_Get_NCP_Days](/*@From_Date,@To_Date*/ MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days)
					ELSE Ms.Absent_Days
					END
				) AS NUMERIC(18, 2)) AS Absent_Days
		,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)
		,ES.arrear_days
		,ES.VPF_PER
		,BM.Branch_Name
		,date_of_join
		,E.Alpha_Emp_Code
		,E.Emp_First_Name --added jimit 25052015
		,dgm.Desig_Dis_No --added jimit 25092015
		,(EDLI_Wages + Isnull(es.Arrear_Wages_833, 0)) * @Edli_charge / 100 AS EDLI
		,vs.Vertical_Name
		,sv.SubVertical_name
		,Isnull(E.UAN_No, '') AS UAN_No
		,'' AS Format_Type
		,ES.Gross_Salary AS Gross_Salary --added jimit 02072016
	FROM #EMP_PF_REPORT EPF
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
	LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
	LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
		AND EPF.MONTH = ES.MONTH
		AND EPF.YEAR = ES.YEAR
	LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
		AND ES.MONTH = month(MS.Month_St_Date)
		AND ES.YEAR = year(MS.Month_St_Date)
	INNER JOIN (
		SELECT I.Branch_ID
			,I.Grd_ID
			,I.Dept_ID
			,I.Desig_ID
			,I.Emp_ID
			,Type_ID
			,Wages_Type
			,I.Vertical_ID
			,I.SubVertical_ID
		FROM T0095_Increment I WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) Q_I ON E.EMP_ID = Q_I.EMP_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
	LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
	INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
	LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
	LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
	INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
	WHERE Pf_Amount <> 0 --Added By Jimit 25052018
	ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
END
ELSE
BEGIN
	--Added by chetan 031017 for show ECR file in individual column
	IF @Export_Type = '4'
	BEGIN
		SELECT ISNULL(E.UAN_No, '') AS UAN_NO
			,UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
						WHEN ISNULL(Emp_Second_Name, '') <> ''
							THEN + ' ' + Emp_Second_Name
						ELSE ''
						END + CASE 
						WHEN ISNULL(Emp_Last_Name, '') <> ''
							THEN + ' ' + Emp_Last_Name
						ELSE ''
						END)) AS EMP_FULL_NAME
			,CAST(CAST(ROUND(ISNULL(Ms.Gross_Salary, 0) - (ISNULL(MS.Arear_Gross, 0) + ISNULL(Ms.Settelement_Amount, 0)), 0) AS NUMERIC) AS VARCHAR(10)) AS GROSS_WAGES
			,CAST(PF_SALARY_AMOUNT AS VARCHAR(10)) AS EPF_WAGES
			,CAST(PF_LIMIT AS VARCHAR(10)) EPS_WAGES
			,CAST(EDLI_Wages AS VARCHAR(10)) AS EDLI_WAGES
			,CAST(PF_AMOUNT + ISNULL(VPF, 0) AS VARCHAR(10)) AS EPF_CONTRI_REMITTED
			,CAST(PF_833 AS VARCHAR(10)) AS EPS_CONTRI_REMITTED
			,CAST(PF_367 AS VARCHAR(10)) AS EPF_EPS_DIFF_REMITTED
			,CASE 
				WHEN @IS_NCP_PRORATA = 1
					THEN CAST([dbo].[F_Get_NCP_Days](MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days) AS VARCHAR(2))
				ELSE CASE 
						WHEN Ms.Absent_Days < 0
							THEN '0'
						ELSE Cast(Ms.Absent_Days AS VARCHAR(4))
						END
				END AS NCP_DAYS
			,CAST(0 AS VARCHAR(10)) AS REFUND_OF_ADVANCES
		FROM #EMP_PF_REPORT EPF
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
		LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
			AND EPF.MONTH = ES.MONTH
			AND EPF.YEAR = ES.YEAR
		LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
			AND ES.MONTH = MONTH(MS.Month_St_Date)
			AND ES.YEAR = YEAR(MS.Month_St_Date)
		INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON E.Emp_ID = I.EMP_ID
		INNER JOIN #Emp_Cons EC ON I.Increment_ID = EC.Increment_ID
			AND I.Emp_ID = EC.Emp_ID
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = gm.Grd_ID
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.BRANCH_ID = BM.BRANCH_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID
		LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON I.Type_ID = Tm.Type_Id
		INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
		INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
		LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON I.Vertical_ID = vs.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON I.SubVertical_ID = sv.SubVertical_ID
		ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
	END
	ELSE IF (
			@Format = 0
			AND @Export_Type = 'CUSTOMIZED_EXCEL'
			) -- CODE ADDED BY RAMIZ ON 19/10/2018
	BEGIN
		PRINT 13223

		--Comment by deepal 
		/*********** GENERAL PORTION OF EMPLOYEE DETAILS ************************/
		--	SELECT E.ALPHA_EMP_CODE , ISNULL(EMPNAME_ALIAS_PF,Emp_Full_Name) as EMP_FULL_NAME ,BM.BRANCH_NAME as BRANCH, DM.Dept_Name AS DEPARTMENT ,DGM.Desig_Name AS DESIGNATION , GM.Grd_Name AS GRADE
		--		,CCM.Center_Name AS COST_CENTER , CCM.CENTER_CODE , CTM.Cat_Name AS CATEGORY , VS.Vertical_Name AS VERTICAL ,SV.SubVertical_name AS SUBVERTICAL , BS.Segment_Name AS BUSINESS_SEGMENT 
		--		,CONVERT(VARCHAR(20) , E.DATE_OF_JOIN , 103) AS DATE_OF_JOIN 
		--		,E.UAN_NO
		--		,EPF.PF_NO
		--		/*********** NORMAL PF PORTION STARTS HERE ************************/
		--		,ES.PF_SALARY_AMOUNT as PF_WAGES , ES.PF_LIMIT AS PENSION_WAGES, EDLI_Wages as EDLI_WAGES
		--		,PF_AMOUNT as PF_AMOUNT , ES.VPF AS VOLUNTARY_PF 
		--		,(ES.PF_AMOUNT + ES.VPF) AS TOTAL_EMPLOYEE_CONTRIBUTION
		--		,ES.PF_367  as Employee_Pf_367--as '+ @dynColChg +'
		--		,ES.PF_833 as PENSION_FUND_833, (ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYER_CONTRIBUTION
		--		,(ES.PF_AMOUNT + ES.VPF + ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYEE_AND_EMPLOYER_CONTRIBUTION
		--		,ES.PF_Admin_Charge_Empwise AS PF_ADMIN_CHARGE_02 ,ES.Edli_Charge_EmpWise AS EDLI_CHARGE_21 ,ROUND((ES.PF_Admin_Charge_Empwise + ES.Edli_Charge_EmpWise),0) as TOTAL_FUND_PF , E.BASIC_SALARY
		--		,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0))) as Gross_Salary
		--		,CAST((
		--				CASE WHEN (@IS_NCP_PRORATA = 1) Then 
		--					[dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)
		--				Else 
		--					Case When Ms.Absent_Days < 0 Then 0 Else Ms.Absent_Days End
		--				End
		--			) AS Numeric(18,2)) as NCP_DAYS
		--		/*********** ARREAR PORTION STARTS HERE ************************/
		--		,ES.ARREAR_DAYS
		--		,ISNULL(ES.Arrear_Wages,0) AS PF_ARREARS_WAGES
		--		,ISNULL(ES.Arrear_Wages_833,0) AS PENSION_ARREARSWAGES
		--		,ISNULL(ES.Arrear_Wages_833,0) AS EDLI_ARREARS_WAGES
		--		,ISNULL(ES.Arrear_PF_Amount,0) AS PF_ARREARS
		--		,ISNULL(ES.Arrear_VPF_Amount,0) AS VOLUNTARY_PF_ARREARS
		--		,(ISNULL(ES.Arrear_PF_Amount,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_EMP_CONTRIBUTION_ARREARS
		--		,ISNULL(ES.Arrear_PF_367,0) AS EMPLOYER_PF_ARREARS
		--		,ISNULL(ES.Arrear_PF_833,0) AS PENSION_FUND_ARREARS
		--		,(ISNULL(ES.Arrear_PF_367,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_EMPLOYER_CONTRIBUTION_ARREARS
		--		,ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS ADMIN_CHARGE_02_ARREARS 
		--		,ISNULL(Arrear_Edli_Charge_EmpWise,0) AS EDLI_CHARGE_21_ARREARS
		--		,ROUND((Arrear_PF_Admin_Charge_Empwise + Arrear_Edli_Charge_EmpWise),0) AS TOTAL_FUNDS_ARREARS
		--		/*********** TOTAL OF PF & ARREARS STARTS HERE ************************/
		--		,(ISNULL(ES.PF_AMOUNT,0) + ISNULL(ES.Arrear_PF_Amount,0)) AS TOTAL_PF
		--		,(ISNULL(ES.VPF,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_VOLUNTARY_PF
		--		,(ISNULL(ES.PF_367,0) + ISNULL(ES.Arrear_PF_367,0)) AS TOTAL_EMPLOYER_PF
		--		,(ISNULL(ES.PF_833,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_PENSION_FUND
		--		,(ES.PF_AMOUNT + ISNULL(ES.Arrear_PF_Amount,0) + ES.VPF + ISNULL(ES.Arrear_VPF_Amount,0) + ES.PF_367 + ISNULL(ES.Arrear_PF_367,0) + ES.PF_833 + ISNULL(ES.Arrear_PF_833,0) ) AS CONTRIBUTION_TOTAL
		--		,ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS TOTAL_ADMIN_CHARGE_02
		--		,ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0) AS TOTAL_EDLI_CHARGE_21
		--		,ROUND(ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) + ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0),0) AS TOTAL_FUNDS
		--FROM #EMP_PF_REPORT EPF 
		--	INNER JOIN		T0080_EMP_MASTER E  ON EPF.EMP_ID = E.EMP_ID
		--	INNER JOIN		#EMP_CONS EC ON EC.Emp_ID = EPF.EMP_ID
		--	INNER JOIN		#EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
		--	INNER JOIN		T0095_INCREMENT INC ON INC.INCREMENT_ID = EC.INCREMENT_ID AND INC.EMP_ID = EC.EMP_ID
		--	INNER JOIN		T0040_GRADE_MASTER GM ON INC.GRD_ID = GM.GRD_ID 
		--	INNER JOIN		T0030_BRANCH_MASTER BM ON INC.BRANCH_ID = BM.BRANCH_ID
		--	INNER JOIN		T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
		--	INNER JOIN		T0040_DESIGNATION_MASTER DGM ON INC.DESIG_ID = DGM.DESIG_ID
		--	LEFT OUTER JOIN	T0100_LEFT_EMP LE ON E.EMP_ID = LE.EMP_ID 
		--	LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR
		--	LEFT OUTER JOIN T0200_MONTHLY_SALARY MS on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and  ES.YEAR =year(MS.Month_St_Date)
		--	LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM ON INC.DEPT_ID = DM.DEPT_ID 
		--	LEFT OUTER JOIN T0040_TYPE_MASTER TM ON INC.TYPE_ID = TM.TYPE_ID
		--	LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS ON INC.VERTICAL_ID = VS.VERTICAL_ID
		--	LEFT OUTER JOIN	T0050_SUBVERTICAL SV ON INC.SUBVERTICAL_ID = SV.SUBVERTICAL_ID
		--	LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM ON INC.Center_ID = CCM.Center_ID
		--	LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM ON INC.Cat_ID = CTM.Cat_ID
		--	LEFT OUTER JOIN T0040_Business_Segment BS ON INC.Segment_ID = BS.Segment_ID
		DECLARE @query AS VARCHAR(max)
		DECLARE @query1 AS VARCHAR(max)
		DECLARE @dynColChg AS VARCHAR(50)

		IF month(@To_Date) IN (
				5
				,6
				,7
				)
			AND year(@To_Date) = 2020
		BEGIN
			SET @dynColChg = 'EMPLOYER_PF_167'
		END
		ELSE
		BEGIN
			SET @dynColChg = 'EMPLOYER_PF_367'
		END

		SELECT *
		FROM #EMP_SALARY

		--select * from #EMP_PF_REPORT--mansi
		SET @query = 'SELECT E.ALPHA_EMP_CODE , ISNULL(EMPNAME_ALIAS_PF,Emp_Full_Name) as EMP_FULL_NAME ,BM.BRANCH_NAME as BRANCH
									, DM.Dept_Name AS DEPARTMENT ,DGM.Desig_Name AS DESIGNATION , GM.Grd_Name AS GRADE ,CCM.Center_Name AS COST_CENTER , CCM.CENTER_CODE 
									, CTM.Cat_Name AS CATEGORY ,VS.Vertical_Name AS VERTICAL ,SV.SubVertical_name AS SUBVERTICAL , BS.Segment_Name AS BUSINESS_SEGMENT 
									,CONVERT(VARCHAR(20),E.DATE_OF_JOIN,103) AS DATE_OF_JOIN ,E.UAN_NO,EPF.PF_NO
									/* NORMAL PF PORTION STARTS HERE */
									,ES.PF_SALARY_AMOUNT as PF_WAGES , ES.PF_LIMIT AS PENSION_WAGES, EDLI_Wages as EDLI_WAGES
									,PF_AMOUNT as PF_AMOUNT , ES.VPF AS VOLUNTARY_PF ,(ES.PF_AMOUNT + ES.VPF) AS TOTAL_EMPLOYEE_CONTRIBUTION
									,ES.PF_367 as ' + @dynColChg + 
			',ES.PF_833 as PENSION_FUND_833, (ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYER_CONTRIBUTION
									,(ES.PF_AMOUNT + ES.VPF + ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYEE_AND_EMPLOYER_CONTRIBUTION
									,ES.PF_Admin_Charge_Empwise AS PF_ADMIN_CHARGE_02 ,ES.Edli_Charge_EmpWise AS EDLI_CHARGE_21 ,ROUND((ES.PF_Admin_Charge_Empwise + ES.Edli_Charge_EmpWise),0) as TOTAL_FUND_PF , E.BASIC_SALARY
									,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0))) as Gross_Salary
									,CAST((CASE WHEN ' + convert(VARCHAR(100), @IS_NCP_PRORATA) + ' = 1  Then [dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days ,' + convert(VARCHAR(100), @PF_LIMIT) + 
			',ms.Absent_Days,Wages_Type,Weekoff_Days)Else Case When Ms.Absent_Days < 0 Then 0 Else Ms.Absent_Days End End) AS Numeric(18,2)) as NCP_DAYS
									/* ARREAR PORTION STARTS HERE */
									,ES.ARREAR_DAYS,ISNULL(ES.Arrear_Wages,0) AS PF_ARREARS_WAGES
									,ISNULL(ES.Arrear_Wages_833,0) AS PENSION_ARREARSWAGES,ISNULL(ES.Arrear_Wages_833,0) AS EDLI_ARREARS_WAGES
									,ISNULL(ES.Arrear_PF_Amount,0) AS PF_ARREARS,ISNULL(ES.Arrear_VPF_Amount,0) AS VOLUNTARY_PF_ARREARS
									,(ISNULL(ES.Arrear_PF_Amount,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_EMP_CONTRIBUTION_ARREARS
									,ISNULL(ES.Arrear_PF_367,0) AS EMPLOYER_PF_ARREARS,ISNULL(ES.Arrear_PF_833,0) AS PENSION_FUND_ARREARS
									,(ISNULL(ES.Arrear_PF_367,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_EMPLOYER_CONTRIBUTION_ARREARS,ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS ADMIN_CHARGE_02_ARREARS 
									,ISNULL(Arrear_Edli_Charge_EmpWise,0) AS EDLI_CHARGE_21_ARREARS,ROUND((Arrear_PF_Admin_Charge_Empwise + Arrear_Edli_Charge_EmpWise),0) AS TOTAL_FUNDS_ARREARS
									/* TOTAL OF PF & ARREARS STARTS HERE */
									,(ISNULL(ES.PF_AMOUNT,0) + ISNULL(ES.Arrear_PF_Amount,0)) AS TOTAL_PF,(ISNULL(ES.VPF,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_VOLUNTARY_PF
									,(ISNULL(ES.PF_367,0) + ISNULL(ES.Arrear_PF_367,0)) AS TOTAL_EMPLOYER_PF,(ISNULL(ES.PF_833,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_PENSION_FUND
									,(ES.PF_AMOUNT + ISNULL(ES.Arrear_PF_Amount,0) + ES.VPF + ISNULL(ES.Arrear_VPF_Amount,0) + ES.PF_367 + ISNULL(ES.Arrear_PF_367,0) + ES.PF_833 + ISNULL(ES.Arrear_PF_833,0) ) AS CONTRIBUTION_TOTAL
									,ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS TOTAL_ADMIN_CHARGE_02
									,ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0) AS TOTAL_EDLI_CHARGE_21
									,ROUND(ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) + ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0),0) AS TOTAL_FUNDS'
		SET @query1 = 
			'FROM #EMP_PF_REPORT EPF 
									INNER JOIN	T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
									INNER JOIN	#EMP_CONS EC ON EC.Emp_ID = EPF.EMP_ID
									INNER JOIN	#EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
									INNER JOIN	T0095_INCREMENT INC WITH (NOLOCK) ON INC.INCREMENT_ID = EC.INCREMENT_ID AND INC.EMP_ID = EC.EMP_ID
									INNER JOIN	T0040_GRADE_MASTER GM WITH (NOLOCK) ON INC.GRD_ID = GM.GRD_ID 
									INNER JOIN	T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.BRANCH_ID = BM.BRANCH_ID
									INNER JOIN	T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
									INNER JOIN	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON INC.DESIG_ID = DGM.DESIG_ID
									LEFT OUTER JOIN	T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID 
									LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR
									LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and  ES.YEAR =year(MS.Month_St_Date)
									LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC.DEPT_ID = DM.DEPT_ID 
									LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON INC.TYPE_ID = TM.TYPE_ID
									LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON INC.VERTICAL_ID = VS.VERTICAL_ID
									LEFT OUTER JOIN	T0050_SUBVERTICAL SV WITH (NOLOCK) ON INC.SUBVERTICAL_ID = SV.SUBVERTICAL_ID
									LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON INC.Center_ID = CCM.Center_ID
									LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON INC.Cat_ID = CTM.Cat_ID
									LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON INC.Segment_ID = BS.Segment_ID'

		EXECUTE (@query + ' ' + @query1)
			--Update by Deepal --09062020
	END
	ELSE IF (
			@Format = 1
			AND @Export_Type = 'CUSTOMIZED_EXCEL'
			) -- ADDED BY JIMIT 29/10/2018
	BEGIN
		SELECT EPF.EMP_CODE
			,UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
						WHEN isnull(Emp_Second_Name, '') <> ''
							THEN + ' ' + Emp_Second_Name
						ELSE ''
						END + CASE 
						WHEN isnull(Emp_Last_Name, '') <> ''
							THEN + ' ' + Emp_Last_Name
						ELSE ''
						END)) AS Emp_Full_Name
			,Cmp_Name
			,bm.Branch_Name
			,Grd_Name
			,dept_Name
			,Desig_Name
			,Type_Name
			,vs.Vertical_Name
			,sv.SubVertical_name
			,E.UAN_No
			,E.Basic_Salary
			,Ms.Gross_Salary
			,Le.Left_Date
			,Le.Left_Reason
			,round(MS.Absent_Days, 0) Absent_Days
			,ES.Sal_Cal_Day
			,ES.arrear_days
			,ES.Arear_M_AD_Amount
			,ES.Arrear_Wages
			,EPF.FOR_DATE
			,EPF.[MONTH]
			,EPF.[YEAR]
			,EPF.PF_NO
			,(PF_AMOUNT) PF_AMOUNT
			,PF_PER
			,PF_Limit
			,EDLI_Wages
			,PF_SALARY_AMOUNT
			,PF_833
			,PF_367
			,PF_Diff_6500
			,ES.VPF
			,cm.PF_No AS CPF_NO
			,@From_Date P_From_Date
			,@To_Date P_To_Date
			,ES.VPF_PER
			,ES.Arrear_PF_Amount
			,ES.Arrear_Wages_833
			,ES.Arrear_PF_833
			,ES.Arrear_PF_367
			,(
				CASE 
					WHEN @To_Date >= '2016-12-01'
						THEN
							--(CASE When @Format = 2 THEN					
							Isnull(E.UAN_No, '') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
										WHEN isnull(Emp_Second_Name, '') <> ''
											THEN + ' ' + Emp_Second_Name
										ELSE ''
										END + CASE 
										WHEN isnull(Emp_Last_Name, '') <> ''
											THEN + ' ' + Emp_Last_Name
										ELSE ''
										END)) + '#~#' + CAST(Cast(Round(Isnull(Ms.Gross_Salary, 0) - (Isnull(MS.Arear_Gross, 0) + ISNULL(Ms.Settelement_Amount, 0)), 0) AS NUMERIC) AS VARCHAR(10)) + '#~#' + CAST(PF_SALARY_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_LIMIT AS VARCHAR(10)) + '#~#' + CAST(EDLI_Wages AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT + ISNULL(VPF, 0) AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_367 AS VARCHAR(10)) + '#~#' + CASE 
								WHEN @IS_NCP_PRORATA = 1
									THEN CAST([dbo].[F_Get_NCP_Days](MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days) AS VARCHAR(2))
								ELSE CASE 
										WHEN cast(Ms.Absent_Days AS NUMERIC(18, 0)) < 0
											THEN '0'
										ELSE Cast(cast(Ms.Absent_Days AS NUMERIC(18, 0)) AS VARCHAR(6))
										END
								END + '#~#' + CAST(0 AS VARCHAR(10))
							--ELSE
							--	IsNull(E.UAN_No,'') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + '#~#' + CAST(Arrear_Wages As Varchar(10)) + '#~#' 
							--	+ Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'	
							--	+ Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'	
							--	+ CAST(cast(round((Isnull(Arrear_PF_Amount,0) + Isnull(Arrear_VPF_Amount,0)),0) as Numeric)AS Varchar(10))+ '#~#'
							--	+ CAST(Arrear_PF_367 AS Varchar(10)) + '#~#' + CAST(Arrear_PF_833 AS Varchar(10))
							--END)
					ELSE EPf.PF_NO + '#~#' + UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
									WHEN isnull(Emp_Second_Name, '') <> ''
										THEN + ' ' + Emp_Second_Name
									ELSE ''
									END + CASE 
									WHEN isnull(Emp_Last_Name, '') <> ''
										THEN + ' ' + Emp_Last_Name
									ELSE ''
									END)) + '#~#' + Cast(PF_SALARY_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_LIMIT AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_367 AS VARCHAR(10)) + '#~#' + CAST(PF_367 AS VARCHAR(10)) + '#~#' + CASE 
							WHEN @IS_NCP_PRORATA = 1
								THEN CAST([dbo].[F_Get_NCP_Days](MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days) AS VARCHAR(2))
							ELSE CASE 
									WHEN Ms.Absent_Days < 0
										THEN '0'
									ELSE Cast(Ms.Absent_Days AS VARCHAR(10))
									END
							END + '#~#' + CAST(0 AS VARCHAR(10)) + '#~#' + CAST(Arrear_Wages AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_Amount AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_367 AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_833 AS VARCHAR(10)) + '#~#' + ED.FATHER_HUSBAND_NAME + ED.RELATION + ED.DOB + ED.GENDER + ED.DOJ + ED.DOJ + ED.LEFT_DATE + ED.LEFT_DATE + ED.LEFT_REASON
					END
				) AS Text_String
			,@PF_LIMIT AS Pf_Max_Limit
		FROM #EMP_PF_REPORT EPF
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
		LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
			AND EPF.MONTH = ES.MONTH
			AND EPF.YEAR = ES.YEAR
		LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
			AND ES.MONTH = month(MS.Month_St_Date)
			AND ES.YEAR = year(MS.Month_St_Date)
		INNER JOIN (
			SELECT I.Branch_ID
				,I.Grd_ID
				,I.Dept_ID
				,I.Desig_ID
				,I.Emp_ID
				,Type_ID
				,Wages_Type
				,I.Vertical_ID
				,I.SubVertical_ID
			FROM T0095_Increment I WITH (NOLOCK)
			INNER JOIN (
				SELECT max(Increment_ID) AS Increment_ID
					,Emp_ID
				FROM T0095_Increment WITH (NOLOCK)
				WHERE Increment_Effective_date <= @To_Date
					AND Cmp_ID = @Cmp_ID
				GROUP BY emp_ID
				) Qry ON I.Emp_ID = Qry.Emp_ID
				AND I.Increment_ID = Qry.Increment_ID
			) Q_I ON E.EMP_ID = Q_I.EMP_ID
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
		LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
		INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
		INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
		LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
		ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
	END
	ELSE --IF (@Format = 2)
	BEGIN
		SELECT EPF.* --, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) ) as SALARY_AMOUNT
			,(PF_AMOUNT) PF_AMOUNT
			,PF_PER
			,PF_Limit
			,EDLI_Wages
			,PF_SALARY_AMOUNT
			,PF_833
			,PF_367
			,PF_Diff_6500
			,EMP_SECOND_NAME
			,ES.VPF
			,E.Basic_Salary
			,E.Emp_code
			,UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
						WHEN isnull(Emp_Second_Name, '') <> ''
							THEN + ' ' + Emp_Second_Name
						ELSE ''
						END + CASE 
						WHEN isnull(Emp_Last_Name, '') <> ''
							THEN + ' ' + Emp_Last_Name
						ELSE ''
						END)) AS Emp_Full_Name
			,Grd_Name
			,Type_Name
			,dept_Name
			,Desig_Name
			,Cmp_Name
			,Cmp_Address
			,cm.PF_No AS CPF_NO
			,@From_Date P_From_Date
			,@To_Date P_To_Date
			,Father_Name
			,Le.Left_Date
			,Le.Left_Reason
			,round(MS.Absent_Days, 0) Absent_Days
			,ES.Sal_Cal_Day
			,ES.arrear_days
			,ES.VPF_PER
			,ES.Arear_M_AD_Amount
			,ES.Arrear_Wages
			,ES.Arrear_PF_Amount
			,ES.Arrear_Wages_833
			,ES.Arrear_PF_833
			,ES.Arrear_PF_367
			,
			--added by jimit 02012017  new online format after 1st december 2016 and old format before it.
			(
				CASE 
					WHEN @To_Date >= '2016-12-01'
						THEN (
								CASE 
									WHEN @Format = 2
										THEN Isnull(E.UAN_No, '') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
														WHEN isnull(Emp_Second_Name, '') <> ''
															THEN + ' ' + Emp_Second_Name
														ELSE ''
														END + CASE 
														WHEN isnull(Emp_Last_Name, '') <> ''
															THEN + ' ' + Emp_Last_Name
														ELSE ''
														END)) + '#~#' + CAST(Cast(Round(Isnull(Ms.Gross_Salary, 0) - (Isnull(MS.Arear_Gross, 0) + ISNULL(Ms.Settelement_Amount, 0)), 0) AS NUMERIC) AS VARCHAR(10)) + '#~#' + CAST(PF_SALARY_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_LIMIT AS VARCHAR(10)) + '#~#' + CAST(EDLI_Wages AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT + ISNULL(VPF, 0) AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_367 AS VARCHAR(10)) + '#~#' + CASE 
												WHEN @IS_NCP_PRORATA = 1
													THEN CAST([dbo].[F_Get_NCP_Days](/*@From_Date,@To_Date*/ MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days) AS VARCHAR(2))
												ELSE CASE 
														WHEN Ms.Absent_Days < 0
															THEN '0'
														ELSE Cast(Ms.Absent_Days AS VARCHAR(10))
														END
												END + '#~#' + CAST(0 AS VARCHAR(10))
									ELSE IsNull(E.UAN_No, '') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
													WHEN isnull(Emp_Second_Name, '') <> ''
														THEN + ' ' + Emp_Second_Name
													ELSE ''
													END + CASE 
													WHEN isnull(Emp_Last_Name, '') <> ''
														THEN + ' ' + Emp_Last_Name
													ELSE ''
													END)) + '#~#' + CAST(Arrear_Wages AS VARCHAR(10)) + '#~#' + CASE 
											WHEN Isnull(Arrear_PF_833, 0) <> 0
												THEN (
														CASE 
															WHEN Pension_Not_Applicable = 1
																THEN '0'
															ELSE CAST(Arrear_Wages_833 AS VARCHAR(10))
															END
														)
											ELSE Cast(0 AS VARCHAR)
											END + '#~#' --Change by ronakk 14072023
										+ CAST(Arrear_Wages_833 AS VARCHAR(10)) + '#~#' --EDLI Wages
										--+ Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'	--Commented By Jimit 12-11-2018 as there is case at WCl for Employee Age greather than pension age Edli Wages amount 0 									
										--+ CAST(cast(round((Isnull(Arrear_PF_Amount,0) + Isnull(Arrear_VPF_Amount,0)),0) as Numeric)AS Varchar(10)) + '#~#'
										+ CAST(cast(round((Isnull(Arrear_PF_Amount, 0) + Isnull(Arrear_VPF_Amount, 0)), 0) AS NUMERIC) AS VARCHAR(10)) + '#~#' + (
											CASE 
												WHEN Pension_Not_Applicable = 1
													THEN CAST((Arrear_PF_367 + Arrear_PF_833) AS VARCHAR(10))
												ELSE CAST(Arrear_PF_367 AS VARCHAR(10))
												END
											) --Change by ronakk 14072023
										+ '#~#' + (
											CASE 
												WHEN Pension_Not_Applicable = 1
													THEN '0'
												ELSE CAST(Arrear_PF_833 AS VARCHAR(10))
												END
											) --Change by ronakk 14072023
									END
								)
					ELSE EPf.PF_NO + '#~#' + UPPER(ISNULL(EmpName_Alias_PF, Emp_First_Name + CASE 
									WHEN isnull(Emp_Second_Name, '') <> ''
										THEN + ' ' + Emp_Second_Name
									ELSE ''
									END + CASE 
									WHEN isnull(Emp_Last_Name, '') <> ''
										THEN + ' ' + Emp_Last_Name
									ELSE ''
									END)) + '#~#' + Cast(PF_SALARY_AMOUNT AS VARCHAR(10)) + '#~#'
						--+ CAST(PF_SALARY_AMOUNT As Varchar(10)) + '#~#' + ----Golcha For Basic allowance amount Imported and effect on PF after discuss with Hardikbhai	--Ankit 09092015
						+ CAST(PF_LIMIT AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_AMOUNT AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_833 AS VARCHAR(10)) + '#~#' + CAST(PF_367 AS VARCHAR(10)) + '#~#'
						--+  CAST(PF_367 AS Varchar(10)) + '#~#' + CAST(Cast(Ms.Absent_Days As Numeric) As Varchar(2)) + '#~#'
						+ CAST(PF_367 AS VARCHAR(10)) + '#~#' + CASE 
							WHEN @IS_NCP_PRORATA = 1
								THEN CAST([dbo].[F_Get_NCP_Days](/*@From_Date,@To_Date*/ MS.Month_St_Date, MS.Month_End_Date, Ms.Basic_Salary, Ms.Salary_Amount, Ms.Sal_Cal_Days, @PF_LIMIT, ms.Absent_Days, Wages_Type, Weekoff_Days) AS VARCHAR(2))
							ELSE CASE 
									WHEN Ms.Absent_Days < 0
										THEN '0'
									ELSE Cast(Ms.Absent_Days AS VARCHAR(4))
									END
							END + '#~#' + CAST(0 AS VARCHAR(10)) + '#~#' + CAST(Arrear_Wages AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_Amount AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_367 AS VARCHAR(10)) + '#~#' + CAST(Arrear_PF_833 AS VARCHAR(10)) + '#~#' + ED.FATHER_HUSBAND_NAME + ED.RELATION + ED.DOB + ED.GENDER + ED.DOJ + ED.DOJ + ED.LEFT_DATE + ED.LEFT_DATE + ED.LEFT_REASON
					END
				) AS Text_String
			,Dgm.Desig_Dis_No
			,E.Alpha_Emp_Code
			,E.Emp_First_Name --added jimit 25092015
			,vs.Vertical_Name
			,sv.SubVertical_name
			,bm.Branch_Name
			,@PF_LIMIT AS Pf_Max_Limit --added jimit 14042017	
			,E.UAN_No --added by jimit 07062017
			,BM.Comp_Name
			,BM.Branch_Address --added by jimit 27062017
			,Ms.Gross_Salary --Added By Jimit 25122017
		FROM #EMP_PF_REPORT EPF
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID = Le.Emp_ID
		LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID
			AND EPF.MONTH = ES.MONTH
			AND EPF.YEAR = ES.YEAR
		LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID = MS.Emp_ID
			AND ES.MONTH = month(MS.Month_St_Date)
			AND ES.YEAR = year(MS.Month_St_Date)
		INNER JOIN (
			SELECT I.Branch_ID
				,I.Grd_ID
				,I.Dept_ID
				,I.Desig_ID
				,I.Emp_ID
				,Type_ID
				,Wages_Type
				,I.Vertical_ID
				,I.SubVertical_ID
			FROM T0095_Increment I WITH (NOLOCK)
			INNER JOIN (
				SELECT max(Increment_ID) AS Increment_ID
					,Emp_ID
				FROM T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment
				WHERE Increment_Effective_date <= @To_Date
					AND Cmp_ID = @Cmp_ID
				GROUP BY emp_ID
				) Qry ON I.Emp_ID = Qry.Emp_ID
				AND I.Increment_ID = Qry.Increment_ID
			) Q_I ON E.EMP_ID = Q_I.EMP_ID
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID
		LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Q_I.Type_ID = Tm.Type_Id
		INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id
		INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID
		LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON Q_I.Vertical_ID = vs.Vertical_ID
		LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON Q_I.SubVertical_ID = sv.SubVertical_ID
		--Where PF_Amount > 0
		ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)
	END
END

DROP TABLE #EMP_PF_REPORT --Nikunj

DROP TABLE #EMP_SALARY --Nikunj

RETURN
