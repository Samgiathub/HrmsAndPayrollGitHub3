


--BEGIN TRAN

CREATE VIEW [dbo].[V0095_Dept_HOD_Detail]
AS
SELECT     Qr.Dept_Name,E.Emp_ID,E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name as Emp_Full_Name, E.Work_Email, D.Dept_Id,D.Cmp_id
FROM         dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) INNER JOIN
                      dbo.T0095_Department_Manager AS D WITH (NOLOCK)  ON E.Emp_ID = D.Emp_id INNER JOIN
                          (SELECT     MAX(DM.Effective_Date) AS Effective_Date, DE.Dept_Id, DE.Dept_Name
                            FROM          dbo.T0095_Department_Manager AS DM WITH (NOLOCK)  INNER JOIN
                                                   dbo.T0040_DEPARTMENT_MASTER AS DE WITH (NOLOCK)  ON DE.Dept_Id = DM.Dept_Id
                            GROUP BY DE.Dept_Id, DE.Dept_Name) AS Qr ON Qr.Dept_Id = D.Dept_Id AND Qr.Effective_Date = D.Effective_Date




