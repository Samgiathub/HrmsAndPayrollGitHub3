




-- =============================================
-- =============================================
-- Author:		Zalak
-- ALTER date: 19012011
-- Description:	--for manager history
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_ORGANIZATION_DATA_USER_UP]  
		@cmp_id as numeric,
		@branch_id as NUMERIC,
		@emp_id as NUMERIC,
		@int_level as NUMERIC,
		@MaxLevel as NUMERIC
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
					
				delete from TBL_ORGANIZATION_DISPLAY --where emp_id=@emp_id
				
				exec SP_GET_ORGANIZATION_TREE_UP @cmp_id,@branch_id,@emp_id,@int_level,@MaxLevel
				--select * from TBL_ORGANIZATION_DISPLAY
				declare @M_int_level as int
				declare @row_id as int
					select @M_int_level=max(int_level) FROM TBL_ORGANIZATION_DISPLAY WITH (NOLOCK) 			   
					  Declare curUser cursor Local for   
					   SELECT row_id FROM TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)  
					   open curUser  
					   Fetch next from curUser Into @row_id
					   while @@Fetch_Status = 0  
						begin  
							update TBL_ORGANIZATION_DISPLAY set int_level=(@M_int_level-int_level) where Row_ID=@Row_ID
							Fetch next from curUser Into @row_id
						end
						Close curUser  
					   Deallocate curUser  

					Select  replace(space(10),space(1),'.') as data1 , replace(space(Qry.Int_Level * 10),space(1),'-') as data,Qry.*,q.*,case when q.gender='F' then replace(emp_name,'2.png','1.gif') else emp_name end as emp_full_name From 
					(Select Row_ID,EMP_ID,case when is_main=1 then '<img src=image_new/dir.png border=0 />&nbsp;' else '<img src=image_new/2.png border=0 />&nbsp;' end + Cast(emp_name as varchar(500)) as emp_name, Parent_id, Int_Level,Desig_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)) Qry
					left outer join (select emp_id, emp_full_name as Employee_name, Gender,isnull(desig_name,'not assigned') as desig_name,isnull(branch_name,'not assigned') as branch_name,isnull(grd_name,'not assigned') as grd_name,isnull(dept_name,'not assigned') as dept_name,date_of_join,def_id,is_main from V0095_Increment_All_Data where emp_left<>'Y' and Increment_ID in (select Increment_ID from t0080_emp_master WITH (NOLOCK) where emp_id in (select emp_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK))))Q on Qry.emp_id = q.emp_id  order by qry.int_level
			return




