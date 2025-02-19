



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Rpt_Appraisal_Result]
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
	,@Appr_Int_Id   NUMERIC
	,@Is_Accept     NUMERIC
	,@CONSTRAINT 	VARCHAR(5000)	
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
	IF @Appr_Int_Id=0
	    set @Appr_Int_Id=null	
	IF @Is_Accept = 0    
	    set @Is_Accept = Null

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

	Select HAI.Appr_Int_Id,HAI.Cmp_Id,HAID.Emp_Id,HAI.For_date,HAID.Is_Accept,I.Increment_Date,HAID.Start_Date,HAID.End_date,EM.Emp_Code,EM.Emp_Full_Name,Em.Branch_Id,Em.Grd_ID,Em.Desig_Id,Em.Dept_Id, LO.Login_Name,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,CM.Cmp_Address 
	From dbo.T0090_hrms_Appraisal_Initiation HAI WITH (NOLOCK)
	INNER JOIN dbo.T0090_hrms_Appraisal_Initiation_detail HAID WITH (NOLOCK) ON HAI.Appr_Int_ID=HAID.Appr_Int_Id
    INNER JOIN dbo.T0080_Emp_Master EM WITH (NOLOCK) ON HAID.Emp_Id=Em.Emp_Id 
    INNER JOIN dbo.T0011_Login LO WITH (NOLOCK) ON HAI.Login_Id = LO.Login_ID 
    INNER JOIN dbo.T0030_Branch_Master BM WITH (NOLOCK) ON EM.Branch_Id = BM.Branch_Id
    LEFT OUTER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK) ON HAID.Increment_Id = I.Increment_ID    
    INNER JOIN dbo.T0010_Company_Master CM WITH (NOLOCK) ON Em.Cmp_Id = CM.Cmp_ID
    Where For_Date >=@From_Date and For_Date <=@To_Date And HAI.Cmp_Id=@Cmp_Id And IsNull(HAI.Appr_Int_Id,0)= IsNull(@Appr_Int_Id,ISNull(HAI.Appr_Int_Id,0)) And IsNull(HAID.Is_Accept,0)= IsNull(@Is_Accept,ISNull(HAID.Is_Accept,0))    
			And Em.Emp_ID in (select Emp_Id from @Emp_Cons) 

RETURN




