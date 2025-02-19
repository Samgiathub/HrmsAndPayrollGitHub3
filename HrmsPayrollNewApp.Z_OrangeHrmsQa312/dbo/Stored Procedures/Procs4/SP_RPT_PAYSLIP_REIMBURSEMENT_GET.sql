---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_REIMBURSEMENT_GET] @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_ID NUMERIC
	,@Emp_ID NUMERIC
	,@constraint VARCHAR(max)
	,@Sal_Type NUMERIC = 0
	,@Salary_Cycle_id NUMERIC = 0
	,@Segment_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@Vertical_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@SubVertical_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@SubBranch_Id NUMERIC = 0 -- Added By Gadriwala Muslim 01082013	
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Branch_ID = 0
	SET @Branch_ID = NULL

IF @Cat_ID = 0
	SET @Cat_ID = NULL

IF @Grd_ID = 0
	SET @Grd_ID = NULL

IF @Type_ID = 0
	SET @Type_ID = NULL

IF @Dept_ID = 0
	SET @Dept_ID = NULL

IF @Desig_ID = 0
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL

IF @Segment_Id = 0
	SET @Segment_Id = NULL

IF @Vertical_Id = 0
	SET @Vertical_Id = NULL

IF @SubVertical_Id = 0
	SET @SubVertical_Id = NULL

IF @SubBranch_Id = 0
	SET @SubBranch_Id = NULL

--Added By Gadriwala Muslim on 24072013
IF @Segment_Id = 0
	SET @Segment_Id = NULL

IF @Vertical_Id = 0
	SET @Vertical_Id = NULL

IF @SubVertical_Id = 0
	SET @SubVertical_Id = NULL

IF @SubBranch_Id = 0 -- Added By Gadriwala Muslim 01082013
	SET @SubBranch_Id = NULL

DECLARE @With_Arear_Amount TINYINT

SET @With_Arear_Amount = 0

--Hardik 03/06/2013 for With Arear Report for Golcha Group
IF @Sal_Type = 3
BEGIN
	SET @With_Arear_Amount = 1
	SET @Sal_Type = 0
END

CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	(
	Emp_ID NUMERIC
	,Branch_ID NUMERIC
	,Increment_ID NUMERIC
	)

EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID
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
	,@Sal_Type
	,@Salary_Cycle_id
	,@Segment_Id
	,@Vertical_Id
	,@SubVertical_Id
	,@SubBranch_Id

--Declare #Emp_Cons Table        
--(        
-- Emp_ID numeric        
--)        
--if @Constraint <> ''        
-- begin
--  Insert Into #Emp_Cons        
--  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
-- end        
--else        
-- begin
--  Insert Into #Emp_Cons        
--  select I.Emp_Id from T0095_Increment I inner join         
--    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment        
--    where Increment_Effective_date <= @To_Date        
--    and Cmp_ID = @Cmp_ID        
--    group by emp_ID  ) Qry on        
--    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date         
--  Where Cmp_ID = @Cmp_ID         
--  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
--  and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
--  and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
--  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
--  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
--  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
--   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
--  and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
--  and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
--   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013     
--  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
--  and I.Emp_ID in         
--   ( select Emp_Id from        
--   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry        
--   where cmp_ID = @Cmp_ID   and          
--   (( @From_Date  >= join_Date  and  @From_Date <= left_date )         
--   or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
--   or Left_date is null and @To_Date >= Join_Date)        
--   or @To_Date >= left_date  and  @From_Date <= left_date )         
-- end        
DECLARE @Sal_St_Date DATETIME
DECLARE @Sal_end_Date DATETIME
DECLARE @manual_salary_Period AS NUMERIC(18, 0) -- Comment and added By rohit on 11022013 

IF @Branch_ID IS NULL
BEGIN
	SELECT TOP 1 @Sal_St_Date = Sal_st_Date
		,@manual_salary_Period = isnull(manual_salary_Period, 0) -- Comment and added By rohit on 11022013
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_ID = @cmp_ID
		AND For_Date = (
			SELECT max(For_Date)
			FROM T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE For_Date <= @From_Date
				AND Cmp_ID = @Cmp_ID
			)
END
ELSE
BEGIN
	SELECT @Sal_St_Date = Sal_st_Date
		,@manual_salary_Period = isnull(manual_salary_Period, 0) -- Comment and added By rohit on 11022013
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_ID = @cmp_ID
		AND Branch_ID = @Branch_ID
		AND For_Date = (
			SELECT max(For_Date)
			FROM T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE For_Date <= @From_Date
				AND Branch_ID = @Branch_ID
				AND Cmp_ID = @Cmp_ID
			)
END

IF @Salary_Cycle_id > 0
BEGIN
	SELECT @Sal_St_Date = Salary_st_date
	FROM T0040_Salary_Cycle_Master WITH (NOLOCK)
	WHERE Tran_Id = @Salary_Cycle_id
END

IF isnull(@Sal_St_Date, '') = ''
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
	-- Comment and added By rohit on 11022013
	--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	--set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	--set @From_Date = @Sal_St_Date
	--Set @To_Date = @Sal_end_Date   
	IF @manual_salary_Period = 0
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
		WHERE month = month(@From_Date)
			AND YEAR = year(@From_Date)

		SET @From_Date = @Sal_St_Date
		SET @To_Date = @Sal_End_Date
	END
			-- Ended By rohit on 11022013	
END

CREATE TABLE #Pay_slip (
	Emp_ID NUMERIC
	,Cmp_ID NUMERIC
	,AD_ID NUMERIC
	,Sal_Tran_ID NUMERIC
	,AD_Description VARCHAR(100)
	,AD_Amount NUMERIC(18, 2)
	,AD_Actual_Amount NUMERIC(18, 2)
	,AD_Calculated_Amount NUMERIC(18, 2)
	,For_Date DATETIME
	,M_AD_Flag CHAR(1)
	,Loan_Id NUMERIC
	,Def_ID NUMERIC
	,M_Arrear_Days NUMERIC
	,YTD NUMERIC(18, 2) --Ankit 10102013
	)

INSERT INTO #Pay_slip (
	Emp_ID
	,Cmp_ID
	,AD_ID
	,Sal_Tran_ID
	,AD_Amount
	,AD_ACtual_Amount
	,AD_Calculated_Amount
	,For_Date
	,M_AD_Flag
	,M_Arrear_Days
	)
SELECT mad.Emp_Id
	,mad.Cmp_ID
	,mad.AD_ID
	,MAD.Sal_Tran_ID
	,--null,  --change by Jaina 21-06-2017
	CASE 
		WHEN MAD.ReimAmount > 0
			THEN SUM(MAD.ReimAmount)
		ELSE sum(mad.m_AD_Amount)
		END AS m_AD_Amount
	,max(mad.M_AD_Actual_Per_amount)
	,sum(mad.M_AD_Calculated_amount)
	,mad.For_Date
	,mad.M_AD_Flag
	,sum(isnull(M_AREAR_AMOUNT, 0))
FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.Ad_ID
INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
WHERE MAD.Cmp_ID = @Cmp_Id
	AND For_date >= @From_Date
	AND For_date <= @To_Date
	AND ISNULL(M_AD_NOT_EFFECT_SALARY, 0) = 1
	AND ISNULL(Display_In_Salary, 0) = 1
	AND Sal_Tran_ID IS NOT NULL
	AND isnull(Sal_Type, 0) = isnull(0, Sal_Type)
GROUP BY Mad.Emp_ID
	,mad.AD_ID
	,mad.Cmp_ID
	,mad.For_Date
	,mad.M_AD_Flag
	,MAD.ReimAmount
	,MAD.Sal_Tran_ID

-- Changed By Ali 22112013  
SELECT ISNULL(EmpName_Alias_Salary, Emp_Full_Name) AS Emp_full_Name
	,Grd_Name
	,Comp_Name
	,Branch_Address
	,EMP_CODE
	,Type_Name
	,Dept_Name
	,Desig_Name
	,(
		AD_Name + ' (' + CASE 
			WHEN GA.AD_MODE = '%'
				THEN cast(AD_Actual_Amount AS NVARCHAR(20))
			ELSE ''
			END + isnull(GA.ad_mode, 'AMT') + ') '
		) AS AD_Name
	,ADM.AD_LEVEL
	,MAD.*
	,CASE 
		WHEN GA.ad_mode = '%'
			THEN EED.E_AD_Amount
		ELSE mad.AD_Actual_Amount
		END AS AD_Amount_on_basic_for_per
	,BM.Branch_ID
	,Alpha_Emp_Code
	,isnull((
			SELECT Reim_Closing
			FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_Id
				AND RC_ID = MAD.ad_ID
				AND Sal_tran_ID = MAD.Sal_Tran_ID
			), 0) Reim_Closing
	,Upper(DATENAME(MONTH, MAD.For_Date)) + '-' + convert(VARCHAR(5), YEAR(MAD.For_Date)) month_name
FROM #Pay_slip MAD
LEFT OUTER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON MAD.emp_ID = E.emp_ID
INNER JOIN #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID
INNER JOIN (
	SELECT I.Increment_ID
		,I.Emp_Id
		,Grd_ID
		,Branch_ID
		,Cat_ID
		,Desig_ID
		,Dept_ID
		,Type_ID
		,Increment_effective_Date
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) -- Ankit 06092014 for Same Date Increment       
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	) I_Q ON E.Emp_ID = I_Q.Emp_ID
INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
LEFT OUTER JOIN T0120_gradewise_allowance GA WITH (NOLOCK) ON I_Q.Grd_id = GA.Grd_ID
	AND ADM.ad_id = GA.Ad_ID
LEFT OUTER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON I_Q.Increment_ID = EED.INCREMENT_ID
	AND MAD.AD_ID = EED.AD_ID
	AND MAD.Emp_ID = EED.EMP_ID
INNER JOIN T0140_ReimClaim_Transacation rt ON rt.RC_ID = MAD.ad_ID
	AND rt.Sal_tran_ID = MAD.Sal_Tran_ID
	AND rt.Cmp_ID = @Cmp_ID --added by mansi 30-09-23  
WHERE E.Cmp_ID = @Cmp_Id
	AND MAD.For_date >= @From_Date
	AND MAD.For_date <= @To_Date
	AND (
		MAD.AD_Amount > 0
		OR MAD.AD_Amount < 0
		)
	AND MAD.AD_ID IN (
		SELECT AD_ID
		FROM T0050_AD_MASTER WITH (NOLOCK)
		WHERE CMP_ID = @Cmp_Id
			AND isnull(AD_NOT_EFFECT_SALARY, 0) = 1
			AND Allowance_Type = 'R'
		)
ORDER BY Ad_name ASC

RETURN
