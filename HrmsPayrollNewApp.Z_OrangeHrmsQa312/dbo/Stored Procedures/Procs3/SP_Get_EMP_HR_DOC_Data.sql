
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_EMP_HR_DOC_Data]
   @emp_id  numeric(18,0) 
  ,@Cmp_ID  numeric (18,0)
  ,@Branch_ID  numeric(18,0)  
  ,@Grd_ID  numeric(18,0)
  ,@Dept_ID  numeric(18,0)
  ,@Desig_ID  numeric(18,0)
  ,@type int = 0
as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID =0
		set @Branch_ID=null
	if @Grd_ID = 0
	   set @Grd_ID = null
	if @Dept_ID =0
	   set @Dept_ID = null
	if @desig_id = 0
	   set @desig_id=null
	declare @gender as char(1)
		set @gender='M'
		
	if isnull(@type,0) = 0
	begin	
	if @emp_id<> 0
		begin
		
			select @Branch_ID=branch_id,@Grd_ID=grd_id,@Dept_ID=dept_id,@Desig_ID=desig_id,@gender=(case when initial='Mr.' then 'M' else 'F' end) from v0080_employee_master where emp_id=@emp_id
			select Doc_Title + ' (for ' + case when gender='M' then 'male' when gender='F' then 'female' else 'any' end + ')' as doc_title ,HR_DOC_ID from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and gender=@gender  
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)order by Doc_Title asc
		end
	else
	 begin
		/*select distinct Doc_Title,HR_DOC_ID from T0040_HR_DOC_MASTER Where Cmp_ID = @Cmp_ID and isnull(gender,'M')=@gender 
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0) order by Doc_Title asc*/
				/*select emp_full_name,emp_id from v0080_employee_master Where Cmp_ID = @Cmp_ID and emp_left<>'F'
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)order by emp_first_name asc
				
				commented on 4th june 2012
				*/
		/*Added by sneha on june 4 2012*/
		select cast(emp_code as varchar(20)) + ' - ' + emp_full_name as emp_full_name,emp_id from v0080_employee_master Where Cmp_ID = @Cmp_ID and emp_left<>'F'
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)order by emp_code asc
		end
	END
	ELSE
	BEGIN
	if @emp_id<> 0
		begin
		
			select @Branch_ID=branch_id,@Grd_ID=grd_id,@Dept_ID=dept_id,@Desig_ID=desig_id,@gender=(case when initial='Mr.' then 'M' else 'F' end) from V0060_HRMS_Candidates_Finalization where resume_id=@emp_id
			select Doc_Title + ' (for ' + case when gender='M' then 'male' when gender='F' then 'female' else 'any' end + ')' as doc_title ,HR_DOC_ID from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and gender=@gender 
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)order by Doc_Title asc
		end
	else
	 begin
		select cast(rec_post_code as varchar) + '-' + app_full_name as emp_full_name, resume_id as emp_id from V0060_HRMS_Candidates_Finalization Where Cmp_ID = @Cmp_ID and resume_status = 1 
				and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
				and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
				and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
				and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)order by app_full_name asc
		end
	
	END
	
	
	return




