





CREATE VIEW [dbo].[Vw0080_Employee_Master]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Cmp_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Second_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, 
                      dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.Basic_Salary, dbo.T0040_SHIFT_MASTER.Shift_Name, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0080_EMP_MASTER.Gender, 
                      dbo.T0040_TYPE_MASTER.Type_Name
FROM         dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0040_DEPARTMENT_MASTER.Dept_Id = dbo.T0080_EMP_MASTER.Dept_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID INNER JOIN
                      dbo.T0040_SHIFT_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Shift_ID = dbo.T0040_SHIFT_MASTER.Shift_ID INNER JOIN
                      dbo.T0040_TYPE_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Type_ID = dbo.T0040_TYPE_MASTER.Type_ID




