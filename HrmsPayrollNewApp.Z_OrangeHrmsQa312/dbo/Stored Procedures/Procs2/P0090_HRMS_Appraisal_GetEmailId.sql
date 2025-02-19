



-- =============================================
-- Author:		Ripal Patel
-- ALTER date: 1-Mar-2013
-- EXEC P0090_HRMS_Appraisal_GetEmailId 45,2370,4
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_GetEmailId]
	@Cmp_ID			as numeric(18,0),
	@Emp_ID			as numeric(18,0),
	@SignoffBy		as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	Declare @list as varchar(max) --Employee's Direct Manager Email ID
	if @SignoffBy = 1
		begin			
			Select  @list = coalesce(@list+',','') + Work_Email from T0080_EMP_MASTER WITH (NOLOCK)
			where Emp_ID IN (select Emp_Superior as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
			select @list as email
		end
	else if @SignoffBy = 2 --Employee,Manager's manager Email ID
		begin
			--Select Work_Email from T0080_EMP_MASTER 
			--where Emp_ID IN (
			--	  select Emp_Superior as ID from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID AND Emp_ID = (select Emp_Superior from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
			--	   union
			--	  select Emp_ID as ID from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID
			--				)			
			Select @list = coalesce(@list+',','') + Work_Email from T0080_EMP_MASTER WITH (NOLOCK)
			where Emp_ID IN (
				  select Emp_Superior as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = (select Emp_Superior from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
				   union
				  select Emp_ID as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID
							)
			select @list as email
							
		end
	else if @SignoffBy = 3 --Employee,Direct Manager Email ID
		begin
			Select @list = coalesce(@list+',','') + Work_Email from T0080_EMP_MASTER WITH (NOLOCK)
			where Emp_ID IN (select Emp_Superior as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID union
							 select Emp_ID as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
			select @list as email
		end	
	else if @SignoffBy = 4 -- Employee,Direct Manager,Manager's manager Email ID
		begin
			Select @list = coalesce(@list+',','') + Work_Email from T0080_EMP_MASTER WITH (NOLOCK)
			where Emp_ID IN (
				  select Emp_Superior as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = (select Emp_Superior from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID)
				   union
				   select Emp_Superior from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID
				   union
				  select Emp_ID as ID from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID
							)
			select @list as email
		end	
	else if @SignoffBy = 5 -- Employee's Email ID
		begin
			Select  Work_Email as email from T0080_EMP_MASTER WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID			
		end	
END



