

CREATE PROCEDURE [dbo].[SP_IT_Get_Tax_Employee_Details]
 @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = '' 

AS

    SET NOCOUNT ON 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON


    if @Branch_ID = 0  
		 set @Branch_ID = null 
		  
	if @Cat_ID = 0  
		set @Cat_ID = null 
		 
	if @Type_ID = 0  
		set @Type_ID = null 
		 
	if @Dept_ID = 0  
		set @Dept_ID = null  
		
	if @Grd_ID = 0  
		set @Grd_ID = null  
		
	if @Emp_ID = 0  
		set @Emp_ID = null  
    
	 If @Desig_ID = 0  
		set @Desig_ID = null  
    
	Declare @Financial_Year varchar(50)
	SET @Financial_Year = ''

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
					
			Insert Into @Emp_Cons
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and	I.Increment_effective_Date = Qry.For_Date
							
			Where Cmp_ID = @Cmp_ID 
			--and Isnull(Division_ID,0) = isnull(@Branch_ID ,Isnull(Division_ID,0))
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and Isnull(Cat_ID,0) = isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 						
			
		END	
		
			SET @Financial_Year = CONVERT(varchar(20),YEAR(@From_Date)) + '-' + CONVERT(varchar(20),YEAR(@To_Date))
			select ITD.EMP_ID,SUM(ITD.AMOUNT)as Amount,Detail_1,Detail_2,Detail_3,Comments
			,ITD.Is_Metro_NonMetro   --added jimit 30062016
			from T0100_IT_DECLARATION ITD WITH (NOLOCK) INNER JOIN
			T0070_IT_MASTER ITM WITH (NOLOCK) ON ITD.IT_ID = ITM.IT_ID INNER JOIN
			T0110_IT_Emp_Details ITED WITH (NOLOCK) ON ITD.IT_ID = ITED.IT_ID and Itd.FINANCIAL_YEAR = ITED.Financial_Year INNER JOIN  --Added By Jimit 27032018 as duplicate record coming for different financial year
			@Emp_Cons e ON e.Emp_ID = ITD.EMP_ID
			where ITD.EMP_ID = e.Emp_ID and ITD.CMP_ID = @Cmp_ID
			AND ITM.IT_Def_ID = 1 and ITED.Emp_ID = e.Emp_ID
			AND ISNULL(ITED.Date,'') = '' and ITED.Amount = 0
			AND ITED.Financial_Year = @Financial_Year
			group by ITD.Emp_ID,Detail_1,Detail_2,Detail_3,Comments,ITD.Is_Metro_NonMetro

		RETURN
	
	RETURN


