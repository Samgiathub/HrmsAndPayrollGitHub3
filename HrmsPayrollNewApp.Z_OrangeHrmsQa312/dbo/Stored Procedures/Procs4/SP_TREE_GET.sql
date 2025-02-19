

---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---


CREATE PROCEDURE [dbo].[SP_TREE_GET] 
	
		 
		    @desig_id as numeric
		    ,@cmp_id  as numeric
			
			
AS			

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

declare @MaxLevel as numeric(18,0)
set @MaxLevel = 21

if @desig_id = 0
		set @desig_id = null

	Declare @Emp_detail Table
	(
		Emp_ID	numeric(18,0),
		emp_name varchar(50),
		desig_id  numeric(18,0),
		parent_id numeric(18,0)
	)
   		
   	insert into @Emp_detail(Emp_ID,emp_name, desig_id, parent_id) 
   	select emp_id, emp_full_name, desig_id, parent_id from v0080_employee_master where cmp_id = @cmp_id
   			
   	select * from @Emp_detail	
			
	RETURN
	



