


CREATE VIEW [dbo].[V0050_Emp_Monthly_Shift_Rotation]
AS
SELECT     ER.Cmp_ID, ER.Tran_ID, ER.Emp_ID, E.Branch_ID, E.Alpha_Emp_Code, E.Emp_Full_Name, ER.Rotation_ID, R.Rotation_Name, ER.Effective_Date, mm.Vertical_ID, 
                      mm.SubVertical_ID, mm.Dept_ID, E.Emp_First_Name
FROM         dbo.T0050_EMP_MONTHLY_SHIFT_ROTATION AS ER WITH (NOLOCK) INNER JOIN
                      dbo.T0050_SHIFT_ROTATION_MASTER AS R  WITH (NOLOCK) ON ER.Rotation_ID = R.Tran_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS E  WITH (NOLOCK) ON ER.Emp_ID = E.Emp_ID INNER JOIN
                          (SELECT     I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID
                            FROM          dbo.T0095_INCREMENT AS I  WITH (NOLOCK) INNER JOIN
                                                   dbo.T0080_EMP_MASTER AS E  WITH (NOLOCK) ON E.Emp_ID = I.Emp_ID
                            WHERE      (I.Increment_ID IN
                                                       (SELECT     MAX(Increment_ID) AS Expr1
                                                         FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                                                         GROUP BY Emp_ID))) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID

