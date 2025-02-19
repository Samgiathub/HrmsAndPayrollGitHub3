

CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_Employee_Tree]  
@Cmp_Id numeric(18,0),  
@Desig_id numeric(18,0),  
@Branch_ID  numeric(18,0)=0,
@Emp_ID numeric(18,0),
@Emp_Search int=0
AS
 if @Branch_ID =0
   set @Branch_ID =NULL

Declare @is_Designationwise tinyint

select @is_Designationwise = ISNULL(is_organo_designationwise,0) from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_Id  -- added by Mihir 02122011
-- If..Elseif Condition added by Mihir 02122011

if @is_Designationwise = 1
begin

--Alpesh 29-Aug-2011 According to new Concept -> Showing all up level 


;with Up_Level_Tree (des_id, parent_id)
as
(
	
	select Desig_ID,Parent_ID from T0040_DESIGNATION_MASTER  WITH (NOLOCK) where Desig_ID=@Desig_id
	union all
	select dm.Desig_ID,dm.Parent_ID from T0040_DESIGNATION_MASTER dm  WITH (NOLOCK) inner join Up_Level_Tree ul on dm.Desig_ID = ul.parent_id 
)
Select Emp_ID, Emp_Full_Name_new as Emp_Full_Name from v0080_employee_MASTER as emp WITH (NOLOCK) 
inner join 
Up_Level_Tree as rec on rec.des_id = emp.Desig_Id
Where Cmp_ID=@Cmp_Id and (Emp_Left<>'Y' or (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))  
and rec.des_id <> @Desig_id
and emp.Emp_ID <> @Emp_ID  -- Added by Mihir 05102011
order by 
--Added by Ramiz on 18-10-2014	
	Case @Emp_Search 
				When 3 Then
					emp.Emp_First_Name
				When 4 Then
					emp.Emp_First_Name
				Else
					RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)
				End
--Ended by Ramiz on 18-10-2014	

 OPTION (MAXRECURSION 32767) 

end
else if @is_Designationwise = 0 
begin


	Select Emp_ID,
	--Emp_Full_Name_new as Emp_Full_Name 
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
	
	from v0080_employee_MASTER as emp WITH (NOLOCK) 
	Where Cmp_ID=@Cmp_Id and (Emp_Left<>'Y' or (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))  
	and emp.Emp_ID <> @Emp_ID 
	order by --Emp_Full_Name_new
	--Added by Ramiz on 18-10-2014	
	Case @Emp_Search 
				When 3 Then
					emp.Emp_First_Name
				When 4 Then
					emp.Emp_First_Name
				Else
					RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)
				End
	--Ended by Ramiz on 18-10-2014	
	
end

 --CAST(dbo.T0080_EMP_MASTER.Emp_code AS varchar(15)) 
 --                     + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS R_Emp_Full_Name, CAST(T0080_EMP_MASTER_1.Emp_code AS varchar(15)) 
 --                     + ' - ' + T0080_EMP_MASTER_1.Emp_Full_Name AS Emp_Full_Name


--if not exists(Select Row_ID from T0090_EMP_REPORTING_DETAIL Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID)
--	begin
--		if @Emp_Superior <> null
--			exec P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@Emp_Superior,'Direct','i'
--	end
					
RETURN  




