CREATE PROCEDURE [dbo].[P0040_Emp_Name_Display_ESS]
@Cmp_Id numeric(18,0),
@Emp_Id numeric(18,0)


As 
Begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		select Emp_ID,Cmp_ID,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,Shift_Name,Dept_Name,Grd_Name,Emp_Full_Name_new,Emp_Full_Name,
		Work_Tel_No,Mobile_No,Date_Of_Birth,Emp_Full_Name_Superior,Emp_Superior,Desig_Id,Desig_Name,Cmp_Name,DEPT_Id,Branch_Name,Branch_ID,Alpha_Emp_Code,Alpha_Code
		from V0080_Employee_Master where cmp_Id= @Cmp_Id and Emp_Id = @Emp_Id	
			
End