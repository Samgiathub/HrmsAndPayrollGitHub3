---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET] @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_ID NUMERIC
	,@Emp_ID NUMERIC
	,@constraint VARCHAR(MAX)
	,@Sal_Type NUMERIC = 0
	,@Salary_Cycle_id NUMERIC = 0
	,@Segment_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@Vertical_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@SubVertical_Id NUMERIC = 0 -- Added By Gadriwala Muslim 24072013
	,@SubBranch_Id NUMERIC = 0 -- Added By Gadriwala Muslim 01082013	
	,@Status VARCHAR(20) = '' -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)
	,@mobile_view VARCHAR(100) = '' -- Added by prakash for mobile salary view on 28052016
	,@Bank_ID VARCHAR(20) = '' --Added by ronakk 20082022
	,@Payment_mode VARCHAR(20) = '' --Added by ronakk 20082022
	,@Salary_Status VARCHAR(100) = '' --Added by ronakk 20102022
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

SET @With_Arear_Amount = 1

DECLARE @SAL_TYPE_OLD AS NUMERIC

SET @SAL_TYPE_OLD = @SAL_TYPE

--Hardik 03/06/2013 for With Arear Report for Golcha Group
IF @Sal_Type = 3
	OR @Sal_Type = 0
BEGIN
	SET @With_Arear_Amount = 1
	SET @Sal_Type = 0
END

--added by jimit 14022017----
IF @SAL_TYPE = 5
BEGIN
	SET @SAL_TYPE = 0
END

----------ended------------
CREATE TABLE #Emp_Cons (
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

--Added by Nimesh 19 May 2015
--Filtering Employee Record according to Salary Status
IF (
		@Status = 'Hold'
		OR @Status = 'Done'
		)
BEGIN
	DELETE
	FROM #Emp_Cons
	WHERE Emp_ID NOT IN (
			SELECT Emp_ID
			FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
			WHERE Month(S.Month_End_Date) = Month(@To_Date)
				AND Year(S.Month_End_Date) = Year(@To_Date)
				AND S.Cmp_ID = @Cmp_ID
				AND S.Salary_Status = @Status
			)
END

--if @Constraint <> ''
--	begin
--		Insert Into #Emp_Cons
--		Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
--	end
--else 
--	Begin
--		Insert Into #Emp_Cons      
--		  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
--		  cmp_id=@Cmp_ID 
--		   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013       
--	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
--		  and Increment_Effective_Date <= @To_Date 
--		  and 
--				  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
--					or (Left_date is null and @To_Date >= Join_Date)      
--					or (@To_Date >= left_date  and  @From_Date <= left_date )) 
--					order by Emp_ID
--			Delete From #Emp_Cons Where Increment_ID Not In
--			(select TI.Increment_ID from t0095_increment TI inner join
--			(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
--			Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
--			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
--			Where Increment_effective_Date <= @to_date) 
--	End	
--Declare #Emp_Cons Table        
--(          -- Emp_ID numeric        
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
DECLARE @IS_ROUNDING AS NUMERIC(1, 0)
DECLARE @Round NUMERIC

SET @Round = 0

DECLARE @manual_salary_Period AS NUMERIC(18, 0) -- Comment and added By rohit on 11022013 
DECLARE @Show_PT_in_Payslip_if_Zero AS INT --added by Krushna 28-05-2018 for EcoGreen
DECLARE @Show_LWF_in_Payslip_if_Zero AS INT --added by Krushna 28-05-2018 for EcoGreen

IF @Branch_ID IS NULL
BEGIN
	SELECT TOP 1 @Sal_St_Date = Sal_st_Date
		,@manual_salary_Period = isnull(manual_salary_Period, 0)
		,@IS_ROUNDING = Isnull(AD_Rounding, 1) -- Comment and added By rohit on 11022013
		,@Show_PT_in_Payslip_if_Zero = Show_PT_in_Payslip_if_Zero -- added by krushna 28-05-2018
		,@Show_LWF_in_Payslip_if_Zero = Show_LWF_in_Payslip_if_Zero -- added by krushna 28-05-2018
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
		,@manual_salary_Period = isnull(manual_salary_Period, 0)
		,@IS_ROUNDING = Isnull(AD_Rounding, 1) -- Comment and added By rohit on 11022013
		,@Show_PT_in_Payslip_if_Zero = Show_PT_in_Payslip_if_Zero -- added by krushna 28-05-2018
		,@Show_LWF_in_Payslip_if_Zero = Show_LWF_in_Payslip_if_Zero -- added by krushna 28-05-2018
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
	AND DAY(@From_Date) = 1
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
	,AD_Description VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,AD_Amount NUMERIC(18, 2)
	,AD_Actual_Amount NUMERIC(18, 5)
	,AD_Calculated_Amount NUMERIC(18, 2)
	,For_Date DATETIME
	,M_AD_Flag CHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,Loan_Id NUMERIC
	,Def_ID NUMERIC
	,M_Arrear_Days NUMERIC(18, 2) DEFAULT 0
	,YTD NUMERIC(18, 2)
	,--Ankit 10102013
	S_Sal_Tran_ID NUMERIC NULL --Added By Ankit For Twise Settlement	--05122015
	,Gujarati_Alias NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)

IF @Sal_Type = 3
	SET @Sal_Type = NULL

--Ankit 10102013--YTD Column Get Finacial Year Date--- 
DECLARE @F_StartDate DATETIME
DECLARE @F_EndDate DATETIME

SET @F_StartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, DATEADD(mm, - (((12 + DATEPART(m, @To_Date)) - 4) % 12), @To_Date) - datePart(d, DATEADD(mm, - (((12 + DATEPART(m, @To_Date)) - 4) % 12), @To_Date)) + 1))

IF day(@Sal_St_Date) <> 1
BEGIN
	SET @F_StartDate = cast(cast(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + cast(datename(mm, dateadd(m, - 1, @F_StartDate)) AS VARCHAR(10)) + '-' + cast(year(dateadd(m, - 1, @F_StartDate)) AS VARCHAR(10)) AS SMALLDATETIME)
END

SET @F_EndDate = DATEADD(SS, - 1, DATEADD(mm, 12, @F_StartDate))

--Ankit 10102013--YTD Column Get Finacial Year Date--- 
IF @Sal_Type = 1
BEGIN
	PRINT 11 --mansi

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
		,S_Sal_Tran_ID
		)
	SELECT mad.Emp_Id
		,mad.Cmp_ID
		,mad.AD_ID
		,NULL
		,sum(mad.m_AD_Amount)
		,sum(mad.M_AD_Actual_Per_amount)
		,sum(mad.M_AD_Calculated_amount)
		,mad.To_Date
		,mad.M_AD_Flag
		,sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))
		,S_Sal_Tran_ID
	FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
	WHERE MAD.Cmp_ID = @Cmp_Id
		AND Month(To_Date) = Month(@To_Date)
		AND Year(To_Date) = Year(@To_Date)
		AND M_AD_NOT_EFFECT_SALARY = 0
		AND isnull(Sal_Type, 0) IN (
			1
			,2
			)
		AND M_AD_Percentage >= 0
	GROUP BY Mad.Emp_ID
		,mad.AD_ID
		,mad.Cmp_ID
		,mad.To_Date
		,mad.M_AD_Flag
		,MAD.S_Sal_Tran_ID

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
		,S_Sal_Tran_ID
		)
	SELECT mad.Emp_Id
		,mad.Cmp_ID
		,mad.AD_ID
		,mad.Sal_Tran_ID
		,sum(mad.ReimAmount)
		,sum(mad.M_AD_Actual_Per_amount)
		,sum(mad.M_AD_Calculated_amount)
		,mad.to_Date
		,mad.M_AD_Flag
		,0
		,S_Sal_Tran_ID
	FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
	WHERE MAD.Cmp_ID = @Cmp_Id
		AND Month(To_Date) = Month(@To_Date)
		AND Year(To_Date) = Year(@To_Date)
		AND (
			M_AD_NOT_EFFECT_SALARY = 1
			AND MAD.reimShow = 1
			)
		AND Sal_Tran_ID IS NOT NULL
		AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0        
	GROUP BY Mad.Emp_ID
		,mad.AD_ID
		,mad.Cmp_ID
		,mad.To_Date
		,mad.M_AD_Flag
		,mad.Sal_Tran_ID
		,MAD.S_Sal_Tran_ID

	-------COMMENT BY NILAY: 21082014------                
	--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	--Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0)) +sum(isnull(M_AREAR_AMOUNT_cutoff,0))          
	--  From T0210_MONTHLY_AD_DETAIL  MAD INNER  JOIN         
	--  #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
	-- WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date          
	--    and M_AD_NOT_EFFECT_SALARY = 0          
	--    and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0        
	-- Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag        
	-------COMMENT BY NILAY: 21082014------                  
	---YTD Column-- Ankit 10102013---
	UPDATE #Pay_slip
	SET YTD = M_AD_Amount + Qry.M_Arrear_Days
	FROM (
		SELECT Ad_Id
			,Mad.Emp_ID
			,sum(mad.m_AD_Amount) AS M_AD_Amount
			,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND MAD.For_Date >= @F_StartDate
			AND MAD.To_Date <= @To_Date
			AND M_AD_NOT_EFFECT_SALARY = 0
			AND isnull(Sal_Type, 0) IN (
				1
				,2
				)
			AND M_AD_Percentage = 0
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
		AND Qry.AD_ID = p.AD_ID

	UPDATE #Pay_slip
	SET YTD = M_AD_Amount + Qry.M_Arrear_Days
	FROM (
		SELECT Ad_Id
			,Mad.Emp_ID
			,sum(mad.m_AD_Amount) AS M_AD_Amount
			,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND MAD.For_Date >= @F_StartDate
			AND MAD.To_Date <= @To_Date
			AND M_AD_NOT_EFFECT_SALARY = 0
			AND isnull(Sal_Type, 0) IN (
				1
				,2
				)
			AND M_AD_Percentage > 0
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
		AND Qry.AD_ID = p.AD_ID

		

	UPDATE #Pay_slip
	SET YTD = M_AD_Amount + Qry.M_Arrear_Days
	FROM ----YTD For Reimbersment Allowance
		(
		SELECT Ad_Id
			,Mad.Emp_ID
			,sum(mad.ReimAmount) AS M_AD_Amount
			,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND MAD.For_Date >= @F_StartDate
			AND MAD.To_Date <= @To_Date
			AND M_AD_NOT_EFFECT_SALARY = 1
			AND MAD.reimShow = 1
			AND Sal_Tran_ID IS NOT NULL
			AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type)
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
		AND Qry.AD_ID = p.AD_ID
		---YTD Column-- Ankit 10102013---
END
ELSE
BEGIN
	IF @With_Arear_Amount = 0
	BEGIN
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
			,mad.Sal_Tran_ID
			,sum(mad.m_AD_Amount)
			,sum(mad.M_AD_Actual_Per_amount)
			,sum(mad.M_AD_Calculated_amount)
			,mad.To_Date
			,mad.M_AD_Flag
			,sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0)) --,S_Sal_Tran_ID               
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND Month(To_Date) = Month(@To_Date)
			AND Year(To_Date) = Year(@To_Date)
			AND M_AD_NOT_EFFECT_SALARY = 0
			AND Sal_Tran_ID IS NOT NULL
			AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0        
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
			,mad.Cmp_ID
			,mad.To_Date
			,mad.M_AD_Flag
			,mad.Sal_Tran_ID

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
			,mad.Sal_Tran_ID
			,sum(mad.ReimAmount)
			,sum(mad.M_AD_Actual_Per_amount)
			,sum(mad.M_AD_Calculated_amount)
			,mad.To_date
			,mad.M_AD_Flag
			,sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0)) -- ,S_Sal_Tran_ID       
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND Month(To_Date) = Month(@To_Date)
			AND Year(To_Date) = Year(@To_Date)
			AND (
				M_AD_NOT_EFFECT_SALARY = 1
				AND MAD.reimShow = 1
				)
			AND Sal_Tran_ID IS NOT NULL
			AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0        
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
			,mad.Cmp_ID
			,mad.to_Date
			,mad.M_AD_Flag
			,mad.Sal_Tran_ID

		--Added by Nimesh 19 May, 2015
		--If the option is disabled from the Admin Settings "Show Reimbursment Amount in Payslip" then 
		--Reimbursment allowance should not be displayed.
		DECLARE @ReimbOption INT = 0;

		SELECT @ReimbOption = Setting_Value
		FROM T0040_SETTING WITH (NOLOCK)
		WHERE Setting_Name = 'Show Reimbursement Amount in Salary Slip'
			AND Group_By = 'Reports'
			AND Cmp_ID = @Cmp_ID;

		IF (@ReimbOption > 0)
		BEGIN
			--Inserting Reimbursement records which is not claimed and not marked as AutoPaid
			INSERT INTO #PAY_SLIP (
				Emp_ID
				,Cmp_ID
				,ADM.AD_ID
				,Sal_Tran_ID
				,AD_Amount
				,AD_ACtual_Amount
				,AD_Calculated_Amount
				,For_Date
				,M_AD_Flag
				,M_Arrear_Days
				)
			SELECT EED.EMP_ID
				,EED.Cmp_ID
				,EED.AD_ID
				,MAD.Sal_Tran_ID
				,MAD.ReimAmount
				,SUM(MAD.M_AD_Actual_Per_Amount) AS AD_Amount_Actual
				,SUM(MAD.M_AD_Calculated_Amount) AS AD_Amount_Calculated
				,MAD.For_Date
				,EED.E_AD_FLAG
				,0
			FROM (
				T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.CMP_ID = AD.CMP_ID
					AND EED.AD_ID = AD.AD_ID
				)
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EED.Emp_ID
				AND EED.INCREMENT_ID = E.Increment_ID --Added By Ramiz on 05/05/2016
			LEFT OUTER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EED.Cmp_ID = MAD.Cmp_ID
				AND EED.AD_ID = MAD.AD_ID
				AND EED.EMP_ID = MAD.Emp_ID
			WHERE EED.CMP_ID = @Cmp_ID
				AND EED.E_AD_AMOUNT <> 0
				AND AD.Auto_Paid <> 1
				AND AD.Allowance_Type = 'R'
				AND EED.AD_ID NOT IN (
					SELECT AD_ID
					FROM #PAY_SLIP P
					WHERE P.Emp_ID = EED.Emp_ID
					)
			GROUP BY EED.EMP_ID
				,EED.Cmp_ID
				,EED.AD_ID
				,MAD.Sal_Tran_ID
				,MAD.For_Date
				,EED.E_AD_FLAG
				,MAD.ReimAmount

			--Inserting Reimbursement records which is not claimed and marked as AutoPaid but not monthly.
			INSERT INTO #PAY_SLIP (
				Emp_ID
				,Cmp_ID
				,ADM.AD_ID
				,Sal_Tran_ID
				,AD_Amount
				,AD_ACtual_Amount
				,AD_Calculated_Amount
				,For_Date
				,M_AD_Flag
				,M_Arrear_Days
				)
			SELECT EED.EMP_ID
				,EED.Cmp_ID
				,EED.AD_ID
				,MAD.Sal_Tran_ID
				,MAD.ReimAmount
				,SUM(MAD.M_AD_Actual_Per_Amount) AS AD_Amount_Actual
				,SUM(MAD.M_AD_Calculated_Amount) AS AD_Amount_Calculated
				,MAD.For_Date
				,EED.E_AD_FLAG
				,0
			FROM (
				T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.CMP_ID = AD.CMP_ID
					AND EED.AD_ID = AD.AD_ID
				)
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EED.Emp_ID
				AND EED.INCREMENT_ID = E.Increment_ID --Added By Ramiz on 05/05/2016
			LEFT OUTER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EED.Cmp_ID = MAD.Cmp_ID
				AND EED.AD_ID = MAD.AD_ID
				AND EED.EMP_ID = MAD.Emp_ID
			WHERE EED.CMP_ID = @Cmp_ID
				AND EED.E_AD_AMOUNT <> 0
				AND (
					AD.Auto_Paid = 1
					AND IsNull(AD.AD_CAL_TYPE, 'Monthly') <> 'Monthly'
					)
				AND AD.Allowance_Type = 'R'
				AND EED.AD_ID NOT IN (
					SELECT AD_ID
					FROM #PAY_SLIP P
					WHERE P.Emp_ID = EED.Emp_ID
					)
			GROUP BY EED.EMP_ID
				,EED.Cmp_ID
				,EED.AD_ID
				,MAD.Sal_Tran_ID
				,MAD.For_Date
				,EED.E_AD_FLAG
				,MAD.ReimAmount
		END
		
		---YTD Column-- Ankit 10102013---
		UPDATE #Pay_slip
		SET YTD = M_AD_Amount + Qry.M_Arrear_Days
		FROM (
			SELECT Ad_Id
				,Mad.Emp_ID
				,sum(mad.m_AD_Amount) AS M_AD_Amount
				,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
			FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id
				AND MAD.For_Date >= @F_StartDate
				AND MAD.To_Date <= @To_Date
				AND M_AD_NOT_EFFECT_SALARY = 0
				AND MAD.Sal_Tran_ID IS NOT NULL
				AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0         
			GROUP BY Mad.Emp_ID
				,mad.AD_ID
			) Qry
		INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
			AND Qry.AD_ID = p.AD_ID

		UPDATE #Pay_slip
		SET YTD = M_AD_Amount + Qry.M_Arrear_Days
		FROM ----YTD For Reimbersment Allowance
			(
			SELECT Ad_Id
				,Mad.Emp_ID
				,sum(mad.ReimAmount) AS M_AD_Amount
				,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
			FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id
				AND MAD.For_Date >= @F_StartDate
				AND MAD.To_Date <= @To_Date
				AND M_AD_NOT_EFFECT_SALARY = 1
				AND MAD.reimShow = 1
				AND Sal_Tran_ID IS NOT NULL
				AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type)
			GROUP BY Mad.Emp_ID
				,mad.AD_ID
			) Qry
		INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
			AND Qry.AD_ID = p.AD_ID
	END
	ELSE
	BEGIN
		--print 22--mansi	
		--select * from #Pay_slip
		
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
			,mad.Sal_Tran_ID
			,sum(mad.m_AD_Amount)
			,sum(mad.M_AD_Actual_Per_amount)
			,sum(mad.M_AD_Calculated_amount)
			,mad.to_Date
			,mad.M_AD_Flag
			,sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND Month(To_Date) = Month(@To_Date)
			AND Year(To_Date) = Year(@To_Date)
			AND M_AD_NOT_EFFECT_SALARY = 0
			AND Sal_Tran_ID IS NOT NULL
			AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0        
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
			,mad.Cmp_ID
			,mad.to_Date
			,mad.M_AD_Flag
			,mad.Sal_Tran_ID

			
		-----Settlement Arear AMount display in Arear Column in Pay slip - AIA --Ankit 03062016
		--select * from #Pay_slip
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
			,mad.Sal_Tran_ID
			,sum(mad.ReimAmount)
			,sum(mad.M_AD_Actual_Per_amount)
			,sum(mad.M_AD_Calculated_amount)
			,mad.To_date
			,mad.M_AD_Flag
			,sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0)) -- ,S_Sal_Tran_ID       
		FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND Month(To_Date) = Month(@To_Date)
			AND Year(To_Date) = Year(@To_Date)
			AND (
				M_AD_NOT_EFFECT_SALARY = 1
				AND MAD.reimShow = 1
				)
			AND Sal_Tran_ID IS NOT NULL
			AND isnull(Sal_Type, 0) = isnull(@Sal_Type, Sal_Type) --and M_AD_Percentage =0        
		GROUP BY Mad.Emp_ID
			,mad.AD_ID
			,mad.Cmp_ID
			,mad.to_Date
			,mad.M_AD_Flag
			,mad.Sal_Tran_ID

			
		
		---YTD Column-- Ankit 10102013---
		UPDATE #Pay_slip
		SET YTD = M_AD_Amount + Qry.M_Arrear_Days
		FROM (
			SELECT Ad_Id
				,Mad.Emp_ID
				,sum(mad.m_AD_Amount) AS M_AD_Amount
				,(sum(isnull(M_AREAR_AMOUNT, 0)) + sum(isnull(M_AREAR_AMOUNT_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
			FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id
				AND MAD.For_Date >= @F_StartDate
				AND MAD.To_Date <= @To_Date
				AND M_AD_NOT_EFFECT_SALARY = 0
				AND MAD.Sal_Tran_ID IS NOT NULL
			--and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0    -- Comment by nilesh patel on 11072017 after discussion with Hardik bhai Settelment Amount is not calculate in YTD Other Month      
			GROUP BY Mad.Emp_ID
				,mad.AD_ID
			) Qry
		INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
			AND Qry.AD_ID = p.AD_ID

		----  Update #Pay_slip Set YTD = M_AD_Amount From
		---- (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
		----	From T0210_MONTHLY_AD_DETAIL  MAD INNER JOIN
		----	#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		----WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
		----   and M_AD_NOT_EFFECT_SALARY = 0 and MAD.Sal_Tran_ID is not null  
		----   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage >0         
		----Group by Mad.Emp_ID,mad.AD_ID) Qry
		----Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
		---YTD Column-- Ankit 10102013---
		DECLARE @AD_Id AS NUMERIC
		DECLARE @M_AD_Amount_Arear AS NUMERIC(18, 2)
		DECLARE @S_Emp_Id AS NUMERIC

		SET @M_AD_Amount_Arear = 0

		DECLARE Cur_Payslip CURSOR
		FOR
		SELECT Emp_ID
		FROM #Pay_slip
		GROUP BY Emp_ID

		OPEN Cur_Payslip

		FETCH NEXT
		FROM Cur_Payslip
		INTO @S_Emp_Id

		WHILE @@fetch_status = 0
		BEGIN
			DECLARE Cur_Allow CURSOR
			FOR
			SELECT MAD.AD_ID
				,Isnull(SUM(M_AD_Amount), 0)
			FROM t0210_monthly_ad_detail MAD WITH (NOLOCK)
			INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) ON MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID
			INNER JOIN -- Added by Nilesh Patel on 11-08-2017 For Salary Settelment ID 
				--MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join Comment by nilesh patel on 11-08-2017 For get issue when Same month Settelment in twice
				T0050_AD_MASTER WITH (NOLOCK) ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
				AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
				AND MAD.Emp_ID = @S_Emp_Id
			WHERE MAD.Cmp_ID = @Cmp_ID
				AND month(MSS.S_Eff_Date) = MONTH(@To_Date)
				AND Year(MSS.S_Eff_Date) = YEAR(@To_Date)
				AND (
					isnull(mad.M_AD_NOT_EFFECT_SALARY, 0) = 0
					OR (
						M_AD_NOT_EFFECT_SALARY = 1
						AND MAD.reimShow = 1
						)
					)
				AND Ad_Active = 1
				--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  03062016
				AND Sal_Type = 1
				AND Isnull(MSS.Effect_On_Salary, 0) = 1 --Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
			GROUP BY MAD.AD_ID
				,MSS.Emp_ID

			OPEN cur_allow

			FETCH NEXT
			FROM cur_allow
			INTO @AD_ID
				,@M_AD_Amount_Arear

			--select * from #Pay_slip--mansi
			WHILE @@fetch_status = 0
			BEGIN
				IF @With_Arear_Amount = 0 -- Ankit 17072016 [Add Condition due to if settlement amount then actual earning amount display wrong in report :Cera client 13072016]
				BEGIN
					--If exists (Select 1 From #Pay_slip Where Emp_ID = @S_Emp_Id And AD_ID = @AD_Id)
					BEGIN
						PRINT 1

						UPDATE #Pay_slip
						SET AD_Amount = AD_Amount + ISNULL(@M_AD_Amount_Arear, 0)
						WHERE Emp_ID = @S_Emp_Id
							AND Cmp_ID = @Cmp_ID
							AND AD_ID = @AD_Id
					END
						--Else
						--	Begin
						--	   Insert into #Pay_slip 
						--		(Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
						--		Select @S_Emp_Id, @Cmp_ID,@AD_Id,0,@M_AD_Amount_Arear,0,0,@From_Date,'D',0
						--	End	
				END
				ELSE IF @With_Arear_Amount = 1 -- added by Ankit 03062016
				BEGIN
					PRINT 2

					--print @M_AD_Amount_Arear
					UPDATE #Pay_slip
					SET M_Arrear_Days = ISNULL(M_Arrear_Days, 0) + ISNULL(@M_AD_Amount_Arear, 0)
						,AD_Amount = AD_Amount
					WHERE Emp_ID = @S_Emp_Id
						AND Cmp_ID = @Cmp_ID
						AND AD_ID = @AD_Id
				END

				FETCH NEXT
				FROM cur_allow
				INTO @AD_ID
					,@M_AD_Amount_Arear
			END

			CLOSE cur_Allow

			DEALLOCATE Cur_Allow

			FETCH NEXT
			FROM Cur_Payslip
			INTO @S_Emp_Id
		END

		CLOSE Cur_Payslip

		DEALLOCATE Cur_Payslip
	END
			--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
			--Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))             
			--  From T0210_MONTHLY_AD_DETAIL  MAD INNER  JOIN         
			--  #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			-- WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date          
			--    and M_AD_NOT_EFFECT_SALARY = 0          and Sal_Tran_ID is not null  
			--    and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage >0         
			-- Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag ,mad.Sal_Tran_ID  
END

IF @Sal_Type = 0
BEGIN
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Basic Salary'
		,Sal_Tran_ID
		,Salary_amount
		,Basic_Salary
		,0
		,Month_end_Date
		,'I'
		,ms.Arear_Basic + ms.basic_salary_arear_cutoff
		,N'Basic Salary' --Changed by ronakk 28042022          
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)
		AND Is_FNF = 0

	--select * from #Pay_slip
	IF @With_Arear_Amount = 1 --Ankit 03062016
	BEGIN
		UPDATE #Pay_Slip
		SET M_Arrear_Days = ISNULL(M_Arrear_Days, 0) + ISNULL(Qry.S_Salary_Amount, 0)
		FROM #Pay_Slip P
		INNER JOIN (
			SELECT ms.Emp_ID
				,SUM(ms.S_Salary_Amount) AS S_Salary_Amount
				,S_Eff_Date
			FROM T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK)
			INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
				AND MONTH(S_Eff_Date) = MONTH(@To_Date)
				AND YEAR(S_Eff_Date) = YEAR(@To_Date)
				AND MS.Emp_ID IN (
					SELECT ms.Emp_ID
					FROM T0200_Monthly_Salary ms WITH (NOLOCK)
					INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
						AND MONTH(Month_End_Date) = MONTH(@To_Date)
						AND YEAR(Month_End_Date) = YEAR(@To_Date)
					)
				AND Isnull(ms.Effect_On_Salary, 0) = 1 --Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
			GROUP BY ms.Emp_ID
				,S_Eff_Date
			) Qry ON Qry.Emp_ID = p.Emp_ID
		WHERE P.Cmp_ID = @Cmp_ID
			AND AD_Description = 'Basic Salary'
	END

	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
	----Hasmukh  15102013------
	UPDATE #Pay_Slip
	SET AD_Actual_Amount = MSY.Day_Salary
	FROM dbo.T0200_MONTHLY_SALARY MSY
	INNER JOIN dbo.T0095_Increment I ON MSY.increment_id = i.Increment_ID
	--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	INNER JOIN #Pay_Slip P ON I.Emp_Id = MSY.Emp_Id
		AND P.Sal_Tran_ID = MSY.Sal_Tran_ID --Ankit 11092014
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'
		AND i.Wages_Type = 'Daily'
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date) --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date  -- Added by rohit on 18102014 for Day Rate Showing Wrong daily Wages Employee
		-------Hasmukh 15102013--------

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Claim Amount'
		,Sal_Tran_ID
		,Total_claim_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'I'
		,N'???? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date) --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        

	----------Added by Sumit 18082015-----------------------------------------------------------------------------------------
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Travel Amount'
		,Sal_Tran_ID
		,replace(Travel_Amount, '-', '')
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'I'
		,0
		,N'?????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Travel Advance Amount'
		,Sal_Tran_ID
		,replace(travel_Advance_Amount, '-', '')
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,0
		,N'?????? ??????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID

	-- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
	-----------Ended by Sumit 18082015----------------------------------- 
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'OT Amount'
		,Sal_Tran_ID
		,OT_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'I'
		,0
		,N'???? ????'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date) --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        

	-- UnCommented by Falak on 12-MAY-2011        
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Arrears'
		,Sal_Tran_ID
		,Other_Allow_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
		,N'?????'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)
		AND isnull(Other_Allow_Amount, 0) > 0 --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0        

	IF @With_Arear_Amount = 0
	BEGIN
		INSERT INTO #Pay_slip (
			Emp_ID
			,Cmp_ID
			,AD_ID
			,AD_Description
			,Sal_Tran_ID
			,AD_Amount
			,AD_ACtual_Amount
			,AD_Calculated_Amount
			,For_Date
			,M_AD_Flag
			,M_Arrear_Days
			,Gujarati_Alias
			)
		SELECT ms.Emp_ID
			,Cmp_ID
			,NULL
			,'Arrear Amount'
			,Sal_Tran_ID
			,Settelement_Amount
			,NULL
			,0
			,Month_end_Date
			,'I'
			,0
			,N'?????? ???'
		FROM T0200_Monthly_Salary ms WITH (NOLOCK)
		INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
			AND Month(Month_End_Date) = Month(@To_Date)
			AND Year(Month_End_Date) = Year(@To_Date) -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date --and isnull(Settelement_Amount,0) >0        
	END

	--Else	--Comment b'cos Settlement allowance amount display head wise - AIA --Ankit 03062016
	--	Begin
	--		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	--		select  ms.Emp_ID,MS.Cmp_ID,null,'Arrear Gross Amount',0,SUM(S_Gross_Salary),null,0,S_Eff_Date ,'I',0        
	--		 From T0201_MONTHLY_SALARY_SETT ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	--		 and  Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)	-- S_Eff_Date >=@From_Date and S_Eff_Date <=@To_Date 
	--		 And MS.Emp_ID In 
	--			(select  ms.Emp_ID
	--			From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	--			and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date))
	--		 Group by ms.Emp_ID,MS.Cmp_ID,S_Eff_Date
	--	End      
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Leave Encash Amount'
		,Sal_Tran_ID
		,Leave_salary_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
		,0
		,N'??????????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)
		AND isnull(Leave_Salary_Amount, 0) > 0

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Advance Amount'
		,Sal_Tran_ID
		,Advance_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'??????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	--added By Mukti(start)25032015
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Asset Installment Amount'
		,Sal_Tran_ID
		,Asset_Installment
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'???? ???? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date)

	--added By Mukti(end)25032015 
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Loan Amount'
		,Sal_Tran_ID
		,Loan_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'??? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Loan Interest'
		,Sal_Tran_ID
		,Loan_Intrest_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'??? ?????'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Bonus'
		,Sal_Tran_ID
		,Bonus_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
		,0
		,N'????'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)
		AND isnull(Bonus_Amount, 0) > 0

	--commented by Falak on 29-OCT-2010 as per told by nilay 
	/*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Professional tax'
		,Sal_Tran_ID
		,PT_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'?????????? ??'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'LWF Amount'
		,Sal_Tran_ID
		,LWF_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'???? ?????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Revenue Amount'
		,Sal_Tran_ID
		,Revenue_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'?????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Other Dedu'
		,Sal_Tran_ID
		,Other_Dedu_Amount
		,Other_Dedu_Amount
		,0
		,Month_end_Date
		,'D'
		,N'???? ????'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Extra Absent Amount'
		,Sal_Tran_ID
		,Extra_AB_Amount
		,Extra_AB_Amount
		,0
		,Month_end_Date
		,'D'
		,N'????? ??????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Deficit Dedu Amount'
		,Sal_Tran_ID
		,Deficit_Dedu_Amount
		,Deficit_Dedu_Amount
		,0
		,Month_end_Date
		,'D'
		,N'??????? ???? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	--added By Mukti(start)23052017
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Uniform Installment Amount'
		,Sal_Tran_ID
		,Uniform_Dedu_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'????????? ???? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date)

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Uniform Refund Amount'
		,Sal_Tran_ID
		,Uniform_Refund_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'I'
		,N'????????? ????? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date)

	--added By Mukti(end)23052017
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Late Deduction Amt'
		,Sal_Tran_ID
		,ms.Late_Dedu_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'??? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	-- ADDED BY RAJPUT FOR BOND DEDUCTION AMOUNT IN SALARY AS DEDUCTION PART ON 10102018 --
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Gujarati_Alias
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Bond Amount'
		,Sal_Tran_ID
		,Bond_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
		,N'??? ???'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_End_Date) = Month(@To_Date)
		AND Year(Month_End_Date) = Year(@To_Date)

	-- END --
	----Added by Gadriwala Muslim 06012015- Start
	--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
	--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(GatePass_Amount,0) > 0  
	----Added by Gadriwala Muslim 06012015- End 
	--Added by Mihir Trivedi on 16/08/2012--------
	--  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
	--			select  ms.Emp_ID,Cmp_ID,null,'Week Off Working',Sal_Tran_ID,M_WO_OT_Amount,M_WO_OT_Amount,0,Month_end_Date ,'I',0
	--				From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	--				and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(M_WO_OT_Amount,0) >0
	--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
	--			select  ms.Emp_ID,Cmp_ID,null,'Holiday Working',Sal_Tran_ID,M_HO_OT_Amount,M_HO_OT_Amount,0,Month_end_Date ,'I',0
	--				From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	--				and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(M_HO_OT_Amount,0) >0
	--End of Added by Mihir Trivedi on 16/08/2012--------  
	--added by jimit 14022017
	IF @SAL_TYPE_OLD = 5
	BEGIN
		INSERT INTO #Pay_slip (
			Emp_ID
			,Cmp_ID
			,AD_ID
			,AD_Description
			,Sal_Tran_ID
			,AD_Amount
			,AD_ACtual_Amount
			,AD_Calculated_Amount
			,For_Date
			,M_AD_Flag
			,M_Arrear_Days
			,Gujarati_Alias
			)
		SELECT ms.Emp_ID
			,Cmp_ID
			,NULL
			,'Week Off Working'
			,Sal_Tran_ID
			,M_WO_OT_Amount
			,M_WO_OT_Amount
			,0
			,Month_end_Date
			,'I'
			,0
			,N'?????? ??? ???'
		FROM T0200_Monthly_Salary ms WITH (NOLOCK)
		INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
			AND Month(Month_End_Date) = Month(@To_Date)
			AND Year(Month_End_Date) = Year(@To_Date) --and isnull(M_WO_OT_Amount,0) >0

		INSERT INTO #Pay_slip (
			Emp_ID
			,Cmp_ID
			,AD_ID
			,AD_Description
			,Sal_Tran_ID
			,AD_Amount
			,AD_ACtual_Amount
			,AD_Calculated_Amount
			,For_Date
			,M_AD_Flag
			,M_Arrear_Days
			,Gujarati_Alias
			)
		SELECT ms.Emp_ID
			,Cmp_ID
			,NULL
			,'Holiday Working'
			,Sal_Tran_ID
			,M_HO_OT_Amount
			,M_HO_OT_Amount
			,0
			,Month_end_Date
			,'I'
			,0
			,N'?????? ???'
		FROM T0200_Monthly_Salary ms WITH (NOLOCK)
		INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
			AND Month(Month_End_Date) = Month(@To_Date)
			AND Year(Month_End_Date) = Year(@To_Date) --and isnull(M_HO_OT_Amount,0) >0
	END
	ELSE
	BEGIN
		INSERT INTO #Pay_slip (
			Emp_ID
			,Cmp_ID
			,AD_ID
			,AD_Description
			,Sal_Tran_ID
			,AD_Amount
			,AD_ACtual_Amount
			,AD_Calculated_Amount
			,For_Date
			,M_AD_Flag
			,M_Arrear_Days
			,Gujarati_Alias
			)
		SELECT ms.Emp_ID
			,Cmp_ID
			,NULL
			,'Week Off Working'
			,Sal_Tran_ID
			,M_WO_OT_Amount
			,M_WO_OT_Amount
			,0
			,Month_end_Date
			,'I'
			,0
			,N'?????? ??? ???'
		FROM T0200_Monthly_Salary ms WITH (NOLOCK)
		INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
			AND Month(Month_End_Date) = Month(@To_Date)
			AND Year(Month_End_Date) = Year(@To_Date)
			AND isnull(M_WO_OT_Amount, 0) > 0

		INSERT INTO #Pay_slip (
			Emp_ID
			,Cmp_ID
			,AD_ID
			,AD_Description
			,Sal_Tran_ID
			,AD_Amount
			,AD_ACtual_Amount
			,AD_Calculated_Amount
			,For_Date
			,M_AD_Flag
			,M_Arrear_Days
			,Gujarati_Alias
			)
		SELECT ms.Emp_ID
			,Cmp_ID
			,NULL
			,'Holiday Working'
			,Sal_Tran_ID
			,M_HO_OT_Amount
			,M_HO_OT_Amount
			,0
			,Month_end_Date
			,'I'
			,0
			,N'?????? ???'
		FROM T0200_Monthly_Salary ms WITH (NOLOCK)
		INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
			AND Month(Month_End_Date) = Month(@To_Date)
			AND Year(Month_End_Date) = Year(@To_Date)
			AND isnull(M_HO_OT_Amount, 0) > 0
	END

	---ended
	---YTD Column-- Ankit 10102013---
	UPDATE #Pay_slip
	SET YTD = Salary_Amount + Qry.M_Arrear_Days
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Salary_Amount) AS Salary_Amount
			,(sum(isnull(mad.Arear_Basic, 0)) + sum(isnull(mad.basic_salary_arear_cutoff, 0))) AS M_Arrear_Days --changed by jimit 07092016 for Ifedora getting Arrear amount in earnings
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'

	UPDATE #Pay_slip
	SET YTD = Total_Claim_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Total_Claim_Amount) AS Total_Claim_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Claim Amount'

	UPDATE #Pay_slip
	SET YTD = OT_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.OT_Amount) AS OT_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'OT Amount'

	UPDATE #Pay_slip
	SET YTD = Other_Allow_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Other_Allow_Amount) AS Other_Allow_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Arrears'

	UPDATE #Pay_slip
	SET YTD = Other_Allow_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Other_Allow_Amount) AS Other_Allow_Amount --,(sum(isnull(mad.Arear_Basic,0))  + sum(isnull(mad.basic_salary_arear_cutoff,0))) as M_Arrear_Days
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Arrear Amount'

	UPDATE #Pay_slip
	SET YTD = Leave_salary_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Leave_salary_Amount) AS Leave_salary_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Leave Encash Amount'

	UPDATE #Pay_slip
	SET YTD = Advance_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Advance_Amount) AS Advance_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Advance Amount'

	UPDATE #Pay_slip
	SET YTD = Loan_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Loan_Amount) AS Loan_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Loan Amount'

	UPDATE #Pay_slip
	SET YTD = Loan_Intrest_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Loan_Intrest_Amount) AS Loan_Intrest_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Loan Interest'

	UPDATE #Pay_slip
	SET YTD = Bonus_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Bonus_Amount) AS Bonus_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Bonus'

	UPDATE #Pay_slip
	SET YTD = PT_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.PT_Amount) AS PT_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Professional tax'

	UPDATE #Pay_slip
	SET YTD = LWF_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.LWF_Amount) AS LWF_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'LWF Amount'

	UPDATE #Pay_slip
	SET YTD = Revenue_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Revenue_Amount) AS Revenue_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Revenue Amount'

	UPDATE #Pay_slip
	SET YTD = Other_Dedu_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Other_Dedu_Amount) AS Other_Dedu_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Other Dedu'

	UPDATE #Pay_slip
	SET YTD = Extra_AB_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Extra_AB_Amount) AS Extra_AB_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Extra Absent Amount'

	UPDATE #Pay_slip
	SET YTD = M_WO_OT_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.M_WO_OT_Amount) AS M_WO_OT_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Week Off Working'

	UPDATE #Pay_slip
	SET YTD = M_HO_OT_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.M_HO_OT_Amount) AS M_HO_OT_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Holiday Working'

	--added by jimit 28072017
	UPDATE #Pay_slip
	SET YTD = Late_Dedu_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(Mad.Late_Dedu_Amount) AS Late_Dedu_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Late Deduction Amt'

	--ended
	---YTD Column-- Ankit 10102013---
	--added By Mukti(start)25032015
	UPDATE #Pay_slip
	SET YTD = Asset_Installment
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Asset_Installment) AS Asset_Installment
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Asset Installment Amount'

	--added By Mukti(end)25032015
	--added By Mukti(start)23052017
	UPDATE #Pay_slip
	SET YTD = Uniform_Installment
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Uniform_Dedu_Amount) AS Uniform_Installment
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Uniform Installment Amount'
		--added By Mukti(end)23052017
END
ELSE IF @Sal_Type = 1
BEGIN
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Basic Salary'
		,NULL
		,S_Salary_amount
		,S_Basic_Salary
		,0
		,s_Month_end_Date
		,'I'
		,0
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)

	--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date       
	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
	----Hasmukh  15102013------
	UPDATE #Pay_Slip
	SET AD_Actual_Amount = MSY.Day_Salary
	FROM dbo.T0200_MONTHLY_SALARY MSY
	INNER JOIN dbo.T0095_Increment I ON MSY.increment_id = i.Increment_ID
	--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	INNER JOIN #Pay_Slip P ON I.Emp_Id = MSY.Emp_Id
		AND P.Sal_Tran_ID = MSY.Sal_Tran_ID --Ankit 11092014
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'
		AND i.Wages_Type = 'Daily'

	----Hasmukh  15102013------
	---YTD Column-- Ankit 10102013---
	UPDATE #Pay_slip
	SET YTD = Salary_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Salary_Amount) AS Salary_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'

	---YTD Column-- Ankit 10102013---
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'OT Amount'
		,NULL
		,S_OT_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'I'
		,0
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Holiday Working'
		,NULL
		,S_WO_OT_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'I'
		,0
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,M_Arrear_Days
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Week Off Working'
		,NULL
		,S_HO_OT_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'I'
		,0
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Professional tax'
		,NULL
		,S_PT_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'D'
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'LWF Amount'
		,NULL
		,S_LWF_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'D'
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,S_Sal_Tran_ID
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Revenue Amount'
		,NULL
		,S_Revenue_Amount
		,NULL
		,S_Gross_Salary
		,S_Month_end_Date
		,'D'
		,S_Sal_Tran_ID
	FROM T0201_Monthly_Salary_Sett ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1
END
ELSE IF @Sal_Type = 2
BEGIN
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Basic Salary'
		,NULL
		,L_Salary_amount
		,l_Basic_Salary
		,0
		,L_Month_end_Date
		,'I'
	FROM T0200_Monthly_Salary_Leave ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(L_Month_end_Date) = Month(@To_Date)
		AND Year(L_Month_end_Date) = Year(@To_Date) --and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date      

	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
	----Hasmukh  15102013------
	UPDATE #Pay_Slip
	SET AD_Actual_Amount = MSY.Day_Salary
	FROM dbo.T0200_MONTHLY_SALARY MSY
	INNER JOIN dbo.T0095_Increment I ON MSY.increment_id = i.Increment_ID
	--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	INNER JOIN #Pay_Slip P ON I.Emp_Id = MSY.Emp_Id
		AND P.Sal_Tran_ID = MSY.Sal_Tran_ID --Ankit 11092014
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'
		AND i.Wages_Type = 'Daily'

	----Hasmukh  15102013------
	---YTD Column-- Ankit 10102013---
	UPDATE #Pay_slip
	SET YTD = Salary_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Salary_Amount) AS Salary_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Basic Salary'
		---YTD Column-- Ankit 10102013---
		/* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,L_PT_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,L_LWF_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,L_Revenue_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date*/
END
ELSE
BEGIN
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Def_ID
		)
	SELECT Emp_ID
		,@Cmp_ID
		,NULL
		,'Basic Salary'
		,NULL
		,0
		,0
		,0
		,@To_Date
		,'I'
		,1
	FROM #Emp_Cons ec

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'OT Amount'
		,Sal_Tran_ID
		,OT_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'I'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        

	--  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	--  select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
	--   From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	--   and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Settlement Amount'
		,Sal_Tran_ID
		,Settelement_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/
		AND isnull(Settelement_Amount, 0) > 0

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Leave Encash Amount'
		,Sal_Tran_ID
		,Leave_salary_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /* and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/
		AND isnull(Leave_Salary_Amount, 0) > 0

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Advance Amount'
		,Sal_Tran_ID
		,Advance_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Bonus'
		,Sal_Tran_ID
		,Bonus_Amount
		,NULL
		,0
		,Month_end_Date
		,'I'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/
		AND isnull(Bonus_Amount, 0) > 0

	--added By Mukti(start)25032015
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Asset Amount'
		,Sal_Tran_ID
		,Asset_Installment
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */

	--added By Mukti(end)25032015
	--added By Mukti(start)23052017
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		)
	SELECT ms.Emp_ID
		,Cmp_ID
		,NULL
		,'Uniform Amount'
		,Sal_Tran_ID
		,Uniform_Dedu_Amount
		,NULL
		,Gross_Salary
		,Month_end_Date
		,'D'
	FROM T0200_Monthly_Salary ms WITH (NOLOCK)
	INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date) /*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */

	--added By Mukti(end)23052017
	/* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)        
    Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID          
    from T0200_Monthly_Salary ms Inner Join #Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp on ms.sal_Tran_Id = mlp.Sal_Tran_Id         
    inner join T0120_loan_approval la on mlp.loan_apr_ID = la.Loan_Apr_ID inner join         
    t0040_Loan_Master lm on la.loan_Id = lm.loan_Id        
    and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date */
	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Def_ID
		)
	SELECT Emp_ID
		,@Cmp_ID
		,NULL
		,'Professional tax'
		,NULL
		,0
		,NULL
		,0
		,@To_Date
		,'D'
		,2
	FROM #Emp_Cons

	-- --Added by Gadriwala Muslim 06012015- Start
	--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
	--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(GatePass_Amount,0) > 0  
	-- --Added by Gadriwala Muslim 06012015- End     
	UPDATE #Pay_slip
	SET AD_Amount = Salary_amount
		,AD_ACtual_Amount = Basic_Salary
	FROM #Pay_slip P
	INNER JOIN T0200_Monthly_Salary ms ON p.emp_ID = ms.emp_ID
		--and  Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
		AND Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date)
	WHERE Def_ID = 1

	UPDATE #Pay_slip
	SET AD_Amount = isnull(AD_Amount, 0) + S_Salary_Amount
		,AD_ACtual_Amount = S_Basic_Salary
	FROM #Pay_slip P
	INNER JOIN T0201_Monthly_Salary_Sett ms ON p.emp_ID = ms.emp_ID
		--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date  
		AND Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1
	WHERE Def_ID = 1

	UPDATE #Pay_slip
	SET AD_Amount = isnull(AD_Amount, 0) + L_Salary_Amount
		,AD_ACtual_Amount = L_Basic_Salary
	FROM #Pay_slip P
	INNER JOIN T0200_Monthly_Salary_Leave ms ON p.emp_ID = ms.emp_ID
		--and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date  ]
		AND Month(L_Month_end_Date) = Month(@To_Date)
		AND Year(L_Month_end_Date) = Year(@To_Date)
	WHERE Def_ID = 1

	UPDATE #Pay_slip
	SET AD_Amount = PT_Amount
		,AD_Calculated_Amount = PT_Calculated_Amount
	FROM #Pay_slip P
	INNER JOIN T0200_Monthly_Salary ms ON p.emp_ID = ms.emp_ID
		AND
		--Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date       
		Month(Month_end_Date) = Month(@To_Date)
		AND Year(Month_end_Date) = Year(@To_Date)
	WHERE Def_ID = 2

	UPDATE #Pay_slip
	SET AD_Amount = isnull(AD_Amount, 0) + S_PT_Amount
		,AD_Calculated_Amount = S_PT_Calculated_Amount
	FROM #Pay_slip P
	INNER JOIN T0201_Monthly_Salary_Sett ms ON p.emp_ID = ms.emp_ID
		AND
		--S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
		Month(S_Month_end_Date) = Month(@To_Date)
		AND Year(S_Month_end_Date) = Year(@To_Date)
		AND Isnull(ms.Effect_On_Salary, 0) = 1
	WHERE Def_ID = 2

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Def_ID
		)
	SELECT Emp_ID
		,@Cmp_ID
		,NULL
		,'LWF Amount'
		,NULL
		,0
		,NULL
		,0
		,@To_DAte
		,'D'
		,3
	FROM #Emp_Cons

	INSERT INTO #Pay_slip (
		Emp_ID
		,Cmp_ID
		,AD_ID
		,AD_Description
		,Sal_Tran_ID
		,AD_Amount
		,AD_ACtual_Amount
		,AD_Calculated_Amount
		,For_Date
		,M_AD_Flag
		,Def_ID
		)
	SELECT Emp_ID
		,@Cmp_ID
		,NULL
		,'Revenue Amount'
		,NULL
		,0
		,NULL
		,0
		,@To_DAte
		,'D'
		,4
	FROM #Emp_Cons

	---YTD Column-- Ankit 10102013---
	UPDATE #Pay_slip
	SET YTD = Settelement_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Settelement_Amount) AS Settelement_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Settlement Amount'

	UPDATE #Pay_slip
	SET YTD = Leave_salary_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Leave_salary_Amount) AS Leave_salary_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Leave Encash Amount'

	UPDATE #Pay_slip
	SET YTD = OT_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.OT_Amount) AS OT_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'OT Amount'

	UPDATE #Pay_slip
	SET YTD = Bonus_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Bonus_Amount) AS Bonus_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Bonus'

	UPDATE #Pay_slip
	SET YTD = Advance_Amount
	FROM (
		SELECT Mad.Emp_ID
			,sum(mad.Advance_Amount) AS Advance_Amount
		FROM T0200_MONTHLY_SALARY MAD WITH (NOLOCK)
		INNER JOIN #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id
			AND (
				MAD.Month_St_Date BETWEEN @F_StartDate
					AND @F_EndDate
				)
			AND MAD.Month_End_Date <= @To_Date
		GROUP BY Mad.Emp_ID
		) Qry
	INNER JOIN #Pay_slip p ON Qry.Emp_ID = p.Emp_ID
	WHERE P.Cmp_ID = @Cmp_ID
		AND AD_Description = 'Advance Amount'
		---YTD Column-- Ankit 10102013---
END

DECLARE @Hide_Allowance_Rate_PaySlip AS TINYINT --Ankit 01052015

SET @Hide_Allowance_Rate_PaySlip = 0

SELECT @Hide_Allowance_Rate_PaySlip = ISNULL(Setting_Value, 0)
FROM T0040_SETTING WITH (NOLOCK)
WHERE Cmp_ID = @Cmp_ID
	AND Setting_Name LIKE 'Hide Allowance Rate in Salary Slip'

UPDATE #Pay_slip -- Added by rohit for Update language value in master on 31032017
SET Gujarati_Alias = LD.LANGUAGES
FROM #Pay_slip PS
INNER JOIN T0040_LANGUAGE_DETAIL LD ON PS.Cmp_ID = LD.CMP_ID
	AND lower(PS.AD_Description) = lower(LD.ENGLISH)

IF @mobile_view = 'MOBILE' -- change by prakash for mobile salary view on 28052016
BEGIN
	--insert into SALTemp (Emp_full_Name,Grd_Name,BandName,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Emp_First_Name,AD_Name,AD_LEVEL,Emp_ID,Cmp_ID,Ad_ID,Sal_Tran_ID,Ad_Description,Ad_Amount,Ad_Actual_Amount,Ad_Calculated_Amount,For_Date,M_Ad_Flag,Loan_ID,Def_ID,M_Arrear_Days,YTD,AD_Amount_on_basic_for_per,Branch_ID,Alpha_Emp_Code)
	SELECT DISTINCT ISNULL(EmpName_Alias_Salary, Emp_Full_Name) AS Emp_full_Name
		,Grd_Name
		,isnull(BandName, '') AS BandName
		,Comp_Name
		,Branch_Address
		,EMP_CODE
		,Type_Name
		,Dept_Name
		,Desig_Name
		,E.Emp_First_Name
		,CASE 
			WHEN @Hide_Allowance_Rate_PaySlip = 0
				THEN (
						AD_Name + ' (' + CASE 
							WHEN GA.AD_MODE = '%'
								THEN cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) AS NVARCHAR(20))
							ELSE ''
							END + isnull(GA.ad_mode, 'AMT') + ') '
						)
			ELSE Ad_Name
			END AS AD_Name
		,ADM.AD_LEVEL
		,MAD.Emp_ID
		,Mad.Cmp_ID
		,Mad.Ad_ID
		,Mad.Sal_Tran_ID
		,Mad.Ad_Description
		,Mad.Ad_Amount
		,CASE 
			WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
				THEN '0.00'
			ELSE dbo.F_Show_Decimal((Mad.Ad_Actual_Amount), mad.cmp_id)
			END AS Ad_Actual_Amount -- F_Show_Decimal function Added by rohit on 06042016
		,Mad.Ad_Calculated_Amount
		,Mad.For_Date
		,Mad.M_Ad_Flag
		,Mad.Loan_ID
		,Mad.Def_ID
		,Mad.M_Arrear_Days
		,Mad.YTD
		,CASE 
			WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
				THEN '0.00'
			ELSE CASE 
					WHEN GA.ad_mode = '%'
						THEN [dbo].[F_Remove_Zero_Decimal](CASE 
									WHEN EEDR_Q.FOR_DATE > EED.FOR_DATE
										THEN EEDR_Q.E_AD_AMOUNT
									WHEN EED.E_AD_AMOUNT > 0
										THEN --Added By Jimit 06072018 as  Percentage Amount is not coming Correct in Actual Amount of heads (Case of Amilife)
											EED.E_AD_AMOUNT
									ELSE EED.E_AD_Amount
									END)
					ELSE mad.AD_Actual_Amount
					END
			END AS AD_Amount_on_basic_for_per
		,-- Changed By rohit For Rate Showing Zero For Formula Allowance on 06012016
		BM.Branch_ID
		,Alpha_Emp_Code
	FROM #Pay_slip MAD
	LEFT OUTER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON MAD.emp_ID = E.emp_ID
	INNER JOIN #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID
	INNER JOIN (
		SELECT I.Increment_ID
			,I.Emp_Id
			,Grd_ID
			,Branch_ID
			,I.Cat_ID
			,Desig_ID
			,Dept_ID
			,Type_ID
			,Increment_effective_Date
			,Band_Id
		FROM dbo.T0095_INCREMENT I WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(Increment_Id) AS Inc_Id
				,II.Emp_ID
			FROM dbo.T0095_INCREMENT II WITH (NOLOCK)
			INNER JOIN (
				SELECT MAX(Increment_Effective_Date) AS For_Date
					,I.Emp_Id
				FROM dbo.T0095_INCREMENT I WITH (NOLOCK)
				INNER JOIN #Emp_Cons E ON I.Emp_ID = E.Emp_Id
				WHERE Cmp_ID = @Cmp_ID
					AND Increment_Effective_Date <= @To_Date
				GROUP BY I.Emp_ID
				) Qry ON II.Emp_ID = Qry.Emp_ID
				AND II.Increment_Effective_Date = Qry.For_Date
			GROUP BY II.Emp_ID
			) Qry1 ON I.Increment_ID = Qry1.Inc_Id
			AND I.Emp_ID = Qry1.Emp_Id
		) I_Q ON E.Emp_ID = I_Q.Emp_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
	LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
	INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
	LEFT OUTER JOIN tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId
	LEFT OUTER JOIN T0120_gradewise_allowance GA WITH (NOLOCK) ON I_Q.Grd_id = GA.Grd_ID
		AND ADM.ad_id = GA.Ad_ID
	LEFT OUTER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON I_Q.Increment_ID = EED.INCREMENT_ID
		AND MAD.AD_ID = EED.AD_ID
		AND MAD.Emp_ID = EED.EMP_ID
	LEFT OUTER JOIN ----Ankit 15092015
		(
		SELECT EEDR.Emp_Id
			,EEDR.AD_ID
			,EEDR.FOR_DATE
			,EEDR.E_AD_AMOUNT
		FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(FOR_DATE) AS For_Date
				,Emp_ID
				,AD_ID
			FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
			WHERE FOR_DATE <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY emp_ID
				,AD_ID
			) Qry ON EEDR.Emp_ID = Qry.Emp_ID
			AND EEDR.For_Date = Qry.For_Date
			AND EEDR.AD_ID = Qry.AD_ID
			AND EEDR.AD_ID = Qry.AD_ID -- Added by nilesh Patel on 15032016
		) EEDR_Q ON MAD.AD_ID = EEDR_Q.AD_ID
		AND MAD.Emp_ID = EEDR_Q.EMP_ID
	LEFT JOIN T0190_MONTHLY_AD_DETAIL_IMPORT ADI WITH (NOLOCK) ON ADI.AD_ID = ADM.AD_ID
		AND ADI.[Month] = Month(@To_date)
		AND ADI.[Year] = Year(@To_date)
		AND ADI.Emp_ID = MAD.Emp_ID
		AND ADI.Cmp_ID = ADM.CMP_ID
		AND ADI.Comments <> '' --Mukti(03082016)          
	WHERE E.Cmp_ID = @Cmp_Id
		AND Month(MAD.For_Date) = Month(@To_date)
		AND Year(Mad.For_date) = Year(@To_date) --MAD.For_date > =@From_Date and MAD.For_date <=@To_Date        
		--and ((MAD.AD_Amount <> 0 And MAD.M_AD_Actual_Per_Amount <> 0) OR (ADM.Allowance_Type='R' AND (MAD.AD_Amount <> 0 OR MAD.AD_Actual_Amount <>0)) ) --aommented jimit due to not in temp table #Pay_Slip
		AND (
			(
				MAD.AD_Amount <> 0
				OR Mad.Ad_Actual_Amount <> 0
				OR Mad.M_Arrear_Days <> 0
				)
			OR (
				ADM.Allowance_Type = 'R'
				AND (
					MAD.AD_Amount <> 0
					OR MAD.AD_Actual_Amount <> 0
					OR Mad.M_Arrear_Days <> 0
					)
				)
			)
	ORDER BY Ad_name DESC
END
ELSE
BEGIN
	IF @SAL_TYPE_OLD = 5
	BEGIN
		SELECT DISTINCT ISNULL(EmpName_Alias_Salary, Emp_Full_Name) AS Emp_full_Name
			,Grd_Name
			,isnull(BandName, '') AS BandName
			,Comp_Name
			,Branch_Address
			,EMP_CODE
			,Type_Name
			,Dept_Name
			,Desig_Name
			,E.Emp_First_Name
			,CASE 
				WHEN @Hide_Allowance_Rate_PaySlip = 0
					THEN (
							AD_Name + ' (' + CASE 
								WHEN GA.AD_MODE = '%'
									THEN cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) AS NVARCHAR(20))
								ELSE ''
								END + isnull(GA.ad_mode, 'AMT') + ') '
							)
				ELSE Ad_Name
				END AS AD_Name
			,
			--(AD_Name + ' (' + case when GA.AD_MODE = '%' then cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) as nvarchar(20)) else '' end  + isnull(GA.ad_mode,'AMT') + ') ')as AD_Name ,
			ADM.AD_LEVEL
			,MAD.Emp_ID
			,Mad.Cmp_ID
			,Mad.Ad_ID
			,Mad.Sal_Tran_ID
			,Mad.Ad_Description
			,Mad.Ad_Amount
			--,dbo.F_Remove_Zero_Decimal(Mad.Ad_Actual_Amount) as Ad_Actual_Amount
			--,case when Upper(Adm.Ad_calculate_on)='FORMULA' then '0.00' else dbo.F_Remove_Zero_Decimal(Mad.Ad_Actual_Amount) end as Ad_Actual_Amount -- Added by rohit on 060120016 for Formula Rate Showing Zero
			,CASE 
				WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
					THEN '0.00'
				ELSE dbo.F_Show_Decimal((Mad.Ad_Actual_Amount), mad.cmp_id)
				END AS Ad_Actual_Amount -- F_Show_Decimal function Added by rohit on 06042016
			,Mad.Ad_Calculated_Amount
			,Mad.For_Date
			,Mad.M_Ad_Flag
			,Mad.Loan_ID
			,Mad.Def_ID
			,Mad.M_Arrear_Days
			,Mad.YTD
			,CASE 
				WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
					THEN '0.00'
				ELSE CASE 
						WHEN GA.ad_mode = '%'
							THEN [dbo].[F_Remove_Zero_Decimal](CASE 
										WHEN EEDR_Q.FOR_DATE > EED.FOR_DATE
											THEN EEDR_Q.E_AD_AMOUNT
										WHEN EED.E_AD_AMOUNT > 0
											THEN --Added By Jimit 06072018 as  Percentage Amount is not coming Correct in Actual Amount of heads (Case of Amilife)
												EED.E_AD_AMOUNT
										ELSE EED.E_AD_Amount
										END)
						ELSE
							--mad.AD_Actual_Amount /*In Salary Slip Format 10 Potrait Showing Earning and Monthly Amount Column Showing Salary Amount (Monthly Amount should show assigned structure amount)
							EED.E_AD_Amount --Added by Jaina 17-01-2018
						END
				END AS AD_Amount_on_basic_for_per
			,-- Changed By rohit For Rate Showing Zero For Formula Allowance on 06012016
			BM.Branch_ID
			,Alpha_Emp_Code
			,MAD.S_Sal_Tran_Id
			,(AD_Name + '-' + ADI.Comments) AS Comments --Mukti(19082016)	
			,CASE 
				WHEN isnull(mad.AD_ID, 0) = 0
					THEN MAD.Gujarati_Alias
				ELSE ADM.gujarati_alias
				END AS gujarati_alias
		FROM #Pay_slip MAD
		LEFT OUTER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON MAD.emp_ID = E.emp_ID
		INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON E.EMP_ID = EC.EMP_ID
		INNER JOIN
			----Start --Ankit/Nimesh 01082016 [Case - Increment Id Check In Monthly Salary Table Due to After Increment Salary, payslip Monthly Amount column Display Lattest Increment Insted of Calculated Actual Salary :WCL - 28 July, 2016 16:48:PM ]---------
			dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Emp_ID = EC.Emp_Id
			AND Month(Month_End_Date) = Month(@To_date)
			AND Year(Month_End_Date) = Year(@To_date)
		INNER JOIN (
			SELECT I.Increment_ID
				,I.Emp_Id
				,Grd_ID
				,Branch_ID
				,I.Cat_ID
				,Desig_ID
				,Dept_ID
				,Type_ID
				,Increment_effective_Date
				,Band_Id
			FROM dbo.T0095_INCREMENT I WITH (NOLOCK)
			) I_Q ON I_Q.Increment_ID = CASE 
				WHEN @Sal_Type = 0
					THEN MS.Increment_ID
				ELSE EC.Increment_ID
				END
		INNER JOIN
			----End --Ankit/Nimesh 01082016 ---------	 
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
		INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId
		LEFT OUTER JOIN T0120_gradewise_allowance GA WITH (NOLOCK) ON I_Q.Grd_id = GA.Grd_ID
			AND ADM.ad_id = GA.Ad_ID
		LEFT OUTER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON I_Q.Increment_ID = EED.INCREMENT_ID
			AND MAD.AD_ID = EED.AD_ID
			AND MAD.Emp_ID = EED.EMP_ID --Comment By Ankit 
		LEFT OUTER JOIN ----Ankit 15092015
			(
			SELECT EEDR.Emp_Id
				,EEDR.AD_ID
				,EEDR.FOR_DATE
				,EEDR.E_AD_AMOUNT
			FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK)
			INNER JOIN (
				SELECT MAX(FOR_DATE) AS For_Date
					,Emp_ID
					,AD_ID
				FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
				WHERE FOR_DATE <= @To_Date
					AND Cmp_ID = @Cmp_ID
				GROUP BY emp_ID
					,AD_ID
				) Qry ON EEDR.Emp_ID = Qry.Emp_ID
				AND EEDR.For_Date = Qry.For_Date
				AND EEDR.AD_ID = Qry.AD_ID
				AND EEDR.AD_ID = Qry.AD_ID -- Added by nilesh Patel on 15032016
			) EEDR_Q ON MAD.AD_ID = EEDR_Q.AD_ID
			AND MAD.Emp_ID = EEDR_Q.EMP_ID
		LEFT OUTER JOIN T0190_MONTHLY_AD_DETAIL_IMPORT ADI WITH (NOLOCK) ON ADI.AD_ID = ADM.AD_ID
			AND ADI.[Month] = Month(@To_date)
			AND ADI.[Year] = Year(@To_date)
			AND ADI.Emp_ID = MAD.Emp_ID
			AND ADI.Cmp_ID = ADM.CMP_ID
			AND ADI.Comments <> '' --Mukti(03082016)        
		WHERE E.Cmp_ID = @Cmp_Id
			AND Month(MAD.For_Date) = Month(@To_date)
			AND Year(Mad.For_date) = Year(@To_date) --MAD.For_date > =@From_Date and MAD.For_date <=@To_Date        
			--and ((MAD.AD_Amount <> 0 And MAD.M_AD_Actual_Per_Amount <> 0) OR (ADM.Allowance_Type='R' AND (MAD.AD_Amount <> 0 OR MAD.AD_Actual_Amount <>0)) ) --aommented jimit due to not in temp table #Pay_Slip
			AND (
				(
					(
						(
							MAD.AD_Amount <> 0
							OR Mad.Ad_Actual_Amount <> 0
							OR ytd <> 0
							OR Mad.M_Arrear_Days <> 0
							)
						AND @sal_type <> 1
						)
					OR (
						(
							(
								MAD.AD_Amount <> 0
								AND Mad.Ad_Actual_Amount <> 0
								)
							OR MAD.AD_Amount < 0
							)
						AND @sal_type = 1
						) -- CHANGED BY GADRIWALA MUSLIM 30092016 FOR IN - SALARY SETTLEMENT ALLOWANCE SHOULD NOT BE SHOW IF AMOUNT IS ZERO 
					OR (
						ADM.Allowance_Type = 'R'
						AND (
							MAD.AD_Amount <> 0
							OR MAD.AD_Actual_Amount <> 0
							OR Mad.M_Arrear_Days <> 0
							)
						)
					)
				OR ADM.Show_In_Pay_Slip = 1
				) --Added by Jaina 21-02-2018
		ORDER BY Ad_name DESC
	END
	ELSE
	BEGIN
		SELECT DISTINCT ISNULL(EmpName_Alias_Salary, Emp_Full_Name) AS Emp_full_Name
			,Grd_Name
			,isnull(BandName, '') AS BandName
			,Comp_Name
			,Branch_Address
			,EMP_CODE
			,Type_Name
			,Dept_Name
			,Desig_Name
			,E.Emp_First_Name
			,CASE 
				WHEN @Hide_Allowance_Rate_PaySlip = 0
					AND AD_DEF_ID <> 8
					THEN -- Added by Hardik 15/09/2018 AD_DEF_ID = 8 for LTA for WCL (As they don't want to show LTA Rate) 
						(
							AD_Name + ' (' + CASE 
								WHEN GA.AD_MODE = '%'
									THEN cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) AS NVARCHAR(20))
								ELSE ''
								END + isnull(GA.ad_mode, 'AMT') + ') '
							)
				ELSE Ad_Name
				END AS AD_Name
			,
			--ADM.AD_LEVEL,
			CASE 
				WHEN AD_Description = 'Arrears'
					THEN 999
				ELSE ADM.AD_LEVEL
				END AS AD_LEVEL
			,--Added By Jimit 11122018 for Genchi Require Arrear at Last in the List
			MAD.Emp_ID
			,Mad.Cmp_ID
			,Mad.Ad_ID
			,Mad.Sal_Tran_ID
			,Mad.Ad_Description
			,Mad.Ad_Amount
			,CASE 
				WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
					THEN '0.00'
				ELSE dbo.F_Show_Decimal((Mad.Ad_Actual_Amount), mad.cmp_id)
				END AS Ad_Actual_Amount -- F_Show_Decimal function Added by rohit on 06042016
			--,case when Ad_Name is null then MAD.AD_Actual_Amount else EED.E_AD_AMOUNT end as Ad_Actual_Amount -- This line uncomment for the Khimji Jewellers Client and Above Link Commeted Added By Sajid 16102021
			,Mad.Ad_Calculated_Amount
			,Mad.For_Date
			,Mad.M_Ad_Flag
			,Mad.Loan_ID
			,Mad.Def_ID
			,Mad.M_Arrear_Days
			,Mad.YTD
			,CASE 
				WHEN Upper(Adm.Ad_calculate_on) = 'FORMULA'
					OR AD_DEF_ID = 8
					THEN '0.00' -- Added by Hardik 15/09/2018 AD_DEF_ID = 8 for LTA for WCL (As they don't want to show LTA Rate) 
				ELSE CASE 
						WHEN GA.ad_mode = '%'
							AND Upper(Adm.Ad_calculate_on) <> 'BRANCH + GRADE'
							THEN [dbo].[F_Remove_Zero_Decimal]
								--(CASE WHEN EEDR_Q.FOR_DATE > EED.FOR_DATE THEN EEDR_Q.E_AD_AMOUNT ELSE EED.E_AD_Amount END) 
								(CASE 
										WHEN EEDR_Q.FOR_DATE > EED.FOR_DATE
											THEN EEDR_Q.E_AD_AMOUNT
										WHEN EED.E_AD_AMOUNT > 0
											THEN --Added By Jimit 06072018 as  Percentage Amount is not coming Correct in Actual Amount of heads (Case of Amilife)
												EED.E_AD_AMOUNT
										ELSE MAD.Ad_Amount
										END)
						WHEN MAD.AD_ID IS NULL
							AND MAD.AD_Description = 'Basic Salary'
							THEN I_Q.Basic_Salary
						ELSE
							--mad.AD_Actual_Amount /*In Salary Slip Format 10 Potrait Showing Earning and Monthly Amount Column Showing Salary Amount (Monthly Amount should show assigned structure amount)
							EED.E_AD_Amount --Added by Jaina 17-01-2018
						END
				END AS AD_Amount_on_basic_for_per
			,-- Changed By rohit For Rate Showing Zero For Formula Allowance on 06012016
			BM.Branch_ID
			,Alpha_Emp_Code
			,MAD.S_Sal_Tran_Id
			,(AD_Name + '-' + ADI.Comments) AS Comments --Mukti(19082016)	
			,CASE 
				WHEN isnull(mad.AD_ID, 0) = 0
					THEN MAD.Gujarati_Alias
				ELSE ADM.gujarati_alias
				END AS gujarati_alias -- added by rohit
			,I_Q.Wages_Type
			,isnull(ADM.AD_CALCULATE_ON, '') AS AD_CALCULATE_ON
		FROM #Pay_slip MAD
		LEFT OUTER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON MAD.emp_ID = E.emp_ID
		INNER JOIN #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID
		INNER JOIN dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Emp_ID = EC.Emp_Id
			AND Month(Month_End_Date) = Month(@To_date)
			AND Year(Month_End_Date) = Year(@To_date) ----Start --Ankit/Nimesh 01082016 [Case - Increment Id Check In Monthly Salary Table Due to After Increment Salary, payslip Monthly Amount column Display Lattest Increment Insted of Calculated Actual Salary :WCL - 28 July, 2016 16:48:PM ]---------
		INNER JOIN T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.EMP_ID = MS.EMP_ID
			AND I_Q.Increment_ID = CASE 
				WHEN @Sal_Type = 0
					THEN MS.Increment_ID
				ELSE EC.Increment_ID
				END --Emp_ID Join Added By Ramiz on 16/10/2018
			--INNER JOIN (SELECT	I.Increment_ID, I.Emp_Id , Grd_ID,Branch_ID,I.Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,I.Wages_Type, I.Basic_Salary
			--			FROM	dbo.T0095_INCREMENT I 
			--			) I_Q  ON  I_Q.Increment_ID  = Case When @Sal_Type = 0 Then MS.Increment_ID Else EC.Increment_ID END  ----End --Ankit/Nimesh 01082016 ---------	 
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
		INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
		LEFT OUTER JOIN T0120_gradewise_allowance GA WITH (NOLOCK) ON I_Q.Grd_id = GA.Grd_ID
			AND ADM.ad_id = GA.Ad_ID
		LEFT OUTER JOIN tblBandMaster B WITH (NOLOCK) ON I_Q.Band_Id = B.BandId
		LEFT OUTER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON I_Q.Increment_ID = EED.INCREMENT_ID
			AND MAD.AD_ID = EED.AD_ID
			AND MAD.Emp_ID = EED.EMP_ID --Comment By Ankit 
		LEFT OUTER JOIN (
			SELECT EEDR.Emp_Id
				,EEDR.AD_ID
				,EEDR.FOR_DATE
				,EEDR.E_AD_AMOUNT
			FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK)
			INNER JOIN (
				SELECT MAX(FOR_DATE) AS For_Date
					,Emp_ID
					,AD_ID
				FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
				WHERE FOR_DATE <= @To_Date
					AND Cmp_ID = @Cmp_ID
				GROUP BY emp_ID
					,AD_ID
				) Qry ON EEDR.Emp_ID = Qry.Emp_ID
				AND EEDR.For_Date = Qry.For_Date
				AND EEDR.AD_ID = Qry.AD_ID
				AND EEDR.AD_ID = Qry.AD_ID -- Added by nilesh Patel on 15032016
			) EEDR_Q ON MAD.AD_ID = EEDR_Q.AD_ID
			AND MAD.Emp_ID = EEDR_Q.EMP_ID
		LEFT JOIN T0190_MONTHLY_AD_DETAIL_IMPORT ADI WITH (NOLOCK) ON ADI.AD_ID = ADM.AD_ID
			AND ADI.[Month] = Month(@To_date)
			AND ADI.[Year] = Year(@To_date)
			AND ADI.Emp_ID = MAD.Emp_ID
			AND ADI.Cmp_ID = ADM.CMP_ID
			AND ADI.Comments <> '' --Mukti(03082016)        
		WHERE E.Cmp_ID = @Cmp_Id
			AND Month(MAD.For_Date) = Month(@To_date)
			AND Year(Mad.For_date) = Year(@To_date) --MAD.For_date > =@From_Date and MAD.For_date <=@To_Date        
			AND (
				(
					(
						(
							MAD.AD_Amount <> 0
							OR Mad.Ad_Actual_Amount <> 0
							OR Mad.M_Arrear_Days <> 0
							)
						AND @sal_type <> 1
						)
					OR (
						(
							(
								MAD.AD_Amount <> 0
								AND Mad.Ad_Actual_Amount <> 0
								)
							OR MAD.AD_Amount <> 0
							)
						AND @sal_type = 1
						) -- CHANGED BY GADRIWALA MUSLIM 30092016 FOR IN - SALARY SETTLEMENT ALLOWANCE SHOULD NOT BE SHOW IF AMOUNT IS ZERO 
					OR (
						ADM.Allowance_Type = 'R'
						AND (
							MAD.AD_Amount <> 0
							OR MAD.AD_Actual_Amount <> 0
							OR Mad.M_Arrear_Days <> 0
							)
						)
					)
				OR ADM.Show_In_Pay_Slip = 1 --Added by Jaina 21-02-2018 
				--added by Krushna 28-05-2018 for EcoGreen
				OR MAD.AD_Description = (
					CASE 
						WHEN @Show_PT_in_Payslip_if_Zero = 1
							THEN 'Professional tax'
						ELSE ''
						END
					)
				OR MAD.AD_Description = (
					CASE 
						WHEN @Show_LWF_in_Payslip_if_Zero = 1
							THEN 'LWF Amount'
						ELSE ''
						END
					)
				)
		--end Krushna
		ORDER BY Ad_name DESC
	END
END
