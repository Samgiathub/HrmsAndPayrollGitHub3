



CREATE VIEW [dbo].[V0095_BalanceScoreCard_Evaluation]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '- ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Employee_Name, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, DG.Desig_Name, D.Dept_Name, dbo.T0095_BalanceScoreCard_Evaluation.Emp_BSC_Review_Id, 
                      dbo.T0095_BalanceScoreCard_Evaluation.Cmp_Id, dbo.T0095_BalanceScoreCard_Evaluation.Emp_Id, dbo.T0095_BalanceScoreCard_Evaluation.FinYear, 
                      dbo.T0095_BalanceScoreCard_Evaluation.Review_Type, dbo.T0095_BalanceScoreCard_Evaluation.Review_Status, 
                      dbo.T0095_BalanceScoreCard_Evaluation.Emp_Comment, dbo.T0095_BalanceScoreCard_Evaluation.Manager_Comment
FROM         dbo.T0095_BalanceScoreCard_Evaluation WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_BalanceScoreCard_Evaluation.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND dbo.T0095_INCREMENT.Increment_Effective_Date =
                          (SELECT     MAX(Increment_Effective_Date) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID)) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK)  ON D.Dept_Id = dbo.T0095_INCREMENT.Dept_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK)  ON DG.Desig_ID = dbo.T0095_INCREMENT.Desig_Id


