





CREATE VIEW [dbo].[V0100_EMP_LTA_Medical_Detail]
AS
SELECT     dbo.T0100_EMP_LTA_Medical_Detail.LM_ID, dbo.T0100_EMP_LTA_Medical_Detail.Cmp_ID, dbo.T0100_EMP_LTA_Medical_Detail.Emp_ID, 
                      dbo.T0100_EMP_LTA_Medical_Detail.From_Date, dbo.T0100_EMP_LTA_Medical_Detail.To_Date, 
                      CASE WHEN Mode = '%' THEN '%' WHEN mode = 'R' THEN 'Rs.' ELSE 'Fix' END AS Mode, dbo.T0100_EMP_LTA_Medical_Detail.Amount, 
                      dbo.T0100_EMP_LTA_Medical_Detail.Type_id, dbo.T0100_EMP_LTA_Medical_Detail.Carry_fw_amount, 
                      dbo.T0100_EMP_LTA_Medical_Detail.no_IT_claims, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      CASE WHEN T0100_EMP_LTA_Medical_Detail.type_id = 1 THEN 'LTA' WHEN T0100_EMP_LTA_Medical_Detail.Type_id = 2 THEN 'Medical' END AS Type_Name,
                       dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0095_INCREMENT.Branch_ID
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0100_EMP_LTA_Medical_Detail WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_EMP_LTA_Medical_Detail.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID ON 
                      dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




