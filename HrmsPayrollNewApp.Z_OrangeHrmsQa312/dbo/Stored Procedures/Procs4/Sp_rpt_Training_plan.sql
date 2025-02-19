


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Sp_rpt_Training_plan]
	
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  
	,@Cat_ID        numeric 
	,@Grd_ID		numeric 
	,@Type_ID       numeric 
	,@Dept_ID		numeric 
	,@Desig_ID		numeric 
	,@Emp_ID		numeric 
	,@Constraint	varchar(5000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if isnull(@Branch_ID,0) > 0
		begin
			select * from V0120_HRMS_TRAINING_APPROVAL where 
			isnull(branch_id,0) = isnull(@Branch_ID,0)  and 
			Training_Date >= cast(@From_Date as varchar(12)) and Training_End_Date <= cast(@To_Date as varchar(12)) 
			and  cmp_id = @cmp_id order by Training_Date asc
		end
		 
	else if isnull(@Grd_ID,0) > 0
		begin
			select * from V0120_HRMS_TRAINING_APPROVAL where 
			isnull(grd_id,0) = @Grd_ID and
			Training_Date >= cast(@From_Date as varchar(12)) and Training_End_Date <= cast(@To_Date as varchar(12)) 
			and  cmp_id = @cmp_id order by Training_Date asc
		end	
		
	else if isnull(@Desig_ID,0) > 0
		begin
			select * from V0120_HRMS_TRAINING_APPROVAL where 
			isnull(Desig_id,0) = @Desig_ID and
			Training_Date >= cast(@From_Date as varchar(12)) and Training_End_Date <= cast(@To_Date as varchar(12)) 
			and  cmp_id = @cmp_id order by Training_Date asc	
		end
		
	else if isnull(@Dept_ID,0) > 0
		begin
			select * from V0120_HRMS_TRAINING_APPROVAL where 
			isnull(dept_id,0) = @Dept_ID and
			Training_Date >= cast(@From_Date as varchar(12)) and Training_End_Date <= cast(@To_Date as varchar(12)) 
			and  cmp_id = @cmp_id order by Training_Date asc	
		end
			
		else
		select * from V0120_HRMS_TRAINING_APPROVAL where 
			Training_Date >= cast(@From_Date as varchar(12)) and Training_End_Date <= cast(@To_Date as varchar(12)) 
			and  cmp_id = @cmp_id order by Training_Date asc
	RETURN




