
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GRAPHICS_REPORT_YEARLY]
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
	,@constraint 	varchar(MAX)
	,@Report_Call	varchar(20)='Net Salary'
	,@PBranch_ID    varchar(max) = '0'   --Change By Jaina 11-12-2015 (max)
	,@Publish_Flag tinyint =0 --Added by Sumit on 16062016 for getting report while unpublish salary
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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) 
					INNER JOIN (SELECT MAX(Increment_ID) as increment_id, I1.Emp_ID
								FROM T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (select max(Increment_effective_Date) as For_Date , Emp_ID 
													from T0095_Increment WITH (NOLOCK)
													where Increment_Effective_date <= @To_date
															and Cmp_ID = @Cmp_ID
													group by emp_ID  ) I2 on I1.Increment_Effective_Date=I2.For_Date AND I1.Emp_ID=I2.Emp_ID
								GROUP BY I1.Emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID		
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

				select I.Emp_Id from T0095_Increment I WITH (NOLOCK)
						INNER JOIN (SELECT MAX(Increment_ID) as increment_id, I1.Emp_ID
									FROM T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (select max(Increment_effective_Date) as For_Date , Emp_ID 
														from T0095_Increment WITH (NOLOCK)
														where Increment_Effective_date <= @To_date
																and Cmp_ID = @Cmp_ID
														group by emp_ID  ) I2 on I1.Increment_Effective_Date=I2.For_Date AND I1.Emp_ID=I2.Emp_ID
									GROUP BY I1.Emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	
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
		END
		 
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
				Def_ID			Numeric ,
				Lable_Name		varchar(100),
				Month_1			numeric default 0,
				Month_2			numeric default 0,
				Month_3			numeric default 0,
				Month_4			numeric default 0,
				Month_5			numeric default 0,
				Month_6			numeric default 0,
				Month_7			numeric default 0,
				Month_8			numeric default 0,
				Month_9			numeric default 0,
				Month_10		numeric default 0,
				Month_11		numeric default 0,
				Month_12		numeric default 0,
				Total			numeric default 0,
				AD_ID			numeric, 
				LOAN_ID			NUMERIC,
				CLAIM_ID		NUMERIC
			)
	
			CREATE table #Yearly_Salary_Report 
			(
			    NetAmount numeric(18,2),
			    Month_1  Varchar(50)  					
			)	
			

			
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,15,'NET SALARY' From @Emp_Cons 
						
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
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15 
							
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_1) as NetAmount,'Jan-' + convert(NVARCHAR(4),right(@Year,2))   from  #Yearly_Salary where Cmp_id=@Cmp_ID
						
						--Select Publish_ID from T0250_SALARY_PUBLISH_ESS where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and @Publish_Flag=0
						
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation --Added By Mukti Sal_Type(30062016)  
							BEGIN							
								if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Jan-' + convert(NVARCHAR(4),right(@Year,2))
									End
								
							END
					end

				else if @count = 2
					begin
						
																												
						Update #Yearly_Salary		
						set Month_2 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
							
					insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_2) as NetAmount,'Feb-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
						
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
									Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Feb-' + convert(NVARCHAR(4),right(@Year,2))
									End
								
							END

					end	
				else if @count = 3
					begin
						Update #Yearly_Salary		
						set Month_3 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
						
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_3) as NetAmount,'Mar-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
						
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Mar-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END

					end	
				else if @count = 4
					begin
						
																												
						Update #Yearly_Salary		
						set Month_4 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15

						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_4) as NetAmount,'Apri-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
							
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Apri-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
						
					end	
				else if @count = 5
					begin
																								
						Update #Yearly_Salary		
						set Month_5 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
							
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_5) as NetAmount,'May-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
						
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'May-' + convert(NVARCHAR(4),right(@Year,2))
									End
							END

					end	
				else if @count = 6
					begin
						
																												
						Update #Yearly_Salary		
						set Month_6 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_6) as NetAmount,'June-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
							
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'June-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
						
					end	
				else if @count = 7
					begin
						

																								
						Update #Yearly_Salary		
						set Month_7 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
							
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_7) as NetAmount,'July-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
					
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'July-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
					end	
				else if @count = 8
					begin
																								
						Update #Yearly_Salary		
						set Month_8 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
							
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_8) as NetAmount,'Aug-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
					
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Aug-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
						
					end	
				else if @count = 9
					begin
																							
						Update #Yearly_Salary		
						set Month_9 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
							
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_9) as NetAmount,'Sept-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
					
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Sept-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END

					end	
				else if @count = 10
					begin
																							
						Update #Yearly_Salary		
						set Month_10 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
					
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_10) as NetAmount,'Oct-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID						
						
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
									Update #Yearly_Salary_Report set NetAmount = 0.0 
									where Month_1 = 'Oct-' + convert(NVARCHAR(4),right(@Year,2))
									End
							END
					end	
				else if @count = 11
					begin
						
																												
						Update #Yearly_Salary		
						set Month_11 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
				
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_11) as NetAmount,'Nov-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID	
							
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Nov-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
						
					end	
				else if @count = 12
					begin
																												
						Update #Yearly_Salary		
						set Month_12 = Net_Amount
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
							and Def_ID = 15
						insert into #Yearly_Salary_Report(NetAmount,Month_1)
						Select sum(Month_12) as NetAmount,'Dec-' + convert(NVARCHAR(4),right(@Year,2)) from  #Yearly_Salary where Cmp_id=@Cmp_ID
							
						If not exists(Select Publish_ID from T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) where Month = @Month and YEAR = @Year and Cmp_ID=@Cmp_ID and Is_Publish = 1 and Sal_Type='Salary') --Added by Mihir Trivedi on 08/06/2012 for salary view validation
							BEGIN
							if (@Publish_Flag=0)
									Begin
										Update #Yearly_Salary_Report set NetAmount = 0.0 
										where Month_1 = 'Dec-' + convert(NVARCHAR(4),right(@Year,2))
									End	
							END
					end						
																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
	
			Select * from #Yearly_Salary_Report
					
	RETURN
