



CREATE VIEW [dbo].[V0011_Login_Eamil_Data]
AS
SELECT     emp.Alpha_Emp_Code, emp.Emp_Full_Name, Qry.Email_id, Qry.Designation, emp.Emp_Left
FROM         (SELECT     Emp_ID, Login_Name, Email_ID_Accou AS Email_id, 'Accountant' AS Designation
                       FROM          dbo.T0011_LOGIN WITH (NOLOCK)
                       WHERE      (Is_Accou = 1) AND (Emp_ID > 0) AND (Cmp_ID = 2)
                       UNION ALL
                       SELECT     Emp_ID, Login_Name, Email_ID AS Email_id, 'HR' AS Designation
                       FROM         dbo.T0011_LOGIN AS T0011_LOGIN_1 WITH (NOLOCK)
                       WHERE     (Is_HR = 1) AND (Emp_ID > 0) AND (Cmp_ID = 2)) AS Qry INNER JOIN
                      dbo.T0080_EMP_MASTER AS emp WITH (NOLOCK) ON emp.Emp_ID = Qry.Emp_ID AND emp.Cmp_ID = 2


