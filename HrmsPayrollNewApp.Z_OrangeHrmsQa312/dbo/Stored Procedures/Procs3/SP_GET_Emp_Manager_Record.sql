
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_Emp_Manager_Record]  
	@Cmp_Id numeric(18,0),  
	@Emp_ID numeric(18,0),
	@Emp_Search int=0  
AS
begin 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 select Emp_ID,Emp_Full_Name_new from v0080_employee_MASTER 
	 where Cmp_ID=@Cmp_Id
	 And Emp_ID <> @Emp_ID And isnull(def_id,0) = 1  and Emp_Left<>'Y' 
	 order by 
			Case @Emp_Search 
						when 0
							then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
						when 1
							then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
						when 2
							then  cast( Alpha_Emp_Code as varchar)
						When 3 Then
							Emp_First_Name
						When 4 Then
							Emp_First_Name
						Else
							--RIGHT(REPLICATE(N' ', 500) + Emp.ALPHA_EMP_CODE, 500)  commented By Mukti 30042015
							Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else Alpha_Emp_Code  --Mukti 30042015
						end
				End
end




