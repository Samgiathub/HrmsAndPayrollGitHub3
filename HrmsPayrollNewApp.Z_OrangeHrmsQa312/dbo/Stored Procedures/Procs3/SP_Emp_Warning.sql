




CREATE PROCEDURE [dbo].[SP_Emp_Warning]
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
	,@Constraint	varchar(5000) = ''
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
		
	
	begin
			
			SELECT    E.Emp_Full_Name,Dept_Name,Desig_Name,Grd_Name,Branch_Name,Date_of_Join,le.left_Date,le.left_reason
			from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
			T0100_left_emp le WITH (NOLOCK) ON E.emp_id = le.emp_ID inner join
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON E.Desig_Id = DGM.Desig_Id inner JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON E.Dept_Id = DM.Dept_Id INNER JOIN 
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON E.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.BRANCH_ID = BM.BRANCH_ID 
			where le.left_date >= @From_date and le.left_Date <= @To_Date
			
	end	
		
	RETURN




