



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_HRMS_Appr_FeedBack_Question_get]
	@Cmp_Id Numeric(18,0),
	@Branch_Id Numeric(18,0),
	@Dept_Id Numeric(18,0),
	@Desig_Id Numeric(18,0),
	@Grd_Id Numeric(18,0),
	@Emp_Id Numeric(18,0),
	@Form_Name Char
  AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Branch_Id = 0	
	  set @Branch_Id=null 

	If @Dept_Id=0
	  set @Dept_Id=null

	If @Desig_Id=0
	  set @Desig_Id=null	

	If @Grd_Id=0
	  set @Grd_Id=null

	If @Emp_Id=0
	  set @Emp_Id=null	
	  
	Declare @For_date as DateTime
	  
	If @Form_Name='I'
		Begin	
	Select @For_date = max(For_Date)  from dbo.T0050_HRMS_Appraisal_Setting R WITH (NOLOCK)
	   where  
			isnull(R.Branch_ID,0) = isnull(@Branch_ID ,isnull(R.Branch_ID,0))
			and isnull(R.Grade_ID,0) = isnull(@Grd_ID ,isnull(R.Grade_id,0))
			and isnull(R.Desig_ID,0) = isnull(@Desig_ID ,isnull(R.Desig_ID,0))
			and isnull(R.Dept_ID,0) = isnull(@Dept_ID ,isnull(R.Dept_ID,0))


        insert into #Appr_ID
		select H.Appr_Id from dbo.T0050_HRMS_Appraisal_Setting H WITH (NOLOCK)
			left outer join dbo.t0030_branch_master B WITH (NOLOCK) on H.Branch_Id=B.branch_ID
			left outer join dbo.t0040_designation_master Des WITH (NOLOCK) on H.Desig_ID = Des.Desig_ID
			left outer join dbo.t0040_department_master Dm WITH (NOLOCK) on H.Dept_ID = Dm.Dept_id
			left outer join dbo.t0040_grade_master G WITH (NOLOCK) on H.Grade_ID = G.Grd_ID		
		where For_Date =@For_date and 
			isnull(H.Branch_ID,0) = isnull(@Branch_ID ,isnull(H.Branch_ID,0))
			and isnull(H.Grade_ID,0) = isnull(@Grd_ID ,isnull(H.Grade_id,0))
			and (isnull(H.Dept_ID,0) =0 or isnull(H.Desig_ID,0) = isnull(@Desig_ID ,isnull(H.Desig_ID,0)))
			and (isnull(H.Dept_ID,0) =0 or isnull(H.Dept_ID,0) = isnull(@Dept_ID ,isnull(H.Dept_ID,0)))		
			
	RETURN	
	End	
Else If @Form_Name='A'
	Begin		
	Select @For_date = max(For_Date)  from dbo.T0050_HRMS_Appraisal_Setting R WITH (NOLOCK)
	   where  
			isnull(R.Branch_ID,0) = isnull(@Branch_ID ,isnull(R.Branch_ID,0))
			and isnull(R.Grade_ID,0) = isnull(@Grd_ID ,isnull(R.Grade_id,0))
			and isnull(R.Desig_ID,0) = isnull(@Desig_ID ,isnull(R.Desig_ID,0))
			and isnull(R.Dept_ID,0) = isnull(@Dept_ID ,isnull(R.Dept_ID,0))

		--insert into #Appr_ID
		select H.Appr_Id,H.Min_Appraisal,H.Max_Appraisal from dbo.T0050_HRMS_Appraisal_Setting H WITH (NOLOCK)
			left outer join dbo.t0030_branch_master B WITH (NOLOCK) on H.Branch_Id=B.branch_ID
			left outer join dbo.t0040_designation_master Des WITH (NOLOCK) on H.Desig_ID = Des.Desig_ID
			left outer join dbo.t0040_department_master Dm WITH (NOLOCK) on H.Dept_ID = Dm.Dept_id
			left outer join dbo.t0040_grade_master G WITH (NOLOCK) on H.Grade_ID = G.Grd_ID		
		where For_Date =@For_date and 
			isnull(H.Branch_ID,0) = isnull(@Branch_ID ,isnull(H.Branch_ID,0))
			and isnull(H.Grade_ID,0) = isnull(@Grd_ID ,isnull(H.Grade_id,0))
			and (isnull(H.Desig_ID,0)=0 or isnull(H.Desig_ID,0) = isnull(@Desig_ID ,isnull(H.Desig_ID,0)))
			and (isnull(H.Dept_ID,0)=0 or isnull(H.Dept_ID,0) = isnull(@Dept_ID ,isnull(H.Dept_ID,0)))  
			--and isnull(H.Desig_ID,0) = isnull(@Desig_ID ,isnull(H.Desig_ID,0))
			--and isnull(H.Dept_ID,0) = isnull(@Dept_ID ,isnull(H.Dept_ID,0)) 			 		
	RETURN		
End
	
--P0055_HRMS_Appr_FeedBack_Question_get 
--Select * from T0050_HRMS_Appraisal_Setting where cmp_id=26 and Branch_ID=22




