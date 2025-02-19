

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_2_GET]
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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_master e WITH (NOLOCK) on i.emp_Id = e.emp_ID inner join
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
			and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
			and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
			and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
			and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
			and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and Date_of_Join >=@From_Date and Date_of_Join <=@To_Date 
		end

		--change by Falak on 24-OCT-2010 added column 'Date_Of_Join'
		
		
		
		-- Changed By Ali 23112013 EmpName_Alias
		Select E.Emp_ID ,ISNULL(E.EmpName_Alias_PF,E.Emp_Full_Name) as Emp_Full_Name ,CM.Cmp_Name,CM.Cmp_Address, E.Emp_Code ,Date_Of_Birth,Gender,Case When Marital_Status = '' Then 0 Else Marital_Status End As Marital_Status,E.Date_Of_Join,Inc_Bank_Ac_no
				,Present_Street,Present_City,Present_State,Present_Post_box,
				Street_1,City,State,Zip_Code,SSN_No as PF_No
				,@From_Date P_From_Date ,@To_Date P_To_Date
				,e.Alpha_Emp_Code,E.Emp_First_Name,Grd_Name,TYPE_NAME,Dept_Name,Desig_Name    --added jimit 02062015
		From T0080_EMP_MASTER E WITH (NOLOCK) inner join t0010_company_master CM WITH (NOLOCK) on E.Cmp_ID =CM.Cmp_ID inner join
			@Emp_cons ec on e.Emp_ID = Ec.emp_ID   inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID ,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID   --added jimit 16062015

		--WHERE E.Cmp_ID = @Cmp_Id	and Date_of_Join >=@From_Date and Date_of_Join <=@To_Date   \\** Commented By Ramiz on 26/06/2015
				
	
	RETURN




