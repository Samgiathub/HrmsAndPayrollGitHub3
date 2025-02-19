


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_SALARY_Constraint_adult_worker] 
	-- Add the parameters for the stored procedure here
	 @Cmp_ID 		varchar(max)
	 --,@Cmp_Constraint VARCHAR(MAX) = ''
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		varchar(MAX) = '' 
	,@Grd_ID 		varchar(MAX) = ''
	--,@Type_ID 		numeric
	,@Type_ID 		varchar(MAX) = ''
	,@Dept_ID 		varchar(MAX) = ''
	,@Desig_ID 		varchar(MAX) = ''
	,@Emp_ID 		numeric
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Branch_Constraint VARCHAR(MAX) = ''
	,@Segment_ID varchar(MAX) = ''
	,@Vertical varchar(MAX) = '' 
	,@SubVertical varchar(MAX) = '' 
	,@subBranch varchar(MAX) = '' 
	,@Constraint	VARCHAR(MAX) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 --CREATE TABLE #Emp_Cons         
 --(              
 --  Emp_ID NUMERIC ,             
 --  Branch_ID NUMERIC,        
 --  Increment_ID NUMERIC            
 --)        
 --CREATE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);        
   

	IF @Salary_Cycle_id = 0
		SET @Salary_Cycle_id = NULL
	
	IF @Branch_ID = 0
		SET @Branch_ID = NULL
		
	IF @Cat_ID = ''
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
		
	IF @Dept_ID = ''
		SET @Dept_ID = NULL
		
	IF @Grd_ID = ''
		SET @Grd_ID = NULL 
		
	IF @Branch_Constraint = ''
		Set @Branch_Constraint = NULL
		
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = ''
		SET @Desig_ID = NULL
		
	IF @Segment_ID = '' 
		SET @Segment_ID = NULL
		
	IF @Vertical = ''  OR @Vertical= '0' 
		SET @Vertical = NULL
		
	IF @SubVertical = '' OR @SubVertical = '0' 
		SET @SubVertical  = NULL
	
	IF @subBranch = '' OR @subBranch = '0' 
		SET @subBranch = NULL

 --	CREATE TABLE #Emp_Cons             
 --  (                  
 --  Emp_ID NUMERIC ,                 
 --  Branch_ID NUMERIC,            
 --  Increment_ID NUMERIC   
 --) 
    DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
    
		--added by mansi  start 20-11-21
		if(@Cmp_ID =cast(0 as varchar))
		begin
		  
		          INSERT INTO #Emp_Cons
		              SELECT DISTINCT emp_id,V_Emp_Cons.branch_id,Increment_ID
		                FROM V_Emp_Cons 
							 inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on V_Emp_Cons.branch_id=g.branch_id
						WHERE --V_Emp_Cons.cmp_id=@Cmp_ID 				
						--		--AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))   -- Comment by nilesh on 01112014
						--		AND ISNULL(Cat_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )  -- Added by nilesh on 01112014 
						--		AND ISNULL(Grd_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Grd_ID,ISNULL(Grd_Id,0)),'#') )  -- Added by nilesh on 26-08-2014  
						--		AND ISNULL(Dept_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID ,ISNULL(Dept_ID,0)),'#') )  -- Added by nilesh on 26-08-2014      
						--		AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
						--		AND ISNULL(Desig_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID ,ISNULL(Desig_ID,0)),'#') ) -- ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
						--		AND ISNULL(SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(SalDate_id,0))     
						--		--AND ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,ISNULL(Segment_ID,0))
						--		--AND ISNULL(Vertical_ID,0) = ISNULL(@Vertical,ISNULL(Vertical_ID,0))
						--		--AND ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,ISNULL(SubVertical_ID,0))
						--		--AND ISNULL(subBranch_ID,0) = ISNULL(@subBranch,ISNULL(subBranch_ID,0)) -- Added on 06082013 
						--		AND ISNULL(Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Segment_ID,ISNULL(Segment_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
						--		AND ISNULL(Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical,ISNULL(Vertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
						--		AND ISNULL(SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SubVertical,ISNULL(SubVertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
						--		AND ISNULL(subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@subBranch,ISNULL(subBranch_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
						--		AND ISNULL(Emp_Id,0) = ISNULL(@Emp_Id,ISNULL(Emp_Id,0)) AND
								 Increment_Effective_Date <= @To_Date 
								AND ((@From_Date >= join_Date AND @From_Date <= left_date)      
									 OR (@To_Date >= join_Date AND @To_Date <= left_date)      
									 OR (Left_date IS NULL AND @To_Date >= Join_Date)      
									 OR (@To_Date >= left_date AND @From_Date <= left_date)
									 OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  
									 dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) 
									 as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
									)
								--AND V_Emp_Cons.branch_id in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint ,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								--AND  ISNULL(V_Emp_Cons.branch_id,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								--and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = Isnull(@branch_id,V_Emp_Cons.Branch_ID))  --Modified By Ramiz on 17092014
							ORDER BY Emp_ID
		end 
		else
		begin
		 
    CREATE TABLE #Cmp_Cons             
   (                  
    Cmp_ID NUMERIC                 
   )  
   	INSERT INTO #Cmp_Cons
				SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Cmp_ID,'#') 
		    
  

	declare @company_Count as int
	set @company_Count =(SELECT COUNT(@Cmp_ID) FROM #Cmp_Cons)
	
	
	if(@company_Count>1)
	begin
		SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING S WITH (NOLOCK) 
		inner join #Cmp_Cons C on C.Cmp_ID=S.Cmp_ID
		WHERE S.Cmp_ID in(C.Cmp_ID) AND Setting_Name LIKE 'Show Left Employee for Salary'
	end 
	else
	 begin
	SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING S WITH (NOLOCK) 
		WHERE S.Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
	end
	--added by mansi  end 20-11-21
	
	   IF @Constraint <> ''
			BEGIN
			
			INSERT INTO #Emp_Cons
				SELECT CAST(DATA AS NUMERIC), CAST(DATA AS NUMERIC), CAST(DATA AS NUMERIC) FROM dbo.Split(@Constraint,'#') 
		    END
	    Else
		   
	         BEGIN
	              if(@company_Count>1)
				  begin 
				
					  INSERT INTO #Emp_Cons
		              SELECT DISTINCT emp_id,V_Emp_Cons.branch_id,Increment_ID --,V_Emp_Cons.Cmp_Id
		                FROM V_Emp_Cons 
							 inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on V_Emp_Cons.branch_id=g.branch_id
						     inner join #Cmp_Cons CC with (NOLOCK) on CC.Cmp_ID=V_Emp_Cons.Cmp_ID
						WHERE V_Emp_Cons.cmp_id in(CC.Cmp_ID)				
								--AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))   -- Comment by nilesh on 01112014
								AND ISNULL(Cat_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )  -- Added by nilesh on 01112014 
								AND ISNULL(Grd_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Grd_ID,ISNULL(Grd_Id,0)),'#') )  -- Added by nilesh on 26-08-2014  
								AND ISNULL(Dept_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID ,ISNULL(Dept_ID,0)),'#') )  -- Added by nilesh on 26-08-2014      
								AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
								AND ISNULL(Desig_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID ,ISNULL(Desig_ID,0)),'#') ) -- ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
								AND ISNULL(SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(SalDate_id,0))     
								--AND ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,ISNULL(Segment_ID,0))
								--AND ISNULL(Vertical_ID,0) = ISNULL(@Vertical,ISNULL(Vertical_ID,0))
								--AND ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,ISNULL(SubVertical_ID,0))
								--AND ISNULL(subBranch_ID,0) = ISNULL(@subBranch,ISNULL(subBranch_ID,0)) -- Added on 06082013 
								AND ISNULL(Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Segment_ID,ISNULL(Segment_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical,ISNULL(Vertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SubVertical,ISNULL(SubVertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@subBranch,ISNULL(subBranch_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(Emp_Id,0) = ISNULL(@Emp_Id,ISNULL(Emp_Id,0)) 
								AND Increment_Effective_Date <= @To_Date 
								AND ((@From_Date >= join_Date AND @From_Date <= left_date)      
									 OR (@To_Date >= join_Date AND @To_Date <= left_date)      
									 OR (Left_date IS NULL AND @To_Date >= Join_Date)      
									 OR (@To_Date >= left_date AND @From_Date <= left_date)
									 OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  
									 dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) 
									 as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
									)
								--AND V_Emp_Cons.branch_id in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint ,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								AND  ISNULL(V_Emp_Cons.branch_id,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK)
								   inner join #Cmp_Cons CC on CC.Cmp_ID=T0040_General_Setting.Cmp_ID
								where T0040_General_Setting.Cmp_ID in(CC.Cmp_ID) and Branch_ID = Isnull(@branch_id,V_Emp_Cons.Branch_ID))  --Modified By Ramiz on 17092014
							ORDER BY Emp_ID
							
				-- Comment by nilesh patel on 05122014 --Start			
					--Delete From #Emp_Cons Where Increment_ID Not In
					--(select TI.Increment_ID from t0095_increment TI inner join
					--(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
					--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
					--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
					--Where Increment_effective_Date <= @to_date)
				-- Comment by nilesh patel on 05122014 --End
				
				Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				 inner join #Cmp_Cons CC on CC.Cmp_ID=T0095_Increment.Cmp_ID
				Where Increment_effective_Date <= @to_date And T0095_Increment.Cmp_ID in(CC.Cmp_ID) Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
				Where Qry.Increment_ID is null

			 end 
	     else
				  begin
				   
		              INSERT INTO #Emp_Cons
		              SELECT DISTINCT emp_id,V_Emp_Cons.branch_id,Increment_ID
		                FROM V_Emp_Cons 
							 inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on V_Emp_Cons.branch_id=g.branch_id
						WHERE V_Emp_Cons.cmp_id=@Cmp_ID 				
								--AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))   -- Comment by nilesh on 01112014
								AND ISNULL(Cat_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )  -- Added by nilesh on 01112014 
								AND ISNULL(Grd_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Grd_ID,ISNULL(Grd_Id,0)),'#') )  -- Added by nilesh on 26-08-2014  
								AND ISNULL(Dept_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID ,ISNULL(Dept_ID,0)),'#') )  -- Added by nilesh on 26-08-2014      
								AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
								AND ISNULL(Desig_ID,0) in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID ,ISNULL(Desig_ID,0)),'#') ) -- ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
								AND ISNULL(SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(SalDate_id,0))     
								--AND ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,ISNULL(Segment_ID,0))
								--AND ISNULL(Vertical_ID,0) = ISNULL(@Vertical,ISNULL(Vertical_ID,0))
								--AND ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,ISNULL(SubVertical_ID,0))
								--AND ISNULL(subBranch_ID,0) = ISNULL(@subBranch,ISNULL(subBranch_ID,0)) -- Added on 06082013 
								AND ISNULL(Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Segment_ID,ISNULL(Segment_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical,ISNULL(Vertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SubVertical,ISNULL(SubVertical_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@subBranch,ISNULL(subBranch_ID,0)),'#') )  -- Added by nilesh on 03-Nov-2014 
								AND ISNULL(Emp_Id,0) = ISNULL(@Emp_Id,ISNULL(Emp_Id,0)) 
								AND Increment_Effective_Date <= @To_Date 
								--AND ((@From_Date >= join_Date AND @From_Date <= left_date)      
								--	 OR (@To_Date >= join_Date AND @To_Date <= left_date)      
								--	 OR (Left_date IS NULL AND @To_Date >= Join_Date)      
								--	 OR (@To_Date >= left_date AND @From_Date <= left_date)
								--	 OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  
								--	 dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) 
								--	 as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
								--	)
								--AND V_Emp_Cons.branch_id in( SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint ,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								AND  ISNULL(V_Emp_Cons.branch_id,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Constraint,ISNULL(V_Emp_Cons.branch_id,0)),'#') )
								and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = Isnull(@branch_id,V_Emp_Cons.Branch_ID))  --Modified By Ramiz on 17092014
							ORDER BY Emp_ID
				  
				 
							
				-- Comment by nilesh patel on 05122014 --Start			
					--Delete From #Emp_Cons Where Increment_ID Not In
					--(select TI.Increment_ID from t0095_increment TI inner join
					--(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
					--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
					--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
					--Where Increment_effective_Date <= @to_date)
				-- Comment by nilesh patel on 05122014 --End
				
				Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date And Cmp_ID = @Cmp_ID Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
				Where Qry.Increment_ID is null
				
				end

			
			End
		
		end
	--Added By Ramiz on 23022018 for Deleting those employees whose Left Date is Less then Join Date. This Case comes when Company transffered on Same Date of Joining--
	Delete #Emp_Cons From  #Emp_Cons EC
		INNER JOIN T0080_EMP_MASTER EM ON EC.EMP_ID = EM.EMP_ID AND EM.Date_Of_Join > isnull(EM.Emp_Left_Date , @To_Date)
	WHERE em.Emp_Left_Date IS NOT NULL		
	--select * from #Emp_Cons
	
END
 
