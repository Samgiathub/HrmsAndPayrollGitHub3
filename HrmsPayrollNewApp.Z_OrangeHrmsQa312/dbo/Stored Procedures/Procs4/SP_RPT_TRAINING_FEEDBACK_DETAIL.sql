



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_TRAINING_FEEDBACK_DETAIL]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  
	,@Cat_ID		numeric  
	,@Grd_ID		numeric 
	,@Type_ID		numeric 
	,@Dept_ID		numeric 
	,@Desig_ID		numeric 
	,@Emp_ID		numeric 
	,@Constraint	varchar(5000) = ''
--	,@Training_id   NUMERIC 
	,@Is_Attend     Numeric(1,0) =0
	

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
		If @Is_Attend = 0
		set @Desig_ID = null
		
	
	
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
		
		if @Is_Attend = 2
		  Begin 
			  select TD.*, E.Emp_full_Name,E.Emp_Code as Emp_code,Emp_superior,DM.Dept_Name,DGM.Desig_Name,Type_Name,Grd_Name,I_Q.BRANCH_ID,BM.Branch_Name,Date_of_Join,Gender,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address  
							from V0140_HRMS_TRAINING_FEEDBACK  TD  Left outer join 
							 T0080_emp_master E WITH (NOLOCK) ON E.Emp_ID = TD.Emp_ID 
							inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join  
						(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join   
							(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)  
							where Increment_Effective_date <= @To_Date  
							and Cmp_ID = @Cmp_ID  
							group by emp_ID  ) Qry on  
							 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q   
							on E.Emp_ID = I_Q.Emp_ID  inner join  
							 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
							 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
							 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
							 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
							 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
						  WHERE TD.Cmp_ID = @Cmp_Id  and Is_Attend =1 or Is_Attend =0  and Training_date >=@From_date and Training_Date <= @To_date 
		And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by TD.Emp_full_name  
					    
		  
		  
		  End
		Else
		  Begin  
		  
		
	    --select TD.Emp_ID,E.Emp_full_Name,TD.Emp_full_name_new,TD.Training_ID,TD.Training_Date,TD.Training_name,TD.Reason,TD.Emp_Score,TD.Emp_comments,TD.Emp_suggestion,TD.Sup_Score,TD.Sup_comments,TD.Is_attend_name, E.Emp_Code as Emp_code,Emp_superior,DM.Dept_Name,DGM.Desig_Name,Type_Name,Grd_Name,I_Q.BRANCH_ID,BM.Branch_Name,Date_of_Join,Gender,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address  
	    select TD.Emp_ID,E.Emp_full_Name,TD.Emp_full_name_new,TD.Training_ID,TD.Training_Date,TD.Training_name,TD.Reason,TD.Emp_Score,TD.Sup_Score,TD.Sup_comments,TD.Is_attend_name, E.Emp_Code as Emp_code,Emp_superior,DM.Dept_Name,DGM.Desig_Name,Type_Name,Grd_Name,I_Q.BRANCH_ID,BM.Branch_Name,Date_of_Join,Gender,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address  
							from V0140_HRMS_TRAINING_FEEDBACK  TD  Left outer join 
							 T0080_emp_master E WITH (NOLOCK) ON E.Emp_ID = TD.Emp_ID 
							inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join  
						(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join   
							(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
							where Increment_Effective_date <= @To_Date  
							and Cmp_ID = @Cmp_ID  
							group by emp_ID  ) Qry on  
							 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q   
							on E.Emp_ID = I_Q.Emp_ID  inner join  
							 T0040_GRADE_MASTER GM WITH (NOLOCK)  ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
							 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
							 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
							 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
							 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
						  WHERE TD.Cmp_ID = @Cmp_Id  and isnull(Is_Attend,0) = isnull(@Is_Attend,isnull(Is_Attend,0))  and Training_date >=@From_date and Training_Date <= @To_date 
		And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by TD.Emp_full_name  
					    
			End
		
		
	RETURN




