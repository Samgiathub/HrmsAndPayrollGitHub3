

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_MONTHLY_LOAN_WISE_PAYMENT_GET]
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
,@Sal_Type		numeric =0
,@Salary_Cycle_id numeric = 0
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)		
,@Bank_ID varchar(20) = '' --Added by ronakk 20082022
 ,@Payment_mode varchar(20) = '' --Added by ronakk 20082022
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
	
	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	


 declare @manual_salary_period as numeric(18,0)
 set @manual_salary_period = 0

  Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
		  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
		       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		 if @manual_salary_period = 0 
			BEGIN 
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
		Else
			Begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
			    Set @From_Date = @Sal_St_Date
			    Set @To_Date = @Sal_End_Date 
			End      

	Declare @Loan Table
	(
		Emp_ID	Numeric,
		Loan_Opening Numeric(18,2),
		Loan_Credit Numeric(18,2),
		Loan_Debit Numeric(18,2),
		Loan_Closing Numeric(18,2),
		Loan_Id 	Numeric
	)

CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		Begin
			Insert Into #Emp_Cons      
			  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
			  cmp_id=@Cmp_ID 
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013       
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
			  and Increment_Effective_Date <= @To_Date 
			  and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
						
				Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date) 
		End	
		
	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END     		
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

	--Insert Into @Loan 
	--Select *,0,0,0,0,0 From #Emp_Cons		 

	Declare @Emp_Id_Cur as Numeric
	Declare @Loan_Opening as Numeric(18,2)
	Declare @Loan_Credit as Numeric(18,2)
	Declare @Loan_Debit as Numeric(18,2)
	Declare @Loan_Closing as Numeric(18,2)
	Declare @Loan_Id as Numeric
	
	Set @Loan_Opening = 0
	Set @Loan_Credit = 0
	Set @Loan_Debit = 0
	Set @Loan_Closing = 0
    set @Loan_Id = 0
    
    Select  0 as Loan_Op,0 as loan_id ,0 as EMP_ID
			into #LoanOpBal
			
	Declare Cur_Loan cursor for 
		Select Emp_ID from #Emp_Cons
	open Cur_Loan
	fetch next from Cur_Loan into @Emp_Id_Cur
	while @@fetch_Status = 0
		begin 
			
			insert into #LoanOpBal
			Select  Isnull(SUM(Loan_Opening),0) as Loan_Op,Qry.loan_id ,LT.EMP_ID
			--into #LoanOpBal
			
			from T0140_LOAN_TRANSACTION LT WITH (NOLOCK) inner Join 
				(Select Loan_Id, MIN(For_Date) Min_For_Date from T0140_LOAN_TRANSACTION WITH (NOLOCK)
				Where Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date
				group by loan_id) Qry 
			on LT.Loan_ID = Qry.Loan_ID And LT.For_Date = Qry.Min_For_Date
			where Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date
			group by LT.EMP_ID,Qry.loan_id

							
			insert into @Loan  (Emp_ID,Loan_Opening,Loan_Credit,Loan_Debit,Loan_Closing,Loan_Id)
		
			--Commented by Hardik 09/07/2016 as Loan Opening coming wrong in Kataria, showing Opening twice and thrice sum
			--Select LT.Emp_ID,Isnull(SUM(Loan_Op),0),Isnull(SUM(Loan_Issue),0),Isnull(SUM(Loan_Return),0), 
			Select LT.Emp_ID,Isnull((select Loan_Op from #LoanOpBal where Emp_id=LT.Emp_Id And Loan_id = LT.Loan_Id),0),
					Isnull(SUM(Loan_Issue),0),Isnull(SUM(Loan_Return),0), 
				   --(Isnull(SUM(Loan_Op),0) + Isnull(SUM(Loan_Issue),0)) - Isnull(SUM(Loan_Return),0)
				   (Isnull((Select Isnull(Loan_Op,0) From #LoanOpBal Where EMP_ID = LT.Emp_Id And loan_id=LT.Loan_Id),0) + Isnull(SUM(Loan_Issue),0)) - Isnull(SUM(Loan_Return),0)
				   
				   ,LT.loan_id
			From T0140_LOAN_TRANSACTION as LT WITH (NOLOCK) inner join #LoanOpBal  as LO
			on LT.Emp_ID = LO.Emp_ID and LT.Loan_Id = LO.Loan_Id 
			where LT.Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date
			group by LT.Emp_ID,LT.loan_id
		
		
			fetch next from Cur_Loan into @Emp_Id_Cur
		End
	Close Cur_Loan
	Deallocate Cur_Loan
	
	Select Lo.*,LM.Loan_Name from @Loan as LO inner join T0040_LOAN_MASTER as LM WITH (NOLOCK)
	on Lo.Loan_id = LM.Loan_id and LM.Is_Interest_Subsidy_Limit = 0  -- changed by gadriwala 25122014 for subsidy loan
					
	RETURN 

