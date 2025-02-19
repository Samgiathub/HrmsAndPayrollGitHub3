




CREATE VIEW [dbo].[V0095_EmployeeGoalSetting_Evaluation]
AS
SELECT     dbo.T0095_EmployeeGoalSetting_Evaluation.Cmp_Id, dbo.T0095_EmployeeGoalSetting_Evaluation.Emp_GoalSetting_Review_Id, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.Emp_Id, dbo.T0095_EmployeeGoalSetting_Evaluation.FinYear, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.Review_Type, dbo.T0095_EmployeeGoalSetting_Evaluation.Review_Status, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.Emp_Comments, dbo.T0095_EmployeeGoalSetting_Evaluation.Manager_Comments, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.AdditionalAchievement, dbo.T0095_EmployeeGoalSetting_Evaluation.CreatedDate, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.CreatedBy, dbo.T0095_EmployeeGoalSetting_Evaluation.ModifiedDate, 
                      dbo.T0095_EmployeeGoalSetting_Evaluation.ModifiedBy, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '- ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Employee_Name, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name
FROM         dbo.T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_EmployeeGoalSetting_Evaluation.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0095_INCREMENT.Emp_ID AND dbo.T0095_INCREMENT.Increment_Effective_Date =
                          (SELECT     MAX(Increment_Effective_Date) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID)) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID


