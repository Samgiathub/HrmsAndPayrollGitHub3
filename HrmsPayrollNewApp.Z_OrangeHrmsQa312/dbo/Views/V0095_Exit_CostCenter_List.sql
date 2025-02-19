


CREATE VIEW [dbo].[V0095_Exit_CostCenter_List]
AS
SELECT     EC.Emp_id, CM.Center_Name, EM.Emp_Full_Name, EC.Cmp_id, EM.Alpha_Emp_Code, EC.Effective_Date, EC.Center_ID
FROM         dbo.T0095_Exit_Clearance AS EC WITH (NOLOCK) INNER JOIN
                          (SELECT     MAX(Effective_Date) AS Effective_Date, Center_ID
                            FROM          dbo.T0095_Exit_Clearance WITH (NOLOCK) 
                            GROUP BY Center_ID) AS Qry ON Qry.Center_ID = EC.Center_ID AND Qry.Effective_Date = EC.Effective_Date INNER JOIN
                      dbo.T0040_COST_CENTER_MASTER AS CM WITH (NOLOCK)  ON EC.Center_ID = CM.Center_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = EC.Emp_id

