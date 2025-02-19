



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_HRMS_RECORDS_DETAILS] 
	
	 @Cmp_ID		numeric  =26
	,@From_Date		datetime ='01-oct-2009'
	,@To_Date		datetime ='31-dec-2009'
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 530
	,@Constraint	varchar(5000) = ''
	,@HRMS_Skill    numeric =0
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Branch_ID = 0
		set @Branch_ID = null
	If @Cat_ID = 0
		set @Cat_ID = null	 
	If @Type_ID = 0
		set @Type_ID = null
	If @Dept_ID = 0
		set @Dept_ID = null
	If @Grd_ID = 0
		set @Grd_ID = null
	If @Emp_ID = 0
		set @Emp_ID = null	
	If @Desig_ID = 0
		set @Desig_ID = null
		
		
	Declare @For_date as DateTime	
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
		----   Skill Max Rating Details ------
		if       @HRMS_Skill =1 
		   Begin
		   
		    
			--Select @For_date = max(For_date) from V0090_HRMS_EMP_SKILL_SETTING where Cmp_ID =26 and Emp_ID =530
             --   and For_date >='01-oct-2009' and For_date <='31-dec-2009'
	
			
			Select SK.*, cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name 
				 from V0090_HRMS_EMP_SKILL_SETTING SK      inner join 
				      T0080_Emp_Master E WITH (NOLOCK) on SK.Emp_ID  = E.Emp_ID inner join
		              T0040_Skill_Master SM WITH (NOLOCK) on SK.Skill_ID = SM.Skill_ID 
	
			where SK.Cmp_ID=@Cmp_ID
				 and SK.Emp_ID=@Emp_ID  and For_date >=@From_Date and For_date <=@To_Date
		  
		   
		   End
		   
		   ----   Training Rating Details -------
		   
		   if @HRMS_Skill = 2
		      Begin
		      
					Select TR.*, cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name 
						 from V0130_HRMS_Traininig_Feedback_Super_Details TR     inner join 
							  T0080_Emp_Master E WITH (NOLOCK) on TR.Emp_ID  = E.Emp_ID inner join
							  T0040_Skill_Master SM WITH (NOLOCK) on TR.Skill_ID = SM.Skill_ID 
			
					where TR.Cmp_ID=@Cmp_ID
						 and TR.Emp_ID=@Emp_ID  and Training_Date >=@From_Date and Training_date <=@To_date
		      
		      End
		   -------Goal Setting  -------------------------------------   
		    if   @HRMS_Skill = 3
		      Begin
		      
		          Select TR.*, cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name 
						 from V0130_HRMS_Traininig_Feedback_Super_Details TR     inner join 
							  T0080_Emp_Master E WITH (NOLOCK) on TR.Emp_ID  = E.Emp_ID inner join
							  T0040_Skill_Master SM WITH (NOLOCK) on TR.Skill_ID = SM.Skill_ID 
			
					where TR.Cmp_ID=@Cmp_ID
						 and TR.Emp_ID=@Emp_ID  and Training_Date >=@From_Date and Training_date <=@To_date
		     
		      
		      end
		   
		
	RETURN




