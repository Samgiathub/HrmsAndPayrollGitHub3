




CREATE VIEW [dbo].[V0050_Training_Wise_CheckList]
AS
SELECT     HTM.Training_id, HTM.Training_name, W_Qry.Effective_Date, HTM.Cmp_Id,W_Qry.Tran_ID,W_Qry.Assign_Checklist
FROM         dbo.T0040_Hrms_Training_master AS HTM WITH (NOLOCK) INNER JOIN
                      dbo.T0030_Hrms_Training_Type AS HTT WITH (NOLOCK)  ON HTM.Training_Type = HTT.Training_Type_ID INNER JOIN
                          (SELECT     TWC.Effective_Date, TWC.Training_ID,Tran_ID,Assign_Checklist
                            FROM          dbo.T0050_Training_Wise_CheckList AS TWC WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(Effective_Date) AS Effective_date, Training_ID
                                                         FROM          dbo.T0050_Training_Wise_CheckList WITH (NOLOCK) 
                                                         --WHERE      (Effective_Date < GETDATE())
                                                         GROUP BY Training_ID) AS Qry ON Qry.Training_ID = TWC.Training_ID AND Qry.Effective_date = TWC.Effective_Date) AS W_Qry ON 
                      W_Qry.Training_ID = HTM.Training_id



