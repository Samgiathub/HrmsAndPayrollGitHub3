
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_Get_Employee_HousingLoan]
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
			
			Select ITD.IT_ID,ITED.Emp_ID,ITED.[Date],REPLACE(ITED.Detail_1,'|',',') as Detail_1,ITED.Detail_2,ITD.CMP_ID
			,ITED.Comments 
			,ITD.FINANCIAL_YEAR   --added jimit 30032016
			from T0100_IT_DECLARATION ITD WITH (NOLOCK) INNER JOIN
			T0070_IT_MASTER ITM WITH (NOLOCK) ON ITD.IT_ID = ITM.IT_ID  INNER JOIN
			T0110_IT_Emp_Details ITED WITH (NOLOCK) ON ITED.IT_ID = ITD.IT_ID INNER JOIN
			@Emp_Cons e On e.Emp_ID = ITD.EMP_ID
			Where ITM.IT_Def_ID = 153 AND ITD.CMP_ID = @Cmp_ID
			AND ITD.EMP_ID = e.Emp_ID  AND ITED.Emp_ID = e.Emp_ID
			AND ITED.Financial_Year = @Financial_Year
			

		RETURN
	
	RETURN


