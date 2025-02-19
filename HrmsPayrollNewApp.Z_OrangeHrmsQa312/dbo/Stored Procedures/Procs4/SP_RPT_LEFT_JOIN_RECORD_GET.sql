

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEFT_JOIN_RECORD_GET]
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
	,@Constraint	varchar(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	

	if @Branch_ID = 0
			set @Branch_ID = null
		if @Type_ID = 0
			set @Type_ID = null
		if @Dept_ID = 0
			set @Dept_ID = null
		if @Grd_ID = 0
			set @Grd_ID = null
		if @Emp_ID = 0
			set @Emp_ID = null

		if @Desig_ID = 0
			set @Desig_ID = null

		if @Cat_ID = 0 
			Set @Cat_ID = null
		 


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
			 
	
			 
	Declare @data table
	 ( 
		Emp_ID		numeric,
		Join_Date	Datetime ,
		Left_DAte	Datetime,
		T_Date		Datetime,
		Is_Join		int

	 )

	 

	insert into @Data (Emp_ID ,Join_Date,Is_Join,T_Date)
	select e.Emp_ID ,Date_Of_Join,1,Date_Of_Join from T0080_Emp_Master e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID where Cmp_ID =@Cmp_ID and Date_Of_Join >=@From_Date and Date_Of_Join <=@to_Date

	insert into @Data (Emp_ID ,Left_Date,Is_Join,T_Date)
	select e.Emp_ID ,Left_Date,0,Left_Date from T0100_LEFT_EMP e WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_ID = ec.emp_ID where Cmp_ID =@Cmp_ID and Left_Date >=@From_Date and Left_Date <=@to_Date


 
	Select d.*,Emp_FULL_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Branch_Name,I_Q.gross_salary,LM.loc_name
			,@From_Date as P_From_Date , @To_Date as P_To_date ,Branch_Address,COMP_NAME,cmp_Name,Cmp_Address,BM.Branch_ID
			,E.Alpha_Emp_Code   --added jimit 02062015
		 From @data  d Inner join 
		T0080_EMP_MASTER E WITH (NOLOCK) on d.emp_ID = E.emp_ID INNER  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date,Gross_Salary  from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer join
					T0001_Location_master LM WITH (NOLOCK) on E.loc_id = LM.loc_id inner join 
					t0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_iD =CM.CMP_iD

		WHERE E.Cmp_ID = @Cmp_ID	
			
			
	
	RETURN




