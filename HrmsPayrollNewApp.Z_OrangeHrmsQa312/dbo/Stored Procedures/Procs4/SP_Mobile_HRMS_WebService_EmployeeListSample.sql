CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_EmployeeListSample]
	
	@Cmp_ID numeric(18,0)
	
	--@Result VARCHAR(MAX) OUTPUT
AS
begin
		select Emp_ID,Alpha_Emp_Code,Emp_First_Name,Emp_Last_Name,Date_Of_Birth,GroupJoiningDate from T0080_EMP_MASTER where Cmp_ID=@Cmp_ID
		return 
		end
