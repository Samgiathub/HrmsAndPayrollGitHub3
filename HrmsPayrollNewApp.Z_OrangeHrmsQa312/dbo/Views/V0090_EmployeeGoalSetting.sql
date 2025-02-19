



CREATE VIEW [dbo].[V0090_EmployeeGoalSetting]
AS
SELECT     dbo.T0090_EmployeeGoalSetting.Emp_GoalSetting_Id, dbo.T0090_EmployeeGoalSetting.Cmp_Id, dbo.T0090_EmployeeGoalSetting.Emp_Id, 
                      dbo.T0090_EmployeeGoalSetting.EGS_Status, dbo.T0090_EmployeeGoalSetting.FinYear, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '- ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Employee_Name, 
                      dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, DG.Desig_Name, D.Dept_Name, dbo.T0090_EmployeeGoalSetting.Emp_Comment, 
                      dbo.T0090_EmployeeGoalSetting.Manager_Comment
FROM         dbo.T0090_EmployeeGoalSetting WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_EmployeeGoalSetting.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND dbo.T0095_INCREMENT.Increment_Effective_Date =
                          (SELECT     MAX(Increment_Effective_Date) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID)) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK)  ON D.Dept_Id = dbo.T0095_INCREMENT.Dept_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK)  ON DG.Desig_ID = dbo.T0095_INCREMENT.Desig_Id


