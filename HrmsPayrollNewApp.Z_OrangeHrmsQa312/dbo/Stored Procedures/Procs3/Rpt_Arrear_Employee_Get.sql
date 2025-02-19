


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Arrear_Employee_Get]  
	@Company_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	--,@Branch_ID		numeric	
	--,@Grade_ID 		numeric
	--,@Type_ID 		numeric
	--,@Dept_ID 		numeric
	--,@Desig_ID 		numeric
	,@Branch_ID		varchar(max) = ''	
	,@Grade_ID 		varchar(max) = ''	
	,@Type_ID 		varchar(max) = ''	
	,@Dept_ID 		varchar(max) = ''	
	,@Desig_ID 		varchar(max) = ''	
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	--,@Cat_ID        numeric = 0
	,@Cat_ID        varchar(max) = ''	
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Actual_From_Date datetime
	Declare @Actual_To_Date datetime
	
	Declare @P_Days as numeric(22,2)
	Declare @Arear_Days as Numeric(18,2)
	Declare @Basic_Salary As Numeric(22,2)
	Declare @TDS As Numeric(22,2)
	Declare @Settl As Numeric(22,2)
	Declare @OTher_Allow As Numeric(22,2)
	Declare @Total_Allowance As Numeric(22,2)
	Declare @CO_Amount As Numeric(22,2)
	Declare @Total_Deduction As Numeric(22,2)
	Declare @PT As Numeric(22,2)
	Declare @Loan As Numeric(22,2)
	Declare @Advance As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)	
	Declare @Revenue_Amt As Numeric(22,2)	
	Declare @LWF_Amt As Numeric(22,2)	
	Declare @Other_Dedu As Numeric(22,2)	
	
	--Alpesh 25-Nov-2011
	Declare @Absent_Day numeric(18,2)
	Declare @Holiday_Day numeric(18,2)
	Declare @WeekOff_Day numeric(18,2)
	--Declare @Leave_Day numeric(18,2) -- Added By Ali 18122013
	Declare @Sal_Cal_Day numeric(18,2)
	
	-- Rohit 26-sep-2012
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	declare @Fix_OT_Shift_Hours varchar(40)
	declare @Fix_OT_Shift_seconds numeric(18,2)
   
	set @Actual_From_Date = @From_Date
	set @Actual_To_Date = @To_Date
	
 	IF @Branch_ID = ''  
		set @Branch_ID = null   
	 If @Grade_ID = ''  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = ''  
		set @Desig_ID = null  
     If @Dept_ID = ''  
		set @Dept_ID = null 
     If @Cat_ID = ''
        set @Cat_ID = null
        
     If @Type_id = ''
        set @Type_id = null
        
        
     if @Salary_Cycle_id   = 0
		set @Salary_Cycle_id = null
		
	if @Segment_ID = 0 
		set @Segment_ID = NULL
		
	if @Vertical = 0 
		set @Vertical = NULL
		
	if @SubVertical = 0 
		set @SubVertical = NULL
	
	if @subBranch  = 0 
		set @subBranch = NULL

   -- Comment and added By rohit on 11022013
    Declare @Sal_St_Date   Datetime    
	 Declare @Sal_end_Date   Datetime   
	
	 declare @manual_salary_period as numeric(18,0)
	 set @manual_salary_period = 0
	 

declare @from_date_temp as datetime
		
if @salary_cycle_id<>0
begin
	select @from_date_temp = Salary_st_date from t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @salary_Cycle_id

	set @from_date = cast(cast(day(@from_date_temp) as varchar(2)) + '-' + cast(datename(mm,dateadd(m,0,@From_Date)) as varchar(10)) + '-' + cast(year(@from_date)as varchar(4)) as datetime)
	set @to_date = dateadd(d,-1,dateadd(m,1,@from_date))
end

    
 create table #Emp_Cons
	(
		Emp_ID	numeric ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC 
	)
	
	
		print 1
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
	
		INSERT INTO #Emp_Cons

			SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
			Inner Join dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = V.Emp_ID 
			Inner Join dbo.T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK) on MPI.Emp_ID = V.Emp_ID and MPI.Month  = month(@To_Date) and MPI.Year = year(@To_Date)
			LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
			WHERE 
		      V.cmp_id=@Company_id
		   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )	
		   and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') )
		   and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grade_ID,ISNULL(Grd_ID,0)),'#') )	
		   and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
		   and ISNULL(TYPE_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(TYPE_ID,0)),'#') )
		   and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 				
		   --AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
		   --AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   --AND Grd_ID = ISNULL(@Grade_ID ,Grd_ID)      
		   --AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		  -- AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   --AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch,IsNull(subBranch_ID,0)) -- Added on 06082013
		   and month(ms.Month_End_Date)  = month(@To_Date) and year(ms.Month_End_Date)  = year(@To_Date)
		 --and month(mpi.Month)  = month(@To_Date) and year(mpi.Year)  = year(@To_Date)
		   and ms.Is_FNF = 0
		   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
			 
			ORDER BY Emp_ID

						
			DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
				
end
	
   select Distinct EC.Emp_ID,Emp_Code,EM.Alpha_Emp_Code, EM.Emp_full_Name,em.branch_id 
			,EM.Vertical_ID,EM.SubVertical_ID,EM.Dept_ID   --Added By Jaina 7-10-2015	
   from #Emp_Cons EC inner join T0080_emp_Master EM WITH (NOLOCK) on EC.Emp_ID=EM.Emp_ID
 --   inner join T0095_Increment on EC.INcrement_ID=EM.INcrement_ID
    order by Em.Emp_code



