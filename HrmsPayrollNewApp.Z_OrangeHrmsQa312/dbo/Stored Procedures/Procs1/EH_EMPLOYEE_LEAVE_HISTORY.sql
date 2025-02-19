



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_LEAVE_HISTORY]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(4000)
	,@Report_Call	varchar(20)='Net Salary'
	,@PBranch_ID    varchar(200) = '0'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		 if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date )
		   end 
		  else
		   Begin
		     Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date )
		   End
			
		end
		 
		Declare @Month numeric 
		Declare @Year numeric  
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )		
			begin
				drop table #Yearly_Salary 
			end
			 
		CREATE table #Yearly_Salary 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,				
				Lable_Name		varchar(100),
				Month_1			numeric(18,2) default 0,
				Month_2			numeric(18,2) default 0,
				Month_3			numeric(18,2) default 0,
				Month_4			numeric(18,2) default 0,
				Month_5			numeric(18,2) default 0,
				Month_6			numeric(18,2) default 0,
				Month_7			numeric(18,2) default 0,
				Month_8			numeric(18,2) default 0,
				Month_9			numeric(18,2) default 0,
				Month_10		numeric(18,2) default 0,
				Month_11		numeric(18,2) default 0,
				Month_12		numeric(18,2) default 0,
				Total			numeric(18,2) default 0,
				
			)
	
			CREATE table #Yearly_Salary_Report 
			(
			    NetAmount numeric(18,2),
			    Month_1  Varchar(50)  					
			)	
			

			
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Lable_Name)
			select @Cmp_ID,emp_ID,'NET SALARY' From @Emp_Cons 
						
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		
		while @Temp_Date <=@To_Date 
			Begin
					set @Month = Month(@Temp_date)
					set @Year = Year(@Temp_Date)
					set @count = Month(@Temp_date)
					 
					
				if @count = 1 
					begin
																										
						Update #Yearly_Salary		
						set Month_1 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_1, 'Jan-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
						
						
						
					end

				else if @count = 2
					begin
						
																												
						Update #Yearly_Salary		
						set Month_2 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						
						insert into #Yearly_Salary_Report
						SELECT Month_2, 'FEB-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
						

					end	
				else if @count = 3
					begin
						Update #Yearly_Salary		
						set Month_3 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_3, 'MAR-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 

					end	
				else if @count = 4
					begin
						
						
						
						Update #Yearly_Salary		
						set Month_4 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
							insert into #Yearly_Salary_Report
						SELECT Month_4, 'APR-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
						
					end	
				else if @count = 5
					begin
																								
						Update #Yearly_Salary		
						set Month_5 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
							insert into #Yearly_Salary_Report
						SELECT Month_5, 'MAY-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 

					end	
				else if @count = 6
					begin
						
							
						Update #Yearly_Salary		
						set Month_6 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						
						
							insert into #Yearly_Salary_Report
						SELECT Month_6, 'JUNE-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
							
						
							
					end	
				else if @count = 7
					begin
						

																								
						Update #Yearly_Salary		
						set Month_7 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						
							insert into #Yearly_Salary_Report
						SELECT Month_7, 'JULY-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
					end	
				else if @count = 8
					begin
																								
						Update #Yearly_Salary		
						set Month_8 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_8, 'AUG-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
						
					end	
				else if @count = 9
					begin
							Update #Yearly_Salary		
						set Month_9 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_9, 'SEP-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 

					end	
				else if @count = 10
					begin
																							
						Update #Yearly_Salary		
						set Month_10 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_10, 'OCT-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary 
					end	
				else if @count = 11
					begin
						
																												
						Update #Yearly_Salary		
						set Month_11 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_11, 'NOV-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary
						
					end	
				else if @count = 12
					begin
																												
						Update #Yearly_Salary		
						set Month_11 = Net_Amount
						From #Yearly_Salary  Ys   inner JOIN
						(SELECT Emp_ID, SUM(Net_Amount) as Net_Amount, Month1,Year1 from T0200_MONTHLY_SALARY WITH (NOLOCK)
						group BY Emp_ID, Month1,Year1
						)MS ON Ys.Emp_Id = MS.Emp_ID																								
						Where ms.Month1 = @Month and Year1 = @Year
						
						insert into #Yearly_Salary_Report
						SELECT Month_12, 'DEC-'+ ' ' +cast(@Year AS varchar(10))   from #Yearly_Salary
					end						
																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End

				
				select Month_1 as [Month], NetAmount from #Yearly_Salary_Report		
					
	
		
	RETURN



