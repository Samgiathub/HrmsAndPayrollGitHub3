





CREATE VIEW [dbo].[Get_Employee_Of_Branch]
As select lo.login_ID,lo.Login_Name,lo.Login_Password,Em.Branch_ID,lo.cmp_Id,lo.Emp_Id from T0080_Emp_Master as EM WITH (NOLOCK) inner join T0011_Login as lo  WITH (NOLOCK) on Em.Emp_ID = lo.emp_ID 




