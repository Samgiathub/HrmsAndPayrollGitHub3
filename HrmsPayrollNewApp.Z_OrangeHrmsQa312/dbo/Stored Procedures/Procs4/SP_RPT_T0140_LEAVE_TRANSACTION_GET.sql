



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0140_LEAVE_TRANSACTION_GET]
 @Cmp_ID 	numeric
,@From_Date 	datetime
,@To_Date 	datetime
,@Branch_ID 	numeric
,@Cat_ID 	numeric 
,@Grd_ID 	numeric
,@Type_ID 	numeric
,@Dept_ID 	numeric
,@Desig_ID 	numeric
,@Emp_ID 	numeric
,@Leave_ID 	numeric
,@constraint 	varchar(1000)
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

	IF @Leave_ID = 0  
		set @Leave_ID = null

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
			
		end
		 
	 
	Select lt.*,Alpha_Emp_Code, Emp_full_Name,Grd_Name,Month(For_Date)as Month,YEar(For_Date)as Year 
			,Leave_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name
		 From T0140_LEAVE_TRANSACTION  lt WITH (NOLOCK) Inner join 
		T0080_EMP_MASTER E WITH (NOLOCK) on lt.emp_ID = E.emp_ID INNER  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Inner join 
					T0040_Leave_Master Lm WITH (NOLOCK) on Lt.Leave_ID = Lm.Leave_ID

		WHERE E.Cmp_ID = @Cmp_Id	
			and Isnull(I_Q.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I_Q.Cat_ID,0))
			and I_Q.Branch_ID = isnull(@Branch_ID ,I_Q.Branch_ID)
			and I_Q.Grd_ID = isnull(@Grd_ID ,I_Q.Grd_ID)
			and isnull(I_Q.Dept_ID,0) = isnull(@Dept_ID ,isnull(I_Q.Dept_ID,0))
			and Isnull(I_Q.Type_ID,0) = isnull(@Type_ID ,Isnull(I_Q.Type_ID,0))
			and Isnull(I_Q.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I_Q.Desig_ID,0))
			and E.Emp_ID = isnull(@Emp_ID ,E.Emp_ID) 
			and lt.Leave_ID = isnull(@Leave_ID ,lt.Leave_ID) 
			and E.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			and For_Date >=@From_Date and For_date <=@To_Date
			And (Isnull(Leave_Credit,0) > 0 or Isnull(Leave_Used,0) > 0 or Isnull(Leave_Encash_Days,0) >0)
	
					
	RETURN 




