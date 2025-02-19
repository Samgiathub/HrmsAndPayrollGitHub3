
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_LWF_STATEMENT_GET]
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
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
	
			-- Changed By Ali 23112013 EmpName_Alias
			Select ms.Emp_Id,Ms.LWF_Amount,E.Date_OF_Join,E.Father_Name,ISNULL(EmpName_Alias_PT,Emp_Full_Name) as Emp_full_Name,Grd_Name,Month(Month_St_Date)as Month,YEar(Month_St_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,CMP_NAME,CMP_ADDRESS,PT_F_T_Limit	,comp_name,branch_name,branch_address,BM.Branch_ID
					,Vs.Vertical_Name,SV.SubVertical_Name,SB.SubBranch_Name	
					,@From_Date as from_date,@To_Date as To_Date,
					UPPER(SM.STATE_NAME) AS STATE_NAME --Added By Jimit 10072018
				 From T0200_MONTHLY_SALARY MS WITH (NOLOCK)  Inner join 
				T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID 
					inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  INNER JOIN 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID left join
							T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I_Q.Vertical_ID left join
							T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=I_q.SubVertical_ID left join
							T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=I_Q.subBranch_ID Left Outer JOIN
							T0020_STATE_MASTER SM WITH (NOLOCK) On Sm.State_ID = Bm.State_ID
							
							
				WHERE E.Cmp_ID = @Cmp_Id	
					and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date 
					and LWF_Amount > 0


		
RETURN




