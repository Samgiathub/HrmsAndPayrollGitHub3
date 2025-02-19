


CREATE VIEW [dbo].[V0120_RC_Approval]
AS
SELECT     T0120_RC_Approval.RC_APR_ID,
		T0120_RC_Approval.Cmp_ID,
		T0120_RC_Approval.RC_APP_ID,
		T0120_RC_Approval.Emp_ID,
		T0120_RC_Approval.RC_ID,
		T0120_RC_Approval.Apr_Date,
		T0120_RC_Approval.Apr_Amount,
		T0120_RC_Approval.Taxable_Exemption_amount,
		T0120_RC_Approval.APr_Comments,
		T0120_RC_Approval.APR_Status,
		T0120_RC_Approval.RC_Apr_Effect_In_Salary,
		T0120_RC_Approval.RC_Apr_Cheque_No,
		T0120_RC_Approval.Payment_Mode,
		T0120_RC_Approval.CreateBy,
		T0120_RC_Approval.DateCreated,
		T0120_RC_Approval.ModifyBy,
		T0120_RC_Approval.ModifyDate,
		T0120_RC_Approval.payment_date,

          
           --dbo.T0240_LTA_Medical_Transaction.Balance_Opening,
           --dbo.T0240_LTA_Medical_Transaction.Balance_Closing, 
           CASE WHEN APR_Status = 0 THEN 'Pending' WHEN APR_Status = 1 THEN 'Approved' WHEN APR_Status = 2 THEN 'Rejected' END AS status, 
         
           dbo.T0080_EMP_MASTER.Emp_Full_Name, 
           dbo.T0080_EMP_MASTER.Emp_code, 
           dbo.T0095_INCREMENT.Branch_ID, 
           dbo.T0095_INCREMENT.Grd_ID, 
           CASE WHEN CAST(dbo.T0100_RC_Application.Leave_From_Date AS varchar(11)) 
                      = 'Jan  1 1900' THEN '' ELSE CAST(Leave_From_Date AS varchar(11)) END AS Leave_from_date, 
           CASE WHEN CAST(dbo.T0100_RC_Application.Leave_to_Date AS varchar(11)) 
                      = 'Jan  1 1900' THEN '' ELSE CAST(leave_to_date AS varchar(11)) END AS Leave_to_date 
          
         
          
FROM         dbo.T0120_RC_Approval WITH (NOLOCK) LEFT OUTER JOIN
                          --(SELECT     SUM(LM_Pay_Amount) AS LM_Pay_Amount, LM_Apr_ID
                          --  FROM          dbo.T0210_LTA_Medical_Payment
                          --  GROUP BY LM_Apr_ID) AS LP ON LP.LM_Apr_ID = dbo.T0120_LTA_Medical_Approval.LM_Apr_ID LEFT OUTER JOIN
                  
                      dbo.T0100_RC_Application  WITH (NOLOCK) on T0100_RC_Application.RC_APP_ID = T0120_RC_Approval.RC_App_ID
                      LEFT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID ON 
                      dbo.T0120_RC_Approval.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
                    
                     -- dbo.T0240_LTA_Medical_Transaction ON dbo.T0120_LTA_Medical_Approval.LM_Apr_ID = dbo.T0240_LTA_Medical_Transaction.LM_Apr_ID
