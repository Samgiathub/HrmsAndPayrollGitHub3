




CREATE VIEW [dbo].[V0090_Emp_JD_Responsibilty]
AS
SELECT     JR.Emp_Id, E.Emp_Full_Name, E.Alpha_Emp_Code, JR.JDCode_Id, JR.EffectiveDate, JM.Job_Code, i.Branch_ID, i.Dept_ID, i.Desig_Id, i.Grd_ID, JR.Cmp_Id
FROM         dbo.T0090_Emp_JD_Responsibilty AS JR WITH (NOLOCK) INNER JOIN
                      dbo.T0050_JobDescription_Master AS JM WITH (NOLOCK)  ON JM.Job_Id = JR.JDCode_Id INNER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON E.Emp_ID = JR.Emp_Id LEFT OUTER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON i.Emp_ID = E.Emp_ID AND i.Increment_Effective_Date =
                          (SELECT     MAX(Increment_Effective_Date) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                            WHERE      (Emp_ID = E.Emp_ID))
GROUP BY JR.Emp_Id, E.Emp_Full_Name, E.Alpha_Emp_Code, JR.JDCode_Id, JR.EffectiveDate, JM.Job_Code, i.Branch_ID, i.Dept_ID, i.Desig_Id, i.Grd_ID, JR.Cmp_Id



