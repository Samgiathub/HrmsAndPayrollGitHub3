


-- exec SP_EMP_SALARY_RECORD_EXPORT_PAYABLE @Cmp_ID=10,@From_Date='2013-08-01 00:00:00',@To_Date='2013-08-31 00:00:00',@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID =0,@Constraint='',@Salary_Status='Pending',@Salary_Cycle_id=0,@Sub_Branch_Id=0,@BSegment_Id=0,@Vertical_Id=0,@SVertical_Id=0
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_EMP_SALARY_RECORD_EXPORT_PAYABLE]
	 @Cmp_ID			NUMERIC
	,@From_Date			DATETIME
	,@To_Date			DATETIME 
	--,@Branch_ID			NUMERIC	= 0 --Comment by nilesh patel on 05112014
	,@Branch_ID			Varchar(Max) = '' --Added by nilesh patel on 05112014
	,@Cat_ID			NUMERIC = 0 
	,@Grd_ID			NUMERIC = 0
	,@Type_ID			NUMERIC = 0
	--,@Dept_ID			NUMERIC = 0 --Comment by nilesh patel on 05112014
	,@Dept_ID		Varchar(Max) = '' --Added by nilesh patel on 05112014
	,@Desig_ID			NUMERIC = 0
	,@Emp_ID			NUMERIC = 0	
	,@Constraint		VARCHAR(5000) = ''
	,@Salary_Status		VARCHAR(10) = 'All'
	,@Salary_Cycle_id	NUMERIC = 0
	--,@Sub_Branch_Id		NUMERIC(18,0) = 0		
	--,@BSegment_Id		NUMERIC(18,0) = 0		
	--,@Vertical_Id		NUMERIC(18,0) = 0		
	--,@SVertical_Id		NUMERIC(18,0) = 0	
	,@Sub_Branch_Id		Varchar(Max) = '' --Added by nilesh patel on 05112014	
	,@BSegment_Id		Varchar(Max) = '' --Added by nilesh patel on 05112014		
	,@Vertical_Id		Varchar(Max) = '' --Added by nilesh patel on 05112014	
	,@SVertical_Id		Varchar(Max) = '' --Added by nilesh patel on 05112014		
AS
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Date_Diff NUMERIC 
	
	SET @Date_Diff = DATEDIFF(d,@From_Date,@To_date) + 1
	
	IF @Salary_Cycle_id = 0
		SET @Salary_Cycle_id = NULL
	
	IF @Branch_ID = ''
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
		
	IF @Dept_ID = ''
		SET @Dept_ID = NULL
		
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
		
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	-- Added By Hiral 13 August, 2013 (Start)
	IF @Sub_Branch_Id = ''
		SET @Sub_Branch_Id = NULL
		
	If @BSegment_Id = ''
		Set @BSegment_Id = Null
		
	If @Vertical_Id = ''
		Set @Vertical_Id = Null
	
	If @SVertical_Id = ''
		Set @SVertical_Id = Null
	-- Added By Hiral 13 August, 2013 (End)

	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
	
	
	SELECT   (Select Cmp_Name From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID) As Cmp_Name
			-- , BS.Segment_ID
			, BS.Segment_Name As Business_Segment
			-- , VS.Vertical_ID
			, VS.Vertical_Name As Vertical
			-- , SVS.SubVertical_ID
			, SVS.SubVertical_Name As Sub_Vertical
			, BM.Branch_Name As Branch
			, datename(month, @From_Date) As Salary_Month
			, year(@From_Date) As Salary_Year
			, SCM.Name As Salary_Cycle
			, count(DISTINCT V.emp_id) as No_Of_Emps
			, Sum (I_Q.CTC) As CTC
			, Sum(MPI.Payble_Amount) As CTC_Payable
			, Sum(MADI.Amount) As Reimbursement
			, (Sum(MPI.Payble_Amount) + Sum(MADI.Amount)) As Total_Payable
			
	--SELECT BM.Branch_Name, count(DISTINCT V.emp_id) as No_Of_Emp, VS.Vertical_ID, VS.Vertical_Name, SVS.SubVertical_ID, SVS.SubVertical_Name
	--		, BS.Segment_ID, BS.Segment_Name, SCM.Name, Sum (I_Q.CTC) As CTC, Sum(MPI.Payble_Amount) As CTC_Payable
	--		, Sum(MADI.Amount) As Reimbursement
	--		, (Sum(MPI.Payble_Amount) + Sum(MADI.Amount)) As Total_Payable
	--		,(Select Cmp_Name From T0010_COMPANY_MASTER Where Cmp_ID = @Cmp_ID) As Cmp_Name, datename(month, @From_Date) As Salary_Month
			
			
		FROM V_Emp_Cons V
		inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on V.branch_id=g.branch_id
			LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Effective_date) AS Effective_date, emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
								ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
							) AS QrySC
			ON QrySC.eid = V.Emp_ID
			LEFT OUTER JOIN (SELECT I.Emp_Id, Grd_ID, Branch_ID, Cat_ID, Desig_ID, Dept_ID, TYPE_ID, CTC
								FROM T0095_Increment I WITH (NOLOCK)
									INNER JOIN (SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
													FROM T0095_Increment WITH (NOLOCK)
													WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
													GROUP BY emp_ID
												) Qry 
									ON I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date
							 ) I_Q 
			ON V.Emp_ID = I_Q.Emp_ID
			Left Outer Join (Select * from T0190_MONTHLY_AD_DETAIL_IMPORT WITH (NOLOCK)
									Where AD_ID In (Select AD_ID From T0050_AD_MASTER WITH (NOLOCK)
														Where AD_Calculate_On = 'Import' And Cmp_ID = @Cmp_ID)
							) MADI
			On MADI.Emp_ID = V.Emp_ID 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON V.BRANCH_ID = BM.BRANCH_ID
			Left Outer Join T0040_Vertical_Segment VS WITH (NOLOCK) On VS.Vertical_ID = V.Vertical_ID
			Left Outer Join T0050_SubVertical SVS WITH (NOLOCK) On SVS.SubVertical_ID = V.SubVertical_ID
			Left Outer Join T0040_Business_Segment BS WITH (NOLOCK) On BS.Segment_ID = V.Segment_ID
			Left Outer Join T0040_Salary_Cycle_Master SCM WITH (NOLOCK) On SCM.Tran_ID = QrySC.SalDate_id
			Left Outer Join T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK) On MPI.Emp_ID = V.Emp_ID
		WHERE V.cmp_id=@Cmp_ID 
			AND ISNULL(V.Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(V.Cat_ID,0))      
			--AND V.Branch_ID = ISNULL(@Branch_ID ,V.Branch_ID) --Comment by nilesh patel on 05112014
			AND ISNULL(V.Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Branch_ID,ISNULL(V.Branch_ID,0)),'#') )  -- Added by nilesh on 01112014           
			AND V.Grd_ID = ISNULL(@Grd_ID ,V.Grd_ID) 
			--AND ISNULL(V.Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(V.Dept_ID,0))  --Comment by nilesh patel on 05112014  
			AND ISNULL(V.Dept_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Dept_ID,ISNULL(V.Dept_ID,0)),'#') )  -- Added by nilesh on 01112014               
			AND ISNULL(V.TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(V.TYPE_ID,0))      
			AND ISNULL(V.Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(V.Desig_ID,0)) 
			AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))      
			AND V.Emp_ID = ISNULL(@Emp_ID ,V.Emp_ID)   
			AND V.Increment_Effective_Date <= @To_Date 
			AND ((@From_Date >= V.join_Date AND @From_Date <= V.left_date) OR (@To_Date >= V.join_Date AND @To_Date <= V.left_date)      
				 OR (V.Left_date IS NULL AND @To_Date >= V.Join_Date) OR (@To_Date >= V.left_date AND @From_Date <= V.left_date )
				 --OR 1 = (CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (V.left_date <= @To_Date) AND (DATEADD(mm,1,V.Left_Date) > @From_Date )) THEN 1 ELSE 0 END)
				 OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (V.left_date >= case when (isnull(g.Sal_St_Date,'')) = ''  then @From_Date  when day(g.Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(g.Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(g.Sal_St_Date,'')) = ''  then @to_date when day(g.sal_st_date)=1 then @to_date else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(g.Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
				)
			--And ISNULL(V.Segment_ID,0) = ISNULL(@BSegment_Id,IsNull(V.Segment_ID,0))			-- Added By Hiral 13 August, 2013
			--And ISNULL(V.Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(V.Vertical_ID,0))			-- Added By Hiral 13 August, 2013
			--And ISNULL(V.SubVertical_ID,0) = ISNULL(@SVertical_Id,IsNull(V.SubVertical_ID,0))	-- Added By Hiral 13 August, 2013
			--And ISNULL(V.subBranch_ID,0) = ISNULL(@Sub_Branch_Id,IsNull(V.subBranch_ID,0))		-- Added By Hiral 13 August, 2013
			AND ISNULL(V.Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@BSegment_Id,ISNULL(V.Segment_ID,0)),'#') )  -- Added by nilesh on 01112014           
			AND ISNULL(V.Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical_Id,ISNULL(V.Vertical_ID,0)),'#') )  -- Added by nilesh on 01112014           
			AND ISNULL(V.SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SVertical_Id,ISNULL(V.SubVertical_ID,0)),'#') )  -- Added by nilesh on 01112014           
			AND ISNULL(V.subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Sub_Branch_Id,ISNULL(V.subBranch_ID,0)),'#') )  -- Added by nilesh on 01112014           
			And V.Emp_ID Not In (Select Emp_ID from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK)
									Where Month = Month(@From_Date) And Cmp_ID = @Cmp_ID)		-- Added By Hiral 16 August, 2013
			and g.For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 17092014
		Group By BM.Branch_Name, VS.Vertical_ID, VS.Vertical_Name, SVS.SubVertical_ID, SVS.SubVertical_Name
			,BS.Segment_ID, BS.Segment_Name, SCM.Name
		  
RETURN

