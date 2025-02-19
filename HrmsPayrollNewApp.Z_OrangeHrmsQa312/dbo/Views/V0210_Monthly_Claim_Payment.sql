




CREATE VIEW [dbo].[V0210_Monthly_Claim_Payment]
AS
SELECT		CA.Emp_ID, CA.Claim_ID,CA.Claim_app_ID, CA.Claim_Apr_Code,CA.Claim_Apr_Deduct_From_Sal, CA.Claim_Apr_Pending_Amount, 
			MCP.Claim_Pay_ID, MCP.Claim_Apr_ID,MCP.Cmp_ID, MCP.Sal_Tran_ID,MCP.Claim_Pay_Code, MCP.Claim_Pay_Amount, 
			MCP.Claim_Pay_Comments, MCP.Claim_Payment_Date,MCP.Claim_Payment_Type, MCP.Bank_Name, EMP.Emp_First_Name, EMP.Mobile_No, 
			EMP.Other_Email, EMP.Emp_Full_Name, EMP.Emp_Left,MCP.Claim_Cheque_No, EMP.Emp_code,INC.Branch_ID --CM.Claim_Name,
FROM        --T0040_CLAIM_MASTER AS CM 
--INNER JOIN	
T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) --ON CM.Cmp_ID = CA.Cmp_ID 
INNER JOIN  T0080_EMP_MASTER AS EMP WITH (NOLOCK)  ON CA.Emp_ID = EMP.Emp_ID 
INNER JOIN  T0095_INCREMENT AS INC WITH (NOLOCK)  ON EMP.Increment_ID = INC.Increment_ID 
INNER JOIN	T0210_MONTHLY_CLAIM_PAYMENT AS MCP WITH (NOLOCK)  ON CA.Claim_Apr_ID = MCP.Claim_Apr_ID


