




-- zalak summary of training  -- 25-sep-2010
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_TRAINING_SUMMARY]   
   @Cmp_ID numeric(18,0),  
   @training_apr_id numeric(18,0)  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
		select * from v0120_HRMS_TRAINING_APPROVAL	where Training_Apr_ID=@training_apr_id
		
		select count(emp_id)as total_emp from v0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by Training_Apr_ID having Training_Apr_ID=@training_apr_id
		
		select count(emp_id)as attend_emp,cast(avg(emp_score)as numeric(18,2))as emp_score,cast(avg(sup_score)as numeric(18,2))as sup_score from V0130_Training_employee_detail_chart group by is_attend,Training_Apr_ID having isnull(is_attend,0)=1 and Training_Apr_ID=@training_apr_id
		
		select count(emp_id)as branch_emp,branch_name from v0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by branch_name,Training_Apr_ID having Training_Apr_ID=@training_apr_id
		
		select count(emp_id)as dept_emp,isnull(dept_name,'not assiged')as dept_name from v0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by dept_name,Training_Apr_ID having Training_Apr_ID=@training_apr_id
		
		select count(emp_id)as desig_emp,desig_name from v0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by desig_name,Training_Apr_ID having Training_Apr_ID=@training_apr_id
		
		select top 5 sup_score,emp_id,emp_full_name_new,dept_name,branch_name,desig_name , 
					(select cmp_name from T0080_EMP_MASTER E WITH (NOLOCK) inner join T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id= e.Cmp_ID where E.emp_id = V0130_Training_employee_detail_chart.Emp_ID)cmp_name		
		from V0130_Training_employee_detail_chart where isnull(is_attend,0)=1 and Training_Apr_ID=@training_apr_id order by sup_score desc

	
		 RETURN  
  



