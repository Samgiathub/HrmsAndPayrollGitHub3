





CREATE VIEW [dbo].[V0090_SUPERIOR_CLAIM_APPROVAL]
AS
SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name, 
                      dbo.T0100_CLAIM_APPLICATION.Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Other_Email, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Superior, 
                      dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_CLAIM_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID INNER JOIN
                      dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID




