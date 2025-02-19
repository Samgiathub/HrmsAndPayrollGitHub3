

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_YEALRY_ADVANCE_GET]
	 @Cmp_ID  		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@Report_Call	varchar(20)='ADVANCE AMOUNT'
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
	,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
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
	
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
	
	
	
	CREATE TABLE #Emp_Cons	-- Ankit 06092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
			
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end
		 
		Declare @Month numeric 
		Declare @Year numeric  
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Advance' )		
			begin
				drop table #Yearly_Advance 
			end
			 
		CREATE table #Yearly_Advance 
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
				
			)
	
			
			if @Report_Call <> 'ADVANCE AMOUNT'
				begin
						
										
						insert into #Yearly_Advance (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,14,'ADVANCE' From #Emp_Cons 
				End

			insert into #Yearly_Advance (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,14,'ADVANCE' From #Emp_Cons 
						
 
		
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
					set @Month =month(@Temp_date)
					set @Year = year(@Temp_Date)
						
				if @count = 1 
					begin
				
						Update #Yearly_Advance		
						set Month_1 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
					
					end
				else if @count = 2
					begin
					

						Update #Yearly_Advance		
						set Month_2 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
					
					end	
				else if @count = 3
					begin
						

						Update #Yearly_Advance		
						set Month_3 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
					

					end	
				else if @count = 4
					begin
						

						Update #Yearly_Advance		
						set Month_4 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 5
					begin
						

						Update #Yearly_Advance		
						set Month_5 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 6
					begin
						
						

						Update #Yearly_Advance		
						set Month_6 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 7
					begin
					
						Update #Yearly_Advance		
						set Month_7 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
					
				else if @count = 8
					begin
					

						Update #Yearly_Advance		
						set Month_8 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 9
					begin
						

						Update #Yearly_Advance		
						set Month_9 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 10
					begin
						
						Update #Yearly_Advance		
						set Month_10 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
					
					end	
				else if @count = 11
					begin
						

						Update #Yearly_Advance		
						set Month_11 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end	
				else if @count = 12
					begin
						

						Update #Yearly_Advance		
						set Month_12 = Advance_Amount
						From #Yearly_Advance  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Where Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
							and Def_ID = 14
																												
						
					end						
																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
	
		UPDATE #Yearly_Advance
		SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 
		
		-- Changed By Ali 22112013 EmpName_Alias
		select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme 
			,Cmp_NAme,Cmp_Address,Emp_Code
			,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
			@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID
		,EM.Alpha_Emp_Code,Em.Emp_first_Name  --added jimit 30052015
		from #Yearly_Advance  Ys inner join 
		( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
				ys.emp_Id = iq.emp_Id inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join 
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id
				 
		order by ys.Emp_ID ,Row_ID
			
					
	RETURN 




