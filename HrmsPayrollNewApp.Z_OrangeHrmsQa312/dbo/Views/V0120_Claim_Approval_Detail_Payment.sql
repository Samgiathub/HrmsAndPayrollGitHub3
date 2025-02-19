


CREATE VIEW [dbo].[V0120_Claim_Approval_Detail_Payment]
As
SELECT   distinct (dbo.T0120_CLAIM_APPROVAL.Claim_App_ID), dbo.T0120_CLAIM_APPROVAL.Claim_Apr_ID,
					  dbo.T0040_CLAIM_MASTER.Claim_Name, 
					  dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_Left, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,
                      dbo.T0120_CLAIM_APPROVAL.Cmp_ID, dbo.T0120_CLAIM_APPROVAL.Emp_ID, 
                      dbo.T0120_CLAIM_APPROVAL.Claim_ID, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Date, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Code, 
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Amount,
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Comments, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_By, 
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Deduct_From_Sal,
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Pending_Amount, 
                      dbo.T0120_CLAIM_APPROVAL.Claim_apr_Status,
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Status,
                      dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code as Emp_Code1, dbo.T0080_EMP_MASTER.Work_Email AS Other_Email,dbo.T0080_EMP_MASTER.Alpha_Emp_Code as Emp_Code
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK)
--INNER JOIN dbo.T0110_CLAIM_APPLICATION_DETAIL on dbo.T0100_CLAIM_APPLICATION.Claim_App_ID=dbo.T0100_CLAIM_APPLICATION.Claim_App_ID
					  inner join
                      dbo.T0120_CLAIM_APPROVAL WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Claim_App_ID = dbo.T0120_CLAIM_APPROVAL.Claim_App_ID INNER JOIN
                      dbo.T0040_CLAIM_MASTER WITH (NOLOCK) ON dbo.T0120_CLAIM_APPROVAL.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID INNER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0120_CLAIM_APPROVAL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
                      


