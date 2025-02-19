


CREATE VIEW [dbo].[View_Reimbursement_Final_N_level_Approval]
AS
SELECT     RA.Cmp_ID, RA.AD_NAME, RA.Taxable, RA.RC_APP_ID, RA.Emp_ID, RA.APP_Date, RA.APP_Tax_Free_Amount, RA.APP_Tax_Amount, qry.Apr_Amount AS APR_Tax_Free_Amount, 
                      qry.Taxable_Exemption_Amount AS APR_Tax_Amount, RA.APP_Comments, qry.APR_Status AS APP_Status, RA.Leave_From_Date, RA.Leave_To_Date, RA.Days, RA.Emp_code, RA.Emp_Full_Name, 
                      RA.Emp_First_Name, CASE WHEN Qry.APR_Status = 1 THEN 'Approved' ELSE 'Rejected' END AS Status, RA.RC_Apr_ID, RA.FY, RA.Alpha_Emp_Code, RA.Branch_ID, RA.Is_Manager_Record, 
                      qry.S_emp_ID AS S_Emp_ID_A, RA.Submit_Flag
FROM         dbo.V0100_RC_Application AS RA WITH (NOLOCK) INNER JOIN
                          (SELECT     RLA.RC_App_ID, RLA.S_emp_ID, RLA.APR_Status, RLA.Apr_Amount, RLA.Taxable_Exemption_Amount
                            FROM          dbo.T0115_RC_Level_Approval AS RLA WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(Rpt_Level) AS Rpt_Level, RC_App_ID
                                                         FROM          dbo.T0115_RC_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY RC_App_ID) AS Qry ON Qry.Rpt_Level = RLA.Rpt_Level AND Qry.RC_App_ID = RLA.RC_App_ID INNER JOIN
                                                   dbo.V0100_RC_Application AS LA WITH (NOLOCK)  ON LA.RC_APP_ID = RLA.RC_App_ID
                            WHERE      (RLA.APR_Status = 1) OR
                                                   (RLA.APR_Status = 2)) AS qry ON RA.RC_APP_ID = qry.RC_App_ID

