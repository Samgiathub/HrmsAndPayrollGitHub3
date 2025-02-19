
CREATE VIEW [dbo].[V0100_Canteen_FingerPrint_Register]
AS
	--SELECT DISTINCT M.Emp_ID,M.Alpha_Emp_Code,M.Emp_Full_Name,F.Cmp_ID--,F.sysDatetime as ForDate
	--FROM T0051_WebService_FingerPrint_Details  F With (NOLOCK) inner join 
	--T0080_EMP_MASTER M With (NOLOCK) on F.Emp_ID = m.Emp_ID

	
	Select Emp_id, Alpha_Emp_Code,Emp_Full_Name,Cmp_ID 
	from T0080_EMP_MASTER  
	where Emp_Left = 'N' and Emp_ID in (Select Emp_ID from T0051_WebService_FingerPrint_Details)
