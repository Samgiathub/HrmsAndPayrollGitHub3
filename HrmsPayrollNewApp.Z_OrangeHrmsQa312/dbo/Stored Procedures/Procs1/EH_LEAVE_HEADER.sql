



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_LEAVE_HEADER]
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
	,@constraint 	varchar(5000)
	
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
			
			
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
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
			
		end
		
		IF OBJECT_ID('tempdb..#Yearly_Leave') IS NOT NULL
		BEGIN
			DROP TABLE #Yearly_Leave
		END	
		 
		 Create table #Yearly_Leave 
		 (
				Cmp_ID NUMERIC,
				Emp_ID NUMERIC,
				Leave_nAME VARCHAR(MAX)
		   )

		insert into #Yearly_Leave (Cmp_ID,Emp_ID ,Leave_nAME)
		
			select @Cmp_ID,emp_ID,lm.Leave_Name From @Emp_Cons ec cross join 
			t0040_Leave_Master lm  WITH (NOLOCK)
			where lm.cmp_ID = @cmp_ID

		
	
		DECLARE @query AS NVARCHAR(MAX)
		DECLARE @pivot_cols NVARCHAR(1000);
		SELECT @pivot_cols =
				STUFF((SELECT DISTINCT '],[' + Leave_name
					   FROM #Yearly_Leave 
					   ORDER BY '],[' + Leave_name
					   FOR XML PATH('')
					   ), 1, 2, '') + ']';
               
 

			SET @query =
			'SELECT * FROM
			(
				SELECT Leave_name,Emp_ID
				FROM #Yearly_Leave
				
			)Salary
			PIVOT (count(Emp_ID) FOR Leave_name
			IN ('+@pivot_cols+')) AS pvt'


			print @query
			EXECUTE (@query)
		
	
				
	RETURN



