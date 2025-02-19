





CREATE VIEW [dbo].[V1000_Employee_Joining_Report]
AS
SELECT     e.Emp_ID, e.Emp_Full_Name, e.Emp_Left, e.Date_Of_Join, e.Gender, d.Dept_Name, de.Desig_Name, dbo.T0040_SHIFT_MASTER.Shift_Name, 
                      dbo.T0040_SKILL_MASTER.Skill_Name, dbo.T0040_GRADE_MASTER.Grd_Name, e.Emp_code, dbo.T0040_TYPE_MASTER.Type_Name, e.Street_1, 
                      e.City, e.State, e.Zip_code, e.Present_Street, e.Present_City, e.Present_State, e.Present_Post_Box
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  INNER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS d WITH (NOLOCK)  ON e.Dept_ID = d.Dept_Id INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS de WITH (NOLOCK)  ON e.Desig_Id = de.Desig_ID INNER JOIN
                      dbo.T0040_SHIFT_MASTER WITH (NOLOCK)  ON e.Shift_ID = dbo.T0040_SHIFT_MASTER.Shift_ID ON dbo.T0040_GRADE_MASTER.Grd_ID = e.Grd_ID INNER JOIN
                      dbo.T0040_TYPE_MASTER WITH (NOLOCK)  ON e.Type_ID = dbo.T0040_TYPE_MASTER.Type_ID LEFT OUTER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  INNER JOIN
                      dbo.T0090_EMP_SKILL_DETAIL WITH (NOLOCK)  ON dbo.T0040_SKILL_MASTER.Skill_ID = dbo.T0090_EMP_SKILL_DETAIL.Skill_ID ON 
                      e.Emp_ID = dbo.T0090_EMP_SKILL_DETAIL.Emp_ID




