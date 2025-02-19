

 ---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_Timesheet_Employee]  
	@Cmp_Id numeric(18,0),  
	@Desig_id numeric(18,0),  
	@Branch_ID  numeric(18,0)=0,
	--@Emp_ID numeric(18,0),
	@Emp_Search int=0  --Mukti 30042015
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 if @Branch_ID =0
	   set @Branch_ID =NULL

		begin
			Select Emp_ID,
			--Emp_Full_Name_new as Emp_Full_Name 
			case @Emp_Search 
			--added By Mukti(start)30042015
					when 0
						then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
					when 1
						then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
					when 2
						then  cast( Alpha_Emp_Code as varchar)
			--added By Mukti(end)30042015
					when 3
						then  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
					when 4
						then  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar)	
					end as Emp_Full_Name
			
			from v0080_employee_MASTER as emp
			Where Cmp_ID=@Cmp_Id and (Emp_Left<>'Y' or (Emp_Left='Y' and convert(varchar(10),isnull(Emp_Left_Date,0),120) > convert(varchar(10),getdate(),120)))  
			--AND Desig_Name = 'Project Manager'
			--and emp.Emp_ID <> @Emp_ID 
			order by --Emp_Full_Name_new
			--Added by Ramiz on 18-10-2014	
			Case @Emp_Search
			----added By Mukti(start)30042015
			--			when 0
			--				then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
			--			when 1
			--				then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
			--			when 2
			--				then  cast( Alpha_Emp_Code as varchar)
			----added By Mukti(end)30042015				
						When 3 Then
							emp.Emp_First_Name
						When 4 Then
							emp.Emp_First_Name
						--Else  commented By Mukti 30042015
						--	RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)
						Else
							Case When IsNumeric(emp.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + emp.Alpha_Emp_Code, 20)
							When IsNumeric(emp.Alpha_Emp_Code) = 0 then Left(emp.Alpha_Emp_Code + Replicate('',21), 20)
							Else emp.Alpha_Emp_Code  --Mukti 30042015
						End
					end
		--Ended by Ramiz on 18-10-2014	
	end
		
RETURN  




