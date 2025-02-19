


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_Employee_Tree_EMP_APP]
	@Cmp_Id int,  
@Desig_id int,  
@Branch_ID  int,
@Emp_ID int =0,
@Emp_Search int=0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 if @Branch_ID =0
   set @Branch_ID =NULL

Declare @is_Designationwise tinyint

select @is_Designationwise = ISNULL(is_organo_designationwise,0) from T0010_COMPANY_MASTER WITH (NOLOCK)
 where Cmp_Id = @Cmp_Id  

if @is_Designationwise = 1
begin



;with Up_Level_Tree (des_id, parent_id)
as
(
	
	select Desig_ID,Parent_ID from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Desig_ID=@Desig_id
	union all
	select dm.Desig_ID,dm.Parent_ID from T0040_DESIGNATION_MASTER dm WITH (NOLOCK) inner join Up_Level_Tree ul on dm.Desig_ID = ul.parent_id 
)
Select Emp_ID, Emp_Full_Name_new as Emp_Full_Name from v0080_employee_MASTER as emp
inner join 
Up_Level_Tree as rec on rec.des_id = emp.Desig_Id
Where Cmp_ID=@Cmp_Id and (Emp_Left<>'Y' or
 (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))  
and rec.des_id <> @Desig_id
--and emp.Emp_ID <> @Emp_ID   
--commented binal
order by 

	Case @Emp_Search 
				When 3 Then
					emp.Emp_First_Name
				When 4 Then
					emp.Emp_First_Name
				Else
					RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)
				End


 OPTION (MAXRECURSION 32767) 

end
else if @is_Designationwise = 0 
begin


	Select Emp_ID,
	
	case @Emp_Search 
			when 0
				then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
			when 1
				then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
			when 2
				then  cast( Alpha_Emp_Code as varchar)
			when 3
				then  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
			when 4
				then  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name
	
	from v0080_employee_MASTER as emp
	Where Cmp_ID=@Cmp_Id and (Emp_Left<>'Y' or (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))  
	--and emp.Emp_ID <> @Emp_ID 
	--commneted binal 
	order by 
	
	Case @Emp_Search 
				When 3 Then
					emp.Emp_First_Name
				When 4 Then
					emp.Emp_First_Name
				Else
					RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)
				End
	
	
end


					
RETURN  




