



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_SKILL_DETAILS]
	@CMP_ID NUMERIC(18,0),
	@BRANCH_ID NUMERIC(18,0),
	@GRD_ID NUMERIC(18,0),
	@DEPT_ID NUMERIC(18,0),
	@DESIG_ID NUMERIC(18,0),
	@Skill  varchar(20)='Skill_RECORD'
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @BRANCH_ID = 0 
	  SET @BRANCH_ID = null
	 
	if @GRD_ID = 0
		set @GRD_ID=null
		
	if @DEPT_ID = 0
	  set @DEPT_ID =null
	  
	if @DESIG_ID =0 
	  set @DESIG_ID = null   
	
	Declare @Skill_d_id as numeric
	 
	Select @Skill_d_id = Skill_d_id from T0050_HRMS_Skill_Rate_Setting WITH (NOLOCK)
	       Where Cmp_ID = @Cmp_ID     
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
		   
		   Declare @Skill_Table Table
		   (
		     Skill_Id numeric(18,0),
		     Skill_Detail_Id numeric(18,0),
		     Skill_name varchar(100),
		     Skill_Actual_Rate numeric(18,0),
		     Skill_R_Rate_Min numeric(18,0),
		     Skill_R_Rate_Max numeric(18,0),
		     Skilll_Rate_Given numeric(18,0),		     
		      Emp_Skill_Id numeric(18,0)
		   )
		   --size change of skill name by sneha on 9/2/2013
		if @Skill ='Skill_RECORD' 
			 Begin			 
			 insert into @Skill_Table
			      Select SM.Skill_ID,Skill_Detail_ID,Skill_name,Skill_Actual_Rate,Skill_R_Rate_Min,Skill_R_Rate_Max,0,0 from T0055_HRMS_Skill_Rate_Detail SR WITH (NOLOCK)			      
			        LEFT OUTER join T0040_Skill_Master SM WITH (NOLOCK) on SR.Skill_ID =SM.Skill_ID
			       where Skill_d_ID = @Skill_d_id			      
			 End
			 
			 select * from @Skill_Table
	RETURN




