





CREATE VIEW [dbo].[V0120_LTA_Medical_Approval]
AS
SELECT     dbo.T0120_LTA_Medical_Approval.LM_Apr_ID, dbo.T0120_LTA_Medical_Approval.LM_App_ID, dbo.T0120_LTA_Medical_Approval.Apr_Date, 
                      dbo.T0120_LTA_Medical_Approval.Apr_Amount, dbo.T0120_LTA_Medical_Approval.APr_Comments, dbo.T0120_LTA_Medical_Approval.Apr_Code, 
                      dbo.T0120_LTA_Medical_Approval.Emp_ID, dbo.T0120_LTA_Medical_Approval.Cmp_ID, dbo.T0120_LTA_Medical_Approval.System_Date, 
                      dbo.T0120_LTA_Medical_Approval.APR_Status, dbo.T0120_LTA_Medical_Approval.Type_ID, dbo.T0120_LTA_Medical_Approval.Login_id, 
                      dbo.T0011_LOGIN.Login_Name, dbo.T0240_LTA_Medical_Transaction.Balance_Opening, dbo.T0240_LTA_Medical_Transaction.Balance_Closing, 
                      CASE WHEN APR_Status = 0 THEN 'Pending' WHEN APR_Status = 1 THEN 'Approved' WHEN APR_Status = 2 THEN 'Rejected' END AS status, 
                      CASE WHEN T0120_LTA_Medical_Approval.type_id = 1 THEN 'LTA' WHEN T0120_LTA_Medical_Approval.type_id = 2 THEN 'Medical' END AS type_name,
                       dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0095_INCREMENT.Grd_ID, CASE WHEN CAST(dbo.T0110_LTA_Medical_Application.Leave_From_Date AS varchar(11)) 
                      = 'Jan  1 1900' THEN '' ELSE CAST(leave_from_date AS varchar(11)) END AS Leave_from_date, 
                      CASE WHEN CAST(dbo.T0110_LTA_Medical_Application.Leave_to_Date AS varchar(11)) 
                      = 'Jan  1 1900' THEN '' ELSE CAST(leave_to_date AS varchar(11)) END AS Leave_to_date, dbo.T0110_LTA_Medical_Application.no_of_Days, 
                      dbo.T0120_LTA_Medical_Approval.effect_salary, dbo.T0120_LTA_Medical_Approval.effective_date, CASE WHEN isnull(effect_salary, 0) 
                      = 0 THEN 'No' ELSE 'Yes' END AS effect_on_salary, dbo.T0240_LTA_Medical_Transaction.Sal_Tran_ID, CASE WHEN isnull(p_status, 0) 
                      = 0 THEN 'Pending' ELSE 'Paid' END AS paid_status, ISNULL(dbo.T0240_LTA_Medical_Transaction.P_Status, 0) AS p_status, 
                      ISNULL(LP.LM_Pay_Amount, 0) AS PAID_AMOUNT, dbo.T0120_LTA_Medical_Approval.Apr_Amount - ISNULL(LP.LM_Pay_Amount, 0) 
                      AS PENDING_AMOUNT
FROM         dbo.T0120_LTA_Medical_Approval WITH (NOLOCK) LEFT OUTER JOIN
                          (SELECT     SUM(LM_Pay_Amount) AS LM_Pay_Amount, LM_Apr_ID
                            FROM          dbo.T0210_LTA_Medical_Payment WITH (NOLOCK) 
                            GROUP BY LM_Apr_ID) AS LP ON LP.LM_Apr_ID = dbo.T0120_LTA_Medical_Approval.LM_Apr_ID LEFT OUTER JOIN
                      dbo.T0110_LTA_Medical_Application WITH (NOLOCK)  ON 
                      dbo.T0120_LTA_Medical_Approval.LM_App_ID = dbo.T0110_LTA_Medical_Application.LM_App_ID LEFT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID ON 
                      dbo.T0120_LTA_Medical_Approval.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0120_LTA_Medical_Approval.Login_id = dbo.T0011_LOGIN.Login_ID LEFT OUTER JOIN
                      dbo.T0240_LTA_Medical_Transaction WITH (NOLOCK)  ON dbo.T0120_LTA_Medical_Approval.LM_Apr_ID = dbo.T0240_LTA_Medical_Transaction.LM_Apr_ID




