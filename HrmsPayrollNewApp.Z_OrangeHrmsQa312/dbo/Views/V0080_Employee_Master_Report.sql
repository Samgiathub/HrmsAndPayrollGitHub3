





CREATE VIEW [dbo].[V0080_Employee_Master_Report]
AS
SELECT     e.Emp_ID, e.Emp_code, e.Emp_Full_Name, e.Cmp_ID, e.Basic_Salary, e.Date_Of_Join, e.Emp_Left, d.Desig_Name, de.Dept_Name, s.Shift_Name, 
                      c.Cmp_Name, dbo.T0040_GRADE_MASTER.Grd_Name, c.Cmp_Address, c.Cmp_Phone, e.Date_Of_Birth, e.Marital_Status, e.Nationality, e.Street_1, 
                      e.City, e.State, e.Zip_code, e.Home_Tel_no, e.Mobile_No, e.Work_Tel_No, e.Work_Email, e.Other_Email, e.Present_Street, e.Present_City, 
                      e.Present_State, e.Present_Post_Box, e.Emp_Left_Date
FROM         dbo.T0080_EMP_MASTER AS e WITH (NOLOCK) INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS d WITH (NOLOCK)  ON e.Desig_Id = d.Desig_ID AND e.Cmp_ID = d.Cmp_ID INNER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS de WITH (NOLOCK)  ON e.Dept_ID = de.Dept_Id AND e.Cmp_ID = de.Cmp_Id INNER JOIN
                      dbo.T0040_SHIFT_MASTER AS s WITH (NOLOCK)  ON e.Shift_ID = s.Shift_ID AND e.Cmp_ID = s.Cmp_ID INNER JOIN
                      dbo.T0010_COMPANY_MASTER AS c WITH (NOLOCK)  ON e.Cmp_ID = c.Cmp_Id INNER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON e.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID AND e.Cmp_ID = dbo.T0040_GRADE_MASTER.Cmp_ID




