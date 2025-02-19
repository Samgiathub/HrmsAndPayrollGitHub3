-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 27/12/2023
-- Description:	Employee Directory Mobile API
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_EmployeeDirectory_Data]
	@Cmp_ID numeric(18,0)
AS
BEGIN
	Select Emp_Full_Name,Blood_Group,Mobile_No, 
	(CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' THEN (CASE WHEN Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END) AS 'Image_Name',
		'' AS 'Image_Path'
	From T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Emp_Left='N'
END
