
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Sp_Rpt_Emp_Skill_Rating]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT 	VARCHAR(5000)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0  
		Set @Branch_ID = null		
	IF @Cat_ID = 0  
		Set @Cat_ID = null
	IF @Grd_ID = 0  
		Set @Grd_ID = null
	IF @Type_ID = 0  
		Set @Type_ID = null
	IF @Dept_ID = 0  
		Set @Dept_ID = null
	IF @Desig_ID = 0  
		Set @Desig_ID = null
	IF @Emp_ID = 0  
		Set @Emp_ID = null

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

			select I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
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
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		End
		
			Select ESS.Emp_Id,ESD.For_Date,ESS.Skilll_Rate_Given,ESS.Skill_Actual_Rate,SM.Skill_Name,EM.Emp_Code,EM.Emp_Full_Name,BM.Comp_Name,Em.Branch_Id,BM.Branch_Address,CM.Cmp_Name,CM.Cmp_Address From dbo.T0055_HRMS_EMP_SKILL_DETAILS ESD WITH (NOLOCK) 
			INNER JOIN dbo.T0090_HRMS_EMP_SKILL_Setting ESS WITH (NOLOCK) ON ESD.Skill_R_Id = ESS.Skill_R_ID
			INNER JOIN dbo.T0040_Skill_Master SM WITH (NOLOCK) ON ESS.Skill_ID = SM.Skill_ID
			INNER JOIN dbo.T0080_Emp_Master EM WITH (NOLOCK) ON ESD.Emp_Id = EM.Emp_Id    
			INNER JOIN dbo.T0030_Branch_Master BM WITH (NOLOCK) ON Em.Branch_Id = BM.Branch_Id 
			INNER JOIN dbo.T0010_Company_Master CM WITH (NOLOCK) ON Em.Cmp_Id = CM.Cmp_ID
			Where For_Date >=@From_Date and For_Date <=@To_Date And ESD.Cmp_Id=@Cmp_Id
			And EM.Emp_ID in (select Emp_Id from @Emp_Cons)			
			
					
RETURN




