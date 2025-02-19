



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_GET_SKILL_FILTER]

	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	 ,@Emp_ID		numeric  = 0
	
	
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
		
	CREATE table #Data
	(
		Emp_ID	numeric,
		Branch_ID numeric,
		Grd_ID numeric,
		Dept_ID numeric,
		Desig_ID numeric,
		
	)
			
			Insert Into #Data(Emp_ID,Branch_ID,Grd_ID,Dept_ID,Desig_ID)

			select I.Emp_Id,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID from T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)   
				 where Increment_Effective_date <= @To_Date    
				 and Cmp_ID = @Cmp_ID    
				 group by emp_ID  ) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
			           
			   Where Cmp_ID = @Cmp_ID     
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
			   and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
			   and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
			   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
			   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
			   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
			   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
				AND I.Emp_ID in (select emp_Id from    
				 (select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry    
				 where Cmp_ID = @Cmp_ID   and      
				 (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
				 or ( @From_Date <= join_Date  and @To_Date >= left_date )     
				 or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
				 or left_date is null and  @To_Date >= Join_Date))    
						
			
	       Select * from #Data
	
	RETURN




