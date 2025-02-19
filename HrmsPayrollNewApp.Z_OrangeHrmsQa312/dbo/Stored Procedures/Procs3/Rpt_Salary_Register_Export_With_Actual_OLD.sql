
---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Salary_Register_Export_With_Actual_OLD]  
	@Company_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID        numeric = 0
	,@is_column tinyint = 0
	,@Salary_Cycle_id  numeric(18,0)= 0
AS  

 
 
 Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
  
	Declare @P_Days as numeric(22,2)
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
	Declare @Total_CTC As Numeric(22,2)	
 
	--Alpesh 25-Nov-2011
	Declare @Absent_Day numeric(18,2)
	Declare @Holiday_Day numeric(18,2)
	Declare @WeekOff_Day numeric(18,2)
	Declare @Leave_Day numeric(18,2)
	Declare @Sal_Cal_Day numeric(18,2)
	  
	  -- Rohit 05-oct-2012
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	declare @Fix_OT_Shift_Hours varchar(40)
	declare @Fix_OT_Shift_seconds numeric(18,2)
 
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
     If @Cat_ID = 0
        set @Cat_ID = null
    -- Comment and added By rohit on 11022013
    Declare @Sal_St_Date   Datetime    
	 Declare @Sal_end_Date   Datetime   
	
	 declare @manual_salary_period as numeric(18,0)
	 set @manual_salary_period = 0

	 If @Branch_ID is null
			Begin 
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Company_id)    
			End
		Else
			Begin
				select @Sal_St_Date  =Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Company_id)    
			End
   
	 if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   --set @OutOf_Days = @OutOf_Days
		  end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			   --set @OutOf_Days = @OutOf_Days    	         
		  end     
	 --else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		--  begin 
			
		--	   if @manual_salary_period = 0   
		--			Begin
					
		--			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		--			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		--			  -- set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
		--			   Set @From_Date = @Sal_St_Date
		--			   Set @To_Date = @Sal_End_Date
		--			End
		--		Else
		--			Begin
		--				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
		--			--	set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
		--				Set @From_Date = @Sal_St_Date
		--				Set @To_Date = @Sal_End_Date 
		--			End    
		--  end
    -- Ended By rohit on 11022013
    
    
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			--Insert Into @Emp_Cons(Emp_ID)
			--select  cast(data  as numeric) from dbo.Split (@Constraint,'#')
			Insert Into @Emp_Cons(Emp_ID)
			select DISTINCT  cast(Emp.Data  as numeric) from dbo.Split (@Constraint,'#') Emp
			Inner Join 
						(SELECT distinct Emp_ID from T0200_MONTHLY_SALARY WITH (NOLOCK)
						where Month_St_Date >= @From_Date and Month_End_Date <= @To_Date
						and Is_FNF = 0) MS on MS.Emp_ID =  cast(Emp.Data  as numeric)
			
		end
	else
		begin
		
			if isnull(@Salary_Cycle_id,0) = 0
				begin	
						
						Insert Into @Emp_Cons

							select DISTINCT I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
									( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
									dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID Inner Join
									T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = E.Emp_ID
									
										--(SELECT distinct Emp_ID from T0200_MONTHLY_SALARY 
										--	where Month_St_Date >= @From_Date and Month_End_Date <= @To_Date
										--and Is_FNF = 0) as MS on MS.Emp_ID = E.Emp_ID 						
								Where E.CMP_ID = @Company_id 
								and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
								and i.Grd_ID = isnull(@Grade_ID ,i.Grd_ID)
								and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
								and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
								and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
								and ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))
								and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @To_Date
										and ms.Is_FNF = 0
								and Date_Of_Join <= @To_Date and I.emp_id in(
									select e.Emp_Id from
									(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
									where cmp_id = @Company_id   and  
									(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
									or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
									or Emp_left_date is null and @To_Date >= Date_Of_Join)
									or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  and E.Emp_Left = 'N'
				End
			Else	
				begin
								declare @from_date_sal_temp datetime
								declare @to_date_sal_temp datetime
								
								select @from_date_sal_temp = Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id
								
								set @from_date_sal_temp =  cast(cast(day(@from_date_sal_temp)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
								set @to_date_sal_temp = dateadd(d,-1,dateadd(m,1,@from_date_sal_temp)) 
									
								Insert Into @Emp_Cons
								select  DISTINCT I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
										( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
										where Increment_Effective_date <= @to_date_sal_temp
										and Cmp_ID = @Company_id
										group by emp_ID  ) Qry on
										I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
										dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID Inner Join
												(SELECT distinct Emp_ID from T0200_MONTHLY_SALARY  WITH (NOLOCK)
													where Month_St_Date >= @From_Date and Month_End_Date <= @To_Date
												and Is_FNF = 0) MS on MS.Emp_ID = E.Emp_ID 
										LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																		WHERE Effective_date <= @to_date_sal_temp AND Cmp_id = @Company_id
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = I.Emp_ID						
									Where E.CMP_ID = @Company_id 
									and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
									and i.Grd_ID = isnull(@Grade_ID ,i.Grd_ID)
									and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
									and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))	
									AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id  ,ISNULL(QrySC.SalDate_id,0))   		
									and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
									and ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))
									--and ms.Month_St_Date >= @From_Date and ms.Month_End_Date <= @to_date_sal_temp
									--and ms.Is_FNF = 0
									and Date_Of_Join <= @to_date_sal_temp and I.emp_id in(
										select e.Emp_Id from
										(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @to_date_sal_temp) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
										where cmp_id = @Company_id   and  
										(( @from_date_sal_temp  >= Date_Of_Join  and  @from_date_sal_temp <= Emp_left_date ) 
										or ( @to_date_sal_temp  >= Date_Of_Join  and @to_date_sal_temp <= Emp_left_date )
										or Emp_left_date is null and @to_date_sal_temp >= Date_Of_Join)
										or @to_date_sal_temp >= Emp_left_date  and  @from_date_sal_temp <= Emp_left_date )  and E.Emp_Left = 'N'
				end
			
		end
	
			 
		 
	CREATE table #CTCMast
	(
		
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) primary key
	   ,Alpha_Emp_Code	varchar(50)
	   ,Emp_Full_Name	varchar(250)
	   ,Branch			nvarchar(100)
	   ,Department		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)	
	   ,Joining_Date	nvarchar(30)
	   ,Pan_No			varchar(50)
	   ,Present_Day		numeric(18,2)
	   ,Absent_Day		numeric(18,2)
	   ,Holiday_Day		numeric(18,2)
	   ,WeekOff_Day		numeric(18,2)
	   ,Inc_id			numeric(18)	   
	  -- ,Leave_Day		numeric(18,2)
	   --,Sal_Cal_Day		numeric(18,2)
	   --,CTC_Actual		Numeric(18,0)
	   --,Basic_Actual	Numeric(18,2)
	)
	
	Declare @AllColumns nvarchar(Max)
	
	Declare @Columns nvarchar(max)
	Declare @Leave_Columns nvarchar(Max)
	Declare @Leave_Name nvarchar(30)
	Set @Columns = '#'
	set @AllColumns = ''
	set @Leave_Columns = ''
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_INC_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)

	Declare @CTC_COLUMNS nvarchar(100)
	Declare @CTC_AD_FLAG varchar(1)
	Declare @Allow_Amount numeric(18,2)
	
	Declare @Basic_Salary_Actual Numeric(18,2)
	Declare @Total_Allowance_Actual Numeric(18,2)
	Declare @Total_Deduction_Actual Numeric(18,2)
	Declare @PT_Actual Numeric(18,2)
	Declare @Net_Salary_Actual Numeric(18,2)
	Declare @Allow_Amount_Actual numeric(18,2)
	Declare @Allow_Amount_Arrear numeric(18,2)
	Declare @Basic_Salary_Arrear Numeric(18,2)
	Declare @Gross_Amount Numeric(18,2)
		
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	declare @count_leave as numeric(18,2)
	set @CTC_INC_ID = 0
	set @count_leave = 0
	set @Gross_Amount = 0
	set @Basic_Salary_Arrear = 0
	set @Allow_Amount_Arrear =0
	
	 

	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Alpha_Emp_Code
	     ,ISNULL(e.EmpName_Alias_Salary,e.Emp_First_Name+' '+ e.Emp_Second_Name +' '+e.Emp_Last_Name) -- Added By Ali 19122013
	     ,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,convert(varchar,e.Date_Of_Join,103),Pan_No
	     ,0,0,0,0,Inc_Qry.Increment_ID  --,0,Inc_Qry.CTC,Inc_Qry.Basic_Salary
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC , I.Increment_ID,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_effective_Date) as For_Date , Emp_ID  from T0095_Increment WITH (NOLOCK)
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID   ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	
	
	
	DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la  WITH (NOLOCK)
				 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
		         inner join ( select I.Emp_Id ,Increment_effective_Date from T0095_Increment I  WITH (NOLOCK) inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				where  la.cmp_ID=@Company_id  and ((lad.From_Date >=@From_Date and lad.From_Date <=@To_Date	) or 	(lad.to_Date >=@From_Date and lad.to_Date <=@To_Date	))				  
				group by Leave_Name
	OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					
					Set @Leave_Columns = @Leave_Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					fetch next from Leave_Cursor into @Leave_Name
				End
	close Leave_Cursor	
	deallocate Leave_Cursor
	
	  --,Sal_Cal_Day		numeric(18,2)
	   --,CTC_Actual		Numeric(18,0)
	   --,Basic_Actual	Numeric(18,2)
	   
	   
	Set @val = 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0'
	exec (@val)	   
		   
	Set @val = 'Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0'
	exec (@val)	   
	   
	Set @val = 'Alter table  #CTCMast Add Sal_Cal_Day numeric(18,2) default 0'
	exec (@val)	
	
	Set @val = 'Alter table  #CTCMast Add CTC_Actual numeric(18,2) default 0'
	exec (@val)	
	
	Set @val = 'Alter table  #CTCMast Add Basic_Actual numeric(18,2) default 0'
	exec (@val)	
	
	delete #CTCMast
	-- Comment And Add by rohit For Grind master Grade Not Showing For Employee on 29052013
	--Insert Into #CTCMast (Cmp_ID,Emp_ID,Alpha_Emp_Code ,Emp_Full_Name,Branch,Department,Designation,Grade,TypeName,Joining_Date,Present_Day,Absent_Day,Holiday_Day,WeekOff_Day ,Inc_id ,Sal_Cal_Day,CTC_Actual,Basic_Actual) 
	--SELECT e.Cmp_ID,e.Emp_ID,e.Alpha_Emp_Code,e.Emp_First_Name+' '+ e.Emp_Second_Name +' '+e.Emp_Last_Name,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,convert(varchar,e.Date_Of_Join,103),
	--	 0,0,0,0,Inc_Qry.Increment_ID ,0,Inc_Qry.CTC,Inc_Qry.Basic_Salary
	--	from T0080_EMP_MASTER e	inner join
	--	( select I.Emp_id,I.Basic_Salary,I.CTC , I.Increment_ID  from T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and cmp_id = @Company_id
	--		group by emp_ID  ) Qry on
	--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date )Inc_Qry on 
	--	E.Emp_ID = Inc_Qry.Emp_ID 
	--inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	--left outer join T0030_BRANCH_MASTER bm on e.Branch_ID = bm.Branch_ID
	--left outer join T0040_GRADE_MASTER ga on e.Grd_ID = ga.Grd_ID
	--left outer join T0040_DEPARTMENT_MASTER dm on e.Dept_ID = dm.Dept_Id
	--left outer join T0040_DESIGNATION_MASTER dnm on e.Desig_Id = dnm.Desig_ID
	--left outer join T0040_TYPE_MASTER tm on e.Type_ID = tm.Type_ID
	
 
	-- Changed By Ali 22112013 EmpName_Alias
	Insert Into #CTCMast (Cmp_ID,Emp_ID,Alpha_Emp_Code ,Emp_Full_Name,Branch,Department,Designation,Grade,TypeName,Joining_Date,Present_Day,Absent_Day,Holiday_Day,WeekOff_Day ,Inc_id ,Sal_Cal_Day,CTC_Actual,Basic_Actual,Pan_no) 
	SELECT e.Cmp_ID,e.Emp_ID,e.Alpha_Emp_Code
		--,e.Emp_First_Name+' '+ e.Emp_Second_Name +' '+e.Emp_Last_Name
		,ISNULL(e.EmpName_Alias_Salary,e.Emp_First_Name+' '+ e.Emp_Second_Name +' '+e.Emp_Last_Name)
		,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,convert(varchar,e.Date_Of_Join,103),
		 0,0,0,0,Inc_Qry.Increment_ID ,0,Inc_Qry.CTC,Inc_Qry.Basic_Salary,Pan_No
		from T0080_EMP_MASTER e WITH (NOLOCK)	inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC , I.Increment_ID, I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID   from T0095_Increment I  WITH (NOLOCK) inner join 
			( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	
	
	
	---below cursor for Actual Allowances
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Inner Join @Emp_Cons Ec on T.Emp_Id = Ec.Emp_Id
		Where E_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and isnull(A.Ad_Not_Effect_Salary,0) = 0 
			and Ad_Active = 1 and AD_Flag = 'I' 
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',''),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_'),'__','_') + '_Actual numeric(18,2) default 0'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_'),'__','_') + '_Actual#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

		Set @val = 'Alter table  #CTCMast Add Gross_Salary_Actual numeric(18,2) default 0'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add PT_Amount_Actual numeric(18,2) default 0'
		exec (@val)	
	
		
	Declare Allow_Dedu_Cursor CURSOR FOR
		--		Select AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION T Inner Join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		--Where E_AD_Amount <> 0 And T.Cmp_ID = @Company_Id And FOR_DATE = 
		--		(Select MAX(FOR_DATE) From T0100_EMP_EARN_DEDUCTION Where Emp_Id = @CTC_EMP_ID And FOR_DATE <= @To_Date)
		--		and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D'
		--Group by AD_SORT_NAME 
		
		Select AD_SORT_NAME from T0100_EMP_EARN_DEDUCTION T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Inner Join @Emp_Cons Ec on T.Emp_Id = Ec.Emp_Id
		Where E_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and isnull(A.Ad_Not_Effect_Salary,0) = 0 
			and Ad_Active = 1 and AD_Flag = 'D'  and T.INCREMENT_ID  = @CTC_INC_ID
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_'),'__','_') + '_Actual numeric(18,2) default 0'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_'),'__','_') + '_Actual#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

		Set @val = 'Alter table  #CTCMast Add Total_Deduction_Actual numeric(18,2) default 0'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Amount_Actual numeric(18,2) default 0'
		exec (@val)	
		
		Set @val =''
		
		
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id,Inc_id from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_INC_ID
	while @@fetch_status = 0
		Begin	
			
			Set @Total_Allowance_Actual  = 0
			Set @Total_Deduction_Actual  = 0
			Set @PT_Actual  = 0
			Set @Net_Salary_Actual  = 0	
			Set @Basic_Salary_Actual = 0 
			Set @Allow_Amount_Actual = 0
				
			
						
			Select @Total_Allowance_Actual = Isnull(SUM(E_AD_Amount),0)
			From T0100_EMP_EARN_DEDUCTION T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) On T.AD_ID = A.AD_ID
			Where Emp_ID = @CTC_EMP_ID And E_AD_FLAG = 'I' And FOR_DATE = 
				(Select MAX(FOR_DATE) From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) Where Emp_Id = @CTC_EMP_ID And FOR_DATE <= @To_Date )
			and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1  and INCREMENT_ID = @CTC_INC_ID
			
			Select @Total_Deduction_Actual = Isnull(SUM(E_AD_Amount),0)
			From T0100_EMP_EARN_DEDUCTION T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) On T.AD_ID = A.AD_ID
			Where Emp_ID = @CTC_EMP_ID And E_AD_FLAG = 'D' And FOR_DATE = 
				(Select MAX(FOR_DATE) From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) Where Emp_Id = @CTC_EMP_ID And FOR_DATE <= @To_Date )
			and isnull(A.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1  and INCREMENT_ID = @CTC_INC_ID

			
			SELECT @PT_Actual = Isnull(Inc_Qry.Emp_PT_Amount,0),@Basic_Salary_Actual = Inc_Qry.Basic_Salary
			From @Emp_Cons ec Inner Join
				( select I.Emp_id,I.Emp_PT_Amount,I.Basic_Salary from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and cmp_id = @Company_id And Emp_ID	= @CTC_EMP_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date )Inc_Qry 
				on ec.Emp_ID = Inc_Qry.Emp_ID 
			Where ec.Emp_ID	= @CTC_EMP_ID 
			 

			update  #CTCMast set
				Gross_Salary_Actual = @Total_Allowance_Actual+@Basic_Salary_Actual,
				Total_Deduction_Actual = @Total_Deduction_Actual + @PT_Actual, PT_Amount_Actual = @PT_Actual,
				Net_Amount_Actual = (@Total_Allowance_Actual+@Basic_Salary_Actual) - (@Total_Deduction_Actual+ @PT_Actual)
			where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
			
			
			
			Declare CRU_COLUMNS CURSOR FOR
				Select data from Split(@Columns,'#') where data <> ''
			OPEN CRU_COLUMNS
					fetch next from CRU_COLUMNS into @CTC_COLUMNS
					while @@fetch_status = 0
						Begin				
								Set @Allow_Amount_Actual = 0	
								begin
										Set @CTC_COLUMNS = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
																				
										begin
												
											select @Allow_Amount_Actual=ded.E_AD_AMOUNT,@CTC_AD_FLAG=ded.E_AD_FLAG from T0100_EMP_EARN_DEDUCTION  ded WITH (NOLOCK)
												inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
												WHere  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim( Cast(ad.AD_Sort_Name + '_Actual' As varchar(200)) )),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')  = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
												--And FOR_DATE =(Select MAX(FOR_DATE) From T0100_EMP_EARN_DEDUCTION Where EMP_ID = @CTC_EMP_ID And FOR_DATE <= @To_Date  ) 
												 and INCREMENT_ID = @CTC_INC_ID
											
											Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Actual,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
											EXEC (@val)								   
											
										end
										
										Set @Allow_Amount = 0
										
								end
								
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
						End
			close CRU_COLUMNS	
			deallocate CRU_COLUMNS
					
	
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_INC_ID
	End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
		
	
	-----------------End Actual Calculation
	
	
		Set @val = 'Alter table  #CTCMast Add Basic_Salary numeric(18,2) default 0'
		exec (@val)	
		
		

		Set @val = 'Alter table  #CTCMast Add Settl_Salary numeric(18,2) default 0'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Other_Allow numeric(18,2) default 0'
		exec (@val)	
	
	
	set @AllColumns = @AllColumns + @Columns
	Set @Columns = ''	
		
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
		Set @val = 'Alter table  #CTCMast Add Total_Earning numeric(18,2) default 0  not null '
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Basic_Salary_Arrear numeric(18,2) default 0 not null'
		exec (@val)	


	-- below cursor is add for arrear amount by mitesh on 04/02/2012
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + '_Arrear numeric(18,2) default 0  not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '_Arrear#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

		Set @val = 'Alter table  #CTCMast Add Total_Arrear_Earning numeric(18,2) default 0 not null '
		exec (@val)			
		
			-- rohit on 05-oct-2012
		Set @val = 'Alter table  #CTCMast Add Holiday_OT_Hours numeric(18,2) default 0 not null'
		exec (@val)	
		Set @val = 'Alter table  #CTCMast Add Holiday_OT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		Set @val = 'Alter table  #CTCMast Add Weekoff_OT_Hours numeric(18,2) default 0 not null'
		exec (@val)	
		Set @val = 'Alter table  #CTCMast Add Weekoff_OT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add OT_Rate numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add OT_Hours numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add OT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Leave_Encash_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		-- ended by rohit on 05-oct-2012
		
		Set @val = 'Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0'
		exec (@val)	

	
	Declare Allow_Dedu_Cursor CURSOR FOR
				Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	Set @val = 'Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null '
	exec (@val)	
	
	
	-- below cursor is add for arrear amount by mitesh on 04/02/2012
	Declare Allow_Dedu_Cursor CURSOR FOR
				Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'D' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''','_'),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + '_Arrear numeric(18,2) default 0  not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '_Arrear#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
		

		Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Other_Dedu numeric(18,2) default 0'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Total_Arrear_Deduction numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Total_Deduction numeric(18,2) default 0'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0'
		exec (@val)	
	

--For CTC Cursor		
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

	------ below cursor is add for arrear amount by Hardik 28/08/2012
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		Select AD_SORT_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) inner JOIN 
		@Emp_Cons ec on ec.Emp_ID = T.Emp_ID Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and month(T.For_Date) =  MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0
		Group by AD_SORT_NAME 
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table  #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + '_Arrear numeric(18,2) default 0  not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '_Arrear#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

	----print 1
	------ End for CTC

		Set @val = 'Alter table  #CTCMast Add Total_CTC_Salary numeric(18,2) default 0'
		exec (@val)	
		Set @val = ''
		
		
		if @is_column = 1 
			begin 
			--	select * from #CTCMast
				Select ROW_NUMBER()  OVER (ORDER BY  MS.Emp_Id) As SrNo,CM.*,MS.Salary_Status,MS.Arear_Day,tmpia.Extra_Day_Month,INC.payment_mode,BM.bank_Name,Inc.Inc_bank_ac_no From #CTCMast CM 
					Inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on CM.Emp_ID = MS.Emp_ID 	
					inner join T0095_INCREMENT INC WITH (NOLOCK) on INC.Increment_ID = MS.Increment_id
					left outer join T0190_MONTHLY_PRESENT_IMPORT tmpia WITH (NOLOCK) on tmpia.Emp_ID = CM.Emp_ID and tmpia.Month = MONTH(@To_Date) and tmpia.Year = YEAR(@To_Date)
					Left Outer Join T0040_bank_master BM WITH (NOLOCK) On Inc.Bank_id = BM.Bank_id
				where Month(MS.Month_st_date) = Month(@From_Date) and Year(MS.Month_st_date) = Year(@From_Date)
				Order by CM.Alpha_Emp_code

				return
			end
		
	
	declare @total_paid_leave_cur numeric(18,2)
		
	
	set @AllColumns = @AllColumns + @Columns	
	
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id,Basic_Salary from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	while @@fetch_status = 0
		Begin	
			
			
			Set @P_Days =0 
			Set @Basic_Salary =0
			set @Basic_Salary_Arrear = 0
			Set @TDS = 0
			Set @Settl  = 0
			Set @OTher_Allow  = 0
			Set @Total_Allowance  = 0
			Set @CO_Amount  = 0
			Set @Total_Deduction  = 0
			Set @PT  = 0
			Set @Loan  = 0
			Set @Advance  = 0	
			Set @Net_Salary  = 0	
			Set @Revenue_Amt  = 0	
			Set @LWF_Amt  = 0	
			Set @Other_Dedu  = 0	
			set @total_paid_leave_cur = 0
			Set @Absent_Day = 0 
			Set @Holiday_Day = 0
			Set @WeekOff_Day = 0
			Set @Leave_Day = 0
			Set @Sal_Cal_Day = 0
			
						--rohit 25-oct-2012 for ot_rate
			set @OT_Hours = 0
			set @OT_AMount = 0
			Set @OT_Rate = 0
			set @Fix_OT_Shift_Hours = ''
			Set @Fix_OT_Shift_seconds = 0
			
			select @Basic_Salary = Salary_Amount,@P_Days = Present_Days,@Absent_Day=Absent_Days,@Holiday_Day=Holiday_Days,@WeekOff_Day=Weekoff_Days,@Leave_Day=Total_Leave_Days,@Sal_Cal_Day=Sal_Cal_Days, @TDS=isnull(M_IT_TAX,0),
				@Settl = Isnull(Settelement_Amount,0),@OTher_Allow = ISNULL(Other_Allow_Amount,0),
				@Total_Allowance = Isnull(Allow_Amount,0), @Basic_Salary_Arrear = Arear_Basic , @Gross_Amount = Gross_Salary
				,@total_paid_leave_cur = (Paid_Leave_Days + OD_Leave_Days)
			from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID and Month(Month_st_date) = Month(@From_Date) 
				and Year(Month_st_date) = Year(@From_Date)
				
			set @Gross_Amount = @Gross_Amount --+ @Settl 
			
			select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
					,@Advance =  Isnull(Advance_Amount,0) ,@Net_Salary = Net_Amount ,@Revenue_Amt = Isnull(Revenue_amount,0),@LWF_Amt =Isnull(LWF_Amount,0),@Other_Dedu= Isnull(Other_Dedu_Amount,0)
			from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID and Month(Month_st_date) = Month(@From_Date) 
				and Year(Month_st_date) = Year(@From_Date)

			Select @Total_CTC = Isnull(SUM(M_AD_Amount),0) 
			from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where T.Cmp_ID = @Company_Id and month(T.For_Date) = MONTH(@From_Date) and Year(T.For_Date) = YEAR(@From_Date)
				and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I'
				And T.Emp_ID = @CTC_EMP_ID and isnull(S_Sal_Tran_ID,0) = 0


			-----------Added by Ramiz on 16092014 --------------
			
			Declare @Branch_id_new numeric(18,2)
			select @Branch_id_new = Branch_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID =@CTC_EMP_ID and Cmp_ID = @CTC_CMP_ID
			select @Fix_OT_Shift_Hours = ot_fix_shift_hours from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Branch_ID = @Branch_id_new and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Branch_ID =@Branch_id_new)  --Modified By Ramiz on 16092014
			select @Fix_OT_Shift_seconds = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00')) 
			
			-----------Ended by Ramiz on 16092014 --------------


-- Added by rohit for Hours rate ,ot_amount and Ot_Hours on 26-sep-2012   --Commented By Ramiz on 16092014
					--select @Fix_OT_Shift_Hours = ot_fix_shift_hours from T0040_GENERAL_SETTING where Cmp_ID = @CTC_CMP_ID and Branch_ID = (select Branch_ID from T0080_EMP_MASTER  where Emp_ID =@CTC_EMP_ID and Cmp_ID = @CTC_CMP_ID)
					 --select @Fix_OT_Shift_seconds = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00')) 
					
					select @OT_Hours = sum(isnull(OT_Hours,0)),@OT_Amount=sum(isnull(OT_Amount,0)) ,
					@OT_Rate = case when isnull(@Fix_OT_Shift_seconds,0) = 0 then Hour_Salary else isnull(Day_Salary,0)* 3600/@Fix_OT_Shift_seconds end
					from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
						and Month_st_date between @From_Date and @To_Date
						group by Emp_ID,Hour_Salary,Day_Salary
						-- ended by rohit on 26-sep-2012

						
			update  #CTCMast set Basic_Salary = @Basic_Salary, Present_Day = @P_Days,Absent_Day=@Absent_Day,Holiday_Day=@Holiday_Day,WeekOff_Day=@WeekOff_Day,Sal_Cal_Day=@Sal_Cal_Day, Settl_Salary = @Settl,
				Other_Allow = @OTher_Allow
				--, Gross_Salary = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) -- commented by mitesh on 04/02/2012 for taking gross with arrear from salary
				,Total_Deduction = @PT + @Loan + @Advance
				,Gross_Salary = @Gross_Amount
				,Net_Total_Deduction = @Total_Deduction, PT_Amount = @PT,
				Loan_Amount = @Loan, Advance_Amount = @Advance, Revenue_Amount = @Revenue_Amt, LWF_Amount = @LWF_Amt,
				Other_Dedu = @Other_Dedu, Net_Amount = @Net_Salary , Basic_Salary_arrear =  @Basic_Salary_Arrear
				,Total_Earning = @Basic_Salary + isnull(@settl,0), Total_Arrear_Earning = @Basic_Salary_Arrear
				,OT_Hours=@OT_Hours,OT_Amount=@OT_Amount,OT_Rate=@OT_Rate -- Add by rohit on 05-dec-2012
				,Holiday_OT_Hours = ISNULL(ms.M_HO_OT_Hours,0),Holiday_OT_Amount=ISNULL(ms.M_HO_OT_Amount,0),Weekoff_OT_Hours=ISNULL(ms.M_WO_OT_Hours,0),Weekoff_OT_Amount=ISNULL(ms.M_WO_OT_Amount,0),leave_Encash_Amount=ISNULL(ms.Leave_Salary_Amount,0)
			
			from 	#CTCMast 
			left join T0200_MONTHLY_SALARY MS on #CTCMast.Emp_ID = MS.Emp_ID 	and Month(MS.Month_st_date) = Month(@From_Date) and Year(MS.Month_st_date) = Year(@From_Date)
			where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
			

			update  #CTCMast set Total_CTC_Salary = @Total_CTC + Gross_Salary
			where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
			
			
			Set @val = 	'update  #CTCMast set Total_Paid_Leave_Days  = ' + convert(nvarchar,isnull(@total_paid_leave_cur,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																														
											
			exec (@val)
			
			Declare CRU_COLUMNS CURSOR FOR
				Select data from Split(@Columns,'#') where data <> ''
			OPEN CRU_COLUMNS
					fetch next from CRU_COLUMNS into @CTC_COLUMNS
					while @@fetch_status = 0
						Begin					
								begin
										
										Set @CTC_COLUMNS = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
																				
										begin
											declare @not_effect_in_salary tinyint
											set @not_effect_in_salary = 1
											
											select @Allow_Amount=ded.M_AD_Amount,@CTC_AD_FLAG=ded.M_AD_Flag , @Allow_Amount_Arrear = isnull(M_AREAR_AMOUNT,0) , @not_effect_in_salary = ad.AD_NOT_EFFECT_SALARY from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
												inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
												WHere  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')  = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
												And MONTH(ded.For_Date) = MONTH(@From_Date) And YEAR(ded.For_Date) = YEAR(@From_Date)  and ad.AD_NOT_EFFECT_SALARY = 0 and isnull(S_Sal_Tran_ID,0) = 0
												

                                             if(isnull(@Allow_Amount,0)=0 and isnull(@Allow_Amount_Arrear,0)=0)
											begin
											  select @Allow_Amount=ded.M_AD_Amount,@CTC_AD_FLAG=ded.M_AD_Flag , @Allow_Amount_Arrear = isnull(M_AREAR_AMOUNT,0) , @not_effect_in_salary = ad.AD_NOT_EFFECT_SALARY from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
												inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
												WHere  Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_Sort_Name)),'+',''),'''',''),',',''),'.',''),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')  = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
												And MONTH(ded.For_Date) = MONTH(@From_Date) And YEAR(ded.For_Date) = YEAR(@From_Date)  and ad.AD_NOT_EFFECT_SALARY =1 and isnull(S_Sal_Tran_ID,0) = 0
											end

											
											Set @val = ''
											if  charindex('_Arrear',@CTC_COLUMNS) = 0 --and @not_effect_in_salary = 0  -- condition added by mitesh on 04/02/2012
												begin			
													
													if @CTC_AD_FLAG = 'I'
														begin
															if @not_effect_in_salary = 0
																begin
																	Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  @CTC_COLUMNS + '_Arrear' + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' , ' + ' Total_Earning = Total_Earning + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  ' Total_Arrear_Earning = Total_Arrear_Earning +  ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)														
																end
															else
																begin
																	Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  @CTC_COLUMNS + '_Arrear' + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) +  ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)														
																end
														end
													else if  @CTC_AD_FLAG = 'D'
														begin
															if @not_effect_in_salary = 0
																begin
																	Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  @CTC_COLUMNS + '_Arrear' + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' , ' + ' Total_Deduction = Total_Deduction + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  ' Total_Arrear_Deduction = Total_Arrear_Deduction +  ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																													
																end
															else
																begin
																	Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' , ' +  @CTC_COLUMNS + '_Arrear' + ' = ' + convert(nvarchar,isnull(@Allow_Amount_Arrear,0)) +  ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																													
																end
														end
												end
											else  if charindex('_Arrear',@CTC_COLUMNS) = 0
												begin
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																														
												end
										
											
											EXEC (@val)								   											
										end
										
										Set @Allow_Amount = 0		
										set @Allow_Amount_Arrear= 0										
								end
								
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
						End
			close CRU_COLUMNS	
			deallocate CRU_COLUMNS
			
			
	declare @leave_total numeric(18,2)		
	declare @leave_name_temp nvarchar(100)	
	
	set @count_leave = 0
	-- Leave detail cursor
	DECLARE Leave_Cursor CURSOR FOR
		Select data from Split(@Leave_Columns,'#') where data <> ''
	OPEN Leave_Cursor
		fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					
					set @leave_total = 0
					
					select @leave_total = SUM(isnull(lt.Leave_Used,0)) + SUM(isnull(lt.CompOff_Used,0)) from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join -- Changed By Gadriwala Muslim 02102014
					 T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID 
					 where LM.cmp_ID=@Company_id  and LT.For_Date  >=@From_Date and LT.For_Date  <=@To_Date and Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','') = @Leave_Name					 
							and LT.emp_id = @CTC_EMP_ID
					group by Leave_Name
									
					
					Set @val = 'update #CTCMast set ' + @Leave_Name + ' = ' +  convert(nvarchar,@leave_total) + ' Where emp_id = ' + convert(nvarchar,@CTC_EMP_ID )
					EXEC (@val)
					
					set @count_leave = @count_leave + @leave_total
					
					fetch next from Leave_Cursor into @Leave_Name
				End
	close Leave_Cursor
	deallocate Leave_Cursor
					
	
	
	Set @val = 'update #CTCMast set Total_Leave_Days = ' +  convert(nvarchar,@count_leave) + ' Where emp_id = ' + convert(nvarchar,@CTC_EMP_ID )
	EXEC (@val)
	
		fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	
	--select replace(@Columns,'#',',')
		
	------declare @valRemove nvarchar(max)
	------declare @valdrop nvarchar(max)
	------set @valdrop = 'CREATE table #ctcmaster drop colmnn'
	
	------set @valRemove = 'select sum(0' +  replace(@AllColumns,'#','),sum(') + '0) from #ctcMast'
		
	------print @valRemove
	
	------exec (@valRemove)
	 
	
	Select ROW_NUMBER()  OVER (ORDER BY  MS.Emp_Id) As SrNo,CM.*,MS.Salary_Status,MS.Arear_Day,tmpia.Extra_Day_Month,INC.payment_mode,BM.bank_Name,Inc.Inc_bank_ac_no,EM.Pan_No  From #CTCMast CM 
			Inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on CM.Emp_ID = MS.Emp_ID 	
			inner join T0095_INCREMENT INC WITH (NOLOCK) on INC.Increment_ID = MS.Increment_id
			left outer join T0190_MONTHLY_PRESENT_IMPORT tmpia WITH (NOLOCK) on tmpia.Emp_ID = CM.Emp_ID and tmpia.Month = MONTH(@To_Date) and tmpia.Year = YEAR(@To_Date)
			Left Outer Join T0040_bank_master BM WITH (NOLOCK) On Inc.Bank_id = BM.Bank_id
			inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = CM.Emp_id
	where Month(MS.Month_End_date) = Month(@To_Date) and Year(MS.Month_End_date) = Year(@To_Date)
	Order by Case When IsNumeric(CM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + CM.Alpha_Emp_Code, 20)
			When IsNumeric(CM.Alpha_Emp_Code) = 0 then Left(CM.Alpha_Emp_Code + Replicate('',21), 20)
				Else CM.Alpha_Emp_Code
			End
	--Order by --CM.Alpha_Emp_code
	--RIGHT(REPLICATE(N' ', 500) + CM.Alpha_Emp_code, 500) -- Changed by rohit on 30072013
		
Return




