



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_MONTHLY_LOAN_PAYMENT_GET]
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
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End


	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	CREATE TABLE #Emp_Cons -- Ankit 05092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 
	Declare @Loan Table
	(
		Emp_ID	Numeric,
		Loan_Opening Numeric(18,2),
		Loan_Credit Numeric(18,2),
		Loan_Debit Numeric(18,2),
		Loan_Closing Numeric(18,2)
	)
	

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

	Insert Into @Loan 
	Select *,0,0 From #Emp_Cons		 

	Declare @Emp_Id_Cur as Numeric
	Declare @Loan_Opening as Numeric(18,2)
	Declare @Loan_Credit as Numeric(18,2)
	Declare @Loan_Debit as Numeric(18,2)
	Declare @Loan_Closing as Numeric(18,2)
	
	Set @Loan_Opening = 0
	Set @Loan_Credit = 0
	Set @Loan_Debit = 0
	Set @Loan_Closing = 0

	Declare Cur_Loan cursor for 
		Select Emp_ID from #Emp_Cons
	open Cur_Loan
	fetch next from Cur_Loan into @Emp_Id_Cur
	while @@fetch_Status = 0
		begin 
			Select @Loan_Opening = Isnull(SUM(Loan_Opening),0) from T0140_LOAN_TRANSACTION LT WITH (NOLOCK) inner Join 
				(Select Loan_Id, MIN(For_Date) Min_For_Date from T0140_LOAN_TRANSACTION WITH (NOLOCK)
				Where Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date
				group by loan_id) Qry 
			on LT.Loan_ID = Qry.Loan_ID And LT.For_Date = Qry.Min_For_Date
			where Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date

			Select @Loan_Credit = Isnull(SUM(Loan_Issue),0),@Loan_Debit = Isnull(SUM(Loan_Return),0), 
					@Loan_Closing = (@Loan_Opening + Isnull(SUM(Loan_Issue),0)) - Isnull(SUM(Loan_Return),0)
			From T0140_LOAN_TRANSACTION LT WITH (NOLOCK)
			where Emp_ID = @Emp_Id_Cur and For_Date >=@From_Date and For_Date <=@To_Date

			
			Update @Loan 
			Set Loan_Opening = @Loan_Opening,
				Loan_Credit = @Loan_Credit,
				Loan_Debit = @Loan_Debit,
				Loan_Closing = @Loan_Closing
			Where Emp_ID = @Emp_Id_Cur

	
			fetch next from Cur_Loan into @Emp_Id_Cur
		End
	Close Cur_Loan
	Deallocate Cur_Loan
	
	Select * from @Loan
	 
	--Select LT.*,Emp_full_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name
	--	 From T0140_LOAN_TRANSACTION LT Inner join 
	--	T0080_EMP_MASTER E on LT.emp_ID = E.emp_ID INNER  JOIN 
	--		#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
	--		( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
	--			on E.Emp_ID = I_Q.Emp_ID  inner join
	--				T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--				T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--				T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--				T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
	--				T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  
	--	WHERE E.Cmp_ID = @Cmp_Id	 and For_Date >=@From_Date and For_Date <=@To_Date
					
	RETURN 




