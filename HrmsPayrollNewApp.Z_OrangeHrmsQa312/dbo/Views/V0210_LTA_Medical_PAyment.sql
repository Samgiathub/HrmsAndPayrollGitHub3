





CREATE VIEW [dbo].[V0210_LTA_Medical_PAyment]
AS
SELECT     dbo.T0210_LTA_Medical_Payment.LM_Pay_ID, dbo.T0210_LTA_Medical_Payment.LM_Apr_ID, dbo.T0210_LTA_Medical_Payment.Cmp_ID, 
                      dbo.T0210_LTA_Medical_Payment.Sal_Tran_ID, dbo.T0210_LTA_Medical_Payment.S_Sal_Tran_ID, dbo.T0210_LTA_Medical_Payment.L_Sal_Tran_ID, 
                      dbo.T0210_LTA_Medical_Payment.LM_Pay_Amount, dbo.T0210_LTA_Medical_Payment.LM_Pay_Comments, 
                      dbo.T0210_LTA_Medical_Payment.LM_Payment_Date, dbo.T0210_LTA_Medical_Payment.LM_Payment_Type, 
                      dbo.T0210_LTA_Medical_Payment.Bank_Name, dbo.T0210_LTA_Medical_Payment.LM_Cheque_No, dbo.T0210_LTA_Medical_Payment.LM_Pay_Code, 
                      dbo.T0120_LTA_Medical_Approval.Type_ID, dbo.T0120_LTA_Medical_Approval.Apr_Amount, dbo.T0120_LTA_Medical_Approval.Apr_Code, 
                      dbo.T0120_LTA_Medical_Approval.Apr_Date, CASE WHEN ISNULL(SAL_TRAN_ID, 0) > 0 THEN 'Salary' WHEN isnull(s_sal_tran_id, 0) 
                      > 0 THEN 'Settlement' WHEN isnull(l_sal_tran_id, 0) > 0 THEN 'Final Settlement' ELSE '' END AS P_status, 
                      CASE WHEN type_id = 1 THEN 'LTA' WHEN type_id = 2 THEN 'Medical' END AS Type_name, dbo.T0120_LTA_Medical_Approval.Emp_ID
FROM         dbo.T0120_LTA_Medical_Approval WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0210_LTA_Medical_Payment WITH (NOLOCK)  ON dbo.T0120_LTA_Medical_Approval.LM_Apr_ID = dbo.T0210_LTA_Medical_Payment.LM_Apr_ID




