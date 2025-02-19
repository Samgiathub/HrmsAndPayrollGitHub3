





CREATE VIEW [dbo].[V0220_PF_Challan_Sett]
AS
SELECT     dbo.T0220_PF_Challan_Sett.Pf_Challan_ID, dbo.T0220_PF_Challan_Sett.Cmp_ID, dbo.T0220_PF_Challan_Sett.Branch_ID, dbo.T0220_PF_Challan_Sett.Bank_ID, 
                      dbo.T0220_PF_Challan_Sett.Month, dbo.T0220_PF_Challan_Sett.Year, dbo.T0220_PF_Challan_Sett.Payment_Date, dbo.T0220_PF_Challan_Sett.E_Code, 
                      dbo.T0220_PF_Challan_Sett.Acc_Gr_No, dbo.T0220_PF_Challan_Sett.Payment_Mode, dbo.T0220_PF_Challan_Sett.Cheque_No, 
                      dbo.T0220_PF_Challan_Sett.Total_SubScriber, dbo.T0220_PF_Challan_Sett.Total_Wages_Due, dbo.T0220_PF_Challan_Sett.Total_Challan_Amount, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name
FROM         dbo.T0220_PF_Challan_Sett WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0220_PF_Challan_Sett.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




