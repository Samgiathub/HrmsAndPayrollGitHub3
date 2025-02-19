




 
CREATE VIEW [dbo].[Active_InActive_Users_Mobile]

AS

SELECT VM.Emp_ID,VM.Cmp_ID,Emp_Full_Name,Dept_Name,Desig_Name,Gender,Branch_Name,Emp_Left,ISNULL(is_for_mobile_Access,0) AS 'is_for_mobile_Access',
LM.Login_Name,LM.Is_Active,VM.Emp_Left_Date,VM.Emp_First_Name,VM.Emp_Second_Name,VM.Emp_Last_Name,VM.Alpha_Emp_Code,VM.Grd_Name,VM.Emp_code
FROM V0080_Employee_Master VM WITH (NOLOCK)
INNER JOIN T0011_LOGIN LM  WITH (NOLOCK) ON VM.Emp_ID = LM.Emp_ID
WHERE VM.Emp_Left = 'N' OR (VM.Emp_Left = 'Y' AND VM.Emp_Left_Date >= GETDATE())




