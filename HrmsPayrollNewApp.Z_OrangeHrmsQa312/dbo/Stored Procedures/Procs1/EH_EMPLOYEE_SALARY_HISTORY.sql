

-- Last Change by Nilesh Patel on 18112015 For Hide Salary details when Employee salary is not published.
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_SALARY_HISTORY]
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
	,@admin_user    numeric =0
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
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
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
			
		   End
			
		end
		 
		 
		 
		Declare @Month numeric 
		Declare @Year numeric  
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )		
			begin
				drop table #Yearly_Salary 
			end
			
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary_Report' )		
			begin
				drop table #Yearly_Salary_Report 
			end
			 
		CREATE TABLE #Yearly_Salary 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,				
				Lable_Name		varchar(100),

				Dedu_Amount1			numeric(18,2) default 0,
				BasicSalary1			numeric(18,2) default 0,
				GrossSalary1			numeric(18,2) default 0,

				Dedu_Amount2			numeric(18,2) default 0,
				BasicSalary2			numeric(18,2) default 0,
				GrossSalary2			numeric(18,2) default 0,

				Dedu_Amount3			numeric(18,2) default 0,
				BasicSalary3			numeric(18,2) default 0,
				GrossSalary3			numeric(18,2) default 0,
				
				Dedu_Amount4			numeric(18,2) default 0,
				BasicSalary4			numeric(18,2) default 0,
				GrossSalary4			numeric(18,2) default 0,
				
				Dedu_Amount5			numeric(18,2) default 0,
				BasicSalary5			numeric(18,2) default 0,
				GrossSalary5			numeric(18,2) default 0,
				
				Dedu_Amount6			numeric(18,2) default 0,
				BasicSalary6			numeric(18,2) default 0,
				GrossSalary6			numeric(18,2) default 0,
				
				Dedu_Amount7			numeric(18,2) default 0,
				BasicSalary7			numeric(18,2) default 0,
				GrossSalary7			numeric(18,2) default 0,
				
				Dedu_Amount8			numeric(18,2) default 0,
				BasicSalary8			numeric(18,2) default 0,
				GrossSalary8			numeric(18,2) default 0,
				
				Dedu_Amount9			numeric(18,2) default 0,
				BasicSalary9			numeric(18,2) default 0,
				GrossSalary9			numeric(18,2) default 0,
				
				Dedu_Amount10			numeric(18,2) default 0,
				BasicSalary10			numeric(18,2) default 0,
				GrossSalary10			numeric(18,2) default 0,
				
				Dedu_Amount11			numeric(18,2) default 0,
				BasicSalary11			numeric(18,2) default 0,
				GrossSalary11			numeric(18,2) default 0,
				
				Dedu_Amount12			numeric(18,2) default 0,
				BasicSalary12			numeric(18,2) default 0,
				GrossSalary12			numeric(18,2) default 0,
				
				T_Deduction_Amount  numeric(18,2) default 0,
				T_GrossSalary  numeric(18,2) default 0,
				T_BasicSalary  numeric(18,2) default 0,
				
			)
	
			CREATE TABLE #Yearly_Salary_Report 
			(
			    ROW_ID int identity,
			    Deduction_Amount numeric(18,2),
			    GrossSalary numeric(18,2),
			    BasicSalary numeric(18,2),
			    Month_1  Varchar(255),
			    mONTH_2   NUMERIC  					
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
						if @admin_user <> 0
					       begin
							If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation --Added By Mukti Sal_Type(30062016) 
								BEGIN						
									Update #Yearly_Salary		
									set Dedu_Amount1 = Dedu_amount, GrossSalary1=Gross_Salary, BasicSalary1=MS.Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount1,GrossSalary1,BasicSalary1, 'JAN-'+ '' +cast(@Year AS varchar(10)),1   from #Yearly_Salary
								END
							ELSE
								 BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount1 = 0, GrossSalary1=0, BasicSalary1=0
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount1,GrossSalary1,BasicSalary1, 'JAN-'+ '' +cast(@Year AS varchar(10)),1   from #Yearly_Salary
							 
									Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
									where MOnth_2= @Month
								END
						end
					else
						begin
							If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Nilesh Patel on 18112015
								BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount1 = Dedu_amount, GrossSalary1=Gross_Salary, BasicSalary1=MS.Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
										Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
											
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount1,GrossSalary1,BasicSalary1, 'JAN-'+ '' +cast(@Year AS varchar(10)),1   from #Yearly_Salary
								End
							Else
								Begin
									insert into #Yearly_Salary_Report
									SELECT 0,0,0, 'JAN-'+ '' +cast(@Year AS varchar(10)),1   from #Yearly_Salary
								End
						end
					End	
				else if @count = 2
					begin
						if @admin_user <> 0
							begin
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount2 = Dedu_amount, GrossSalary2=Gross_Salary, BasicSalary2=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount2,GrossSalary2,BasicSalary2, 'FEB-'+ '' +cast(@Year AS varchar(10)),2   from #Yearly_Salary 											
									END
								ELSE
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount2 = 0, GrossSalary2=0, BasicSalary2=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount2,GrossSalary2,BasicSalary2, 'FEB-'+ '' +cast(@Year AS varchar(10)),2   from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
											BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
												where MOnth_2= @Month
									END						
								END																																																				
						end	
					else
						begin
							If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN	
									Update #Yearly_Salary		
									set Dedu_Amount2 = Dedu_amount, GrossSalary2=Gross_Salary, BasicSalary2=Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount2,GrossSalary2,BasicSalary2, 'FEB-'+ '' +cast(@Year AS varchar(10)),2   from #Yearly_Salary
								End
							Else
								Begin
									insert into #Yearly_Salary_Report
									SELECT 0,0,0, 'FEB-'+ '' +cast(@Year AS varchar(10)),2   from #Yearly_Salary
								End
						End
					end
				else if @count = 3
					begin
					
					if @admin_user <> 0
						BEGIN
							If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount3 = Dedu_amount, GrossSalary3=Gross_Salary, BasicSalary3=Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount3,GrossSalary3,BasicSalary3, 'MAR-'+ '' +cast(@Year AS varchar(10)),3   from #Yearly_Salary 
								END
							ELSE
								BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount3 = 0, GrossSalary3=0, BasicSalary3=0
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount3,GrossSalary3,BasicSalary3, 'MAR-'+ '' +cast(@Year AS varchar(10)),3   from #Yearly_Salary
									
									If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
										BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
												where MOnth_2= @Month	
										End
								END
						end
					else
						begin
							If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount3 = Dedu_amount, GrossSalary3=Gross_Salary, BasicSalary3=Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount3,GrossSalary3,BasicSalary3, 'MAR-'+ '' +cast(@Year AS varchar(10)),3   from #Yearly_Salary
								End
							Else
								Begin
									insert into #Yearly_Salary_Report
									SELECT 0,0,0, 'MAR-'+ '' +cast(@Year AS varchar(10)),3   from #Yearly_Salary
								End 
						end	
					end
				else if @count = 4
					begin
						if @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount4 = Dedu_amount, GrossSalary4=Gross_Salary, BasicSalary4=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount4,GrossSalary4,BasicSalary4, 'APR-'+ '' +cast(@Year AS varchar(10)),4   from #Yearly_Salary 
							
									END
								ELSE
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount4 = 0, GrossSalary4=0, BasicSalary4=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount4,GrossSalary4,BasicSalary4, 'APR-'+ '' +cast(@Year AS varchar(10)),4   from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
											BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
												where MOnth_2= @Month
											END
									END
							end	
						else
							begin
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount4 = Dedu_amount, GrossSalary4=Gross_Salary, BasicSalary4=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount4,GrossSalary4,BasicSalary4, 'APR-'+ '' +cast(@Year AS varchar(10)),4   from #Yearly_Salary
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'APR-'+ '' +cast(@Year AS varchar(10)),4   from #Yearly_Salary
									End
							end
						end
				else if @count = 5
					begin
						if @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount5 = Dedu_amount, GrossSalary5=Gross_Salary, BasicSalary5=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount5,GrossSalary5,BasicSalary5, 'MAY-'+ '' +cast(@Year AS varchar(10)),5   from #Yearly_Salary
									END
								ELSE
									BEGIN				
										Update #Yearly_Salary		
										set Dedu_Amount5 = 0, GrossSalary5=0, BasicSalary5=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount5,GrossSalary5,BasicSalary5, 'MAY-'+ '' +cast(@Year AS varchar(10)),5   from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
										BEGIN
											Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
											where MOnth_2= @Month
										END
									END		
							end
					else
						BEGIN
							If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN
									Update #Yearly_Salary		
									set Dedu_Amount5 = Dedu_amount, GrossSalary5=Gross_Salary, BasicSalary5=Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount5,GrossSalary5,BasicSalary5, 'MAY-'+ '' +cast(@Year AS varchar(10)),5   from #Yearly_Salary 
								End
							Else
								Begin
									insert into #Yearly_Salary_Report
									SELECT 0,0,0, 'MAY-'+ '' +cast(@Year AS varchar(10)),5   from #Yearly_Salary 						
								End
						end
					end	
				else if @count = 6
					begin
					 IF @admin_user <> 0
						BEGIN
						 If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							
								Update #Yearly_Salary		
								set Dedu_Amount6 = Dedu_amount, GrossSalary6=Gross_Salary, BasicSalary6=Net_Amount
								From #Yearly_Salary  Ys   inner JOIN
								(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
									SUM(Net_Amount) as Net_Amount,
								 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
								group BY Emp_ID,Month_End_Date
								)MS ON Ys.Emp_Id = MS.Emp_ID																								
								Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
								
								insert into #Yearly_Salary_Report
								SELECT Dedu_Amount6,GrossSalary6,BasicSalary6, 'JUNE-'+ '' +cast(@Year AS varchar(10)),6   from #Yearly_Salary 													
						
							END
						ELSE
							BEGIN
								Update #Yearly_Salary		
								set Dedu_Amount6 = 0, GrossSalary6=0, BasicSalary6=0
								From #Yearly_Salary  Ys   inner JOIN
								(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
									SUM(Net_Amount) as Net_Amount,
								 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
								group BY Emp_ID,Month_End_Date
								)MS ON Ys.Emp_Id = MS.Emp_ID																								
								Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
								
								insert into #Yearly_Salary_Report
								SELECT Dedu_Amount6,GrossSalary6,BasicSalary6, 'JUNE-'+ '' +cast(@Year AS varchar(10)),6   from #Yearly_Salary 
									
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
										where MOnth_2= @Month
									END
								END
							END
						ELSE
							BEGIN
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount6 = Dedu_amount, GrossSalary6=Gross_Salary, BasicSalary6=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount6,GrossSalary6,BasicSalary6, 'JUNE-'+ '' +cast(@Year AS varchar(10)),6   from #Yearly_Salary
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount6,GrossSalary6,BasicSalary6, 'JUNE-'+ '' +cast(@Year AS varchar(10)),6   from #Yearly_Salary
									End
							END
						end	
				else if @count = 7
					begin
						IF @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount7 = Dedu_amount, GrossSalary7=Gross_Salary, BasicSalary7=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount7,GrossSalary6,BasicSalary6, 'JULY-'+ '' +cast(@Year AS varchar(10)),7   from #Yearly_Salary 
									END
								ELSE
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount7 = 0, GrossSalary7=0, BasicSalary7=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount7,GrossSalary7,BasicSalary7, 'JULY-'+ '' +cast(@Year AS varchar(10)),7   from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
										BEGIN
											
											Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
											where MOnth_2= @Month
										END
									END																		
								END
						ELSE
							BEGIN
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
								
										Update #Yearly_Salary		
										set Dedu_Amount7 = Dedu_amount, GrossSalary7=Gross_Salary, BasicSalary7=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount7,GrossSalary7,BasicSalary7, 'JULY-'+ '' +cast(@Year AS varchar(10)),7   from #Yearly_Salary 
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'JULY-'+ '' +cast(@Year AS varchar(10)),7   from #Yearly_Salary 
									End
								END
						end	
				else if @count = 8
					begin
						IF @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount8 = Dedu_amount, GrossSalary8=Gross_Salary, BasicSalary8=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount8,GrossSalary8,BasicSalary8, 'AUG-'+ '' +cast(@Year AS varchar(10)) ,7  from #Yearly_Salary
							
									END	
								ELSE
									BEGIN
						
										Update #Yearly_Salary		
										set Dedu_Amount8 = 0, GrossSalary8=0, BasicSalary8=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount8,GrossSalary8,BasicSalary8, 'AUG-'+ '' +cast(@Year AS varchar(10)) ,7  from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
											BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
												where MOnth_2= @Month
											END
									END
							end
						else
							BEGIN
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
								
										Update #Yearly_Salary		
										set Dedu_Amount8 = Dedu_amount, GrossSalary8=Gross_Salary, BasicSalary8=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount8,GrossSalary8,BasicSalary8, 'AUG-'+ '' +cast(@Year AS varchar(10)) ,7  from #Yearly_Salary 
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'AUG-'+ '' +cast(@Year AS varchar(10)) ,7  from #Yearly_Salary 
									End
							end																		
						end	
				else if @count = 9
					begin
						IF @admin_user <> 0
						BEGIN
							If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount9 = Dedu_amount, GrossSalary9=Gross_Salary, BasicSalary9=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount9,GrossSalary9,BasicSalary9, 'SEP-'+ '' +cast(@Year AS varchar(10)),8   from #Yearly_Salary
								
								END
							ELSE
								BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount9 = 0, GrossSalary9=0, BasicSalary9=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount9,GrossSalary9,BasicSalary9, 'SEP-'+ '' +cast(@Year AS varchar(10)),8   from #Yearly_Salary 
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
											BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
												where MOnth_2= @Month
											END
										END
								end
						else
						  BEGIN
							If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
								BEGIN
					  				Update #Yearly_Salary		
									set Dedu_Amount9 = Dedu_amount, GrossSalary9=Gross_Salary, BasicSalary9=Net_Amount
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID, Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount9,GrossSalary9,BasicSalary9, 'SEP-'+ '' +cast(@Year AS varchar(10)),8   from #Yearly_Salary
								End
							Else
								Begin
									insert into #Yearly_Salary_Report
									SELECT 0,0,0, 'SEP-'+ '' +cast(@Year AS varchar(10)),8   from #Yearly_Salary
								End
						  end	
					 end	
				else if @count = 10
					begin
						IF @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount10 = Dedu_amount, GrossSalary10=Gross_Salary, BasicSalary10=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount10,GrossSalary10,BasicSalary10, 'OCT-'+ '' +cast(@Year AS varchar(10)),9   from #Yearly_Salary 
						
									END
								ELSE
									BEGIN												
										Update #Yearly_Salary		
										set Dedu_Amount10 = 0, GrossSalary10=0, BasicSalary10=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
						
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount10,GrossSalary10,BasicSalary10, 'OCT-'+ '' +cast(@Year AS varchar(10)),9   from #Yearly_Salary 
						
						
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
										BEGIN
											Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
											where MOnth_2= @Month
										END
						
									END
						
								end
						else
							BEGIN
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount10 = Dedu_amount, GrossSalary10=Gross_Salary, BasicSalary10=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount10,GrossSalary10,BasicSalary10, 'OCT-'+ '' +cast(@Year AS varchar(10)),9   from #Yearly_Salary
									END
								Else
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'OCT-'+ '' +cast(@Year AS varchar(10)),9   from #Yearly_Salary
								end
						end	
				else if @count = 11
					begin
						IF @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set  Dedu_Amount11 = Dedu_amount, GrossSalary11=Gross_Salary, BasicSalary11=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount11,GrossSalary11,BasicSalary11, 'NOV-'+ '' +cast(@Year AS varchar(10)),10   from #Yearly_Salary
									END
								ELSE
									BEGIN
									
									Update #Yearly_Salary		
									set  Dedu_Amount11 = 0, GrossSalary11=0, BasicSalary11=0
									From #Yearly_Salary  Ys   inner JOIN
									(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
										SUM(Net_Amount) as Net_Amount,
									  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
									group BY Emp_ID,Month_End_Date
									)MS ON Ys.Emp_Id = MS.Emp_ID																								
									Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
									
									insert into #Yearly_Salary_Report
									SELECT Dedu_Amount11,GrossSalary11,BasicSalary11, 'NOV-'+ '' +cast(@Year AS varchar(10)),10   from #Yearly_Salary
									
									If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
										BEGIN
											Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
											where MOnth_2= @Month
										END
									END																					
								end
						else
							BEGIN
								If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
					    				Update #Yearly_Salary		
										set  Dedu_Amount11 = Dedu_amount, GrossSalary11=Gross_Salary, BasicSalary11=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										  Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID,Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount11,GrossSalary11,BasicSalary11, 'NOV-'+ '' +cast(@Year AS varchar(10)),10   from #Yearly_Salary
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'NOV-'+ '' +cast(@Year AS varchar(10)),10   from #Yearly_Salary
									End
								end
						end	
				else if @count = 12
					begin
						IF @admin_user <> 0
							BEGIN
								If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount12 = Dedu_amount, GrossSalary12=Gross_Salary, BasicSalary12=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount12,GrossSalary12,BasicSalary12, 'DEC-'+ '' +cast(@Year AS varchar(10)),11   from #Yearly_Salary
									END
								ELSE
									BEGIN
										Update #Yearly_Salary		
										set Dedu_Amount12 = 0, GrossSalary12=0, BasicSalary12=0
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount12,GrossSalary12,BasicSalary12, 'DEC-'+ ' ' +cast(@Year AS varchar(10)),11   from #Yearly_Salary
										
										If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
											BEGIN
												Update #Yearly_Salary_Report set Deduction_Amount=0, GrossSalary=0, BasicSalary=0
											--	where Month_1 = 'DEC-' + convert(NVARCHAR(4),right(@Year,4))
											where MOnth_2= @Month
											END
										END
								   End
							else
								BEGIN
								 If exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year AND Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
									BEGIN
							   
					   					Update #Yearly_Salary		
										set Dedu_Amount12 = Dedu_amount, GrossSalary12=Gross_Salary, BasicSalary12=Net_Amount
										From #Yearly_Salary  Ys   inner JOIN
										(SELECT Emp_ID, SUM(Total_Dedu_Amount) as Dedu_amount,SUM(Gross_Salary) as Gross_Salary,
											SUM(Net_Amount) as Net_Amount,
										 Month_End_Date from T0200_MONTHLY_SALARY WITH (NOLOCK)
										group BY Emp_ID, Month_End_Date
										)MS ON Ys.Emp_Id = MS.Emp_ID																								
										Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year
										
										insert into #Yearly_Salary_Report
										SELECT Dedu_Amount12,GrossSalary12,BasicSalary12, 'DEC-'+ '' +cast(@Year AS varchar(10)),11   from #Yearly_Salary
									End
								Else
									Begin
										insert into #Yearly_Salary_Report
										SELECT 0,0,0, 'DEC-'+ '' +cast(@Year AS varchar(10)),11   from #Yearly_Salary
									End
						end
					end																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
			End
			
		   Update #Yearly_Salary 
		   set T_Deduction_Amount = Dedu_Amount1 + Dedu_Amount2 + Dedu_Amount3 + Dedu_Amount4 + Dedu_Amount5 + Dedu_Amount6
								+ Dedu_Amount7 + Dedu_Amount8 + Dedu_Amount9 + Dedu_Amount10 + Dedu_Amount11 +Dedu_Amount12		
		   	
		   Update #Yearly_Salary 
		   set T_GrossSalary = GrossSalary1 + GrossSalary2 + GrossSalary3 + GrossSalary4 + GrossSalary5 + GrossSalary6
							  + GrossSalary7 + GrossSalary8 + GrossSalary9 + GrossSalary10 + GrossSalary11 +GrossSalary12	
		
		   Update #Yearly_Salary 
		   set T_BasicSalary = BasicSalary1 + BasicSalary2 + BasicSalary3 + BasicSalary4 + BasicSalary5 + BasicSalary6
								+ BasicSalary7 + BasicSalary8 + BasicSalary9 + BasicSalary10 + BasicSalary11 +BasicSalary12	
    
			Insert INTO #Yearly_Salary_Report 
			SELECT T_Deduction_Amount,T_GrossSalary,T_BasicSalary,'<font color="green" size="2	" font-family="verdana"   >Total</font>',13 
			from #Yearly_Salary
			
			select  ROW_NUMBER() OVER (ORDER BY Row_ID) AS RowNumber	,Month_1,isnull(GrossSalary,0) as GrossSalary ,
			isnull(BasicSalary,0) as BasicSalary,
			isnull(Deduction_Amount,0) as Deduction_Amount
			from #Yearly_Salary_Report 
			
	RETURN




