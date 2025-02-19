




CREATE VIEW [dbo].[V0350_Exit_Clearance_Allowance_Detail]
AS
SELECT DISTINCT    EC.Item_name, EC.Recovery_Amt,EC.Cmp_id,EC.Emp_ID,A.AD_CALCULATE_ON,A.FOR_FNF,A.AD_FLAG
FROM         dbo.V0350_Exit_Clearance_Approval_Detail AS EC WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0100_EMP_EARN_DEDUCTION AS E WITH (NOLOCK)  ON E.EMP_ID = EC.Emp_ID LEFT OUTER JOIN
                      dbo.T0050_AD_MASTER AS A WITH (NOLOCK)  ON A.AD_ID = E.AD_ID


