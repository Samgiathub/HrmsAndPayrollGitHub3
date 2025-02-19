





CREATE VIEW [dbo].[V0220_ESIC_Challan_Sett]
AS
SELECT     dbo.T0220_ESIC_CHALLAN_SETT.ESIC_Challan_ID, dbo.T0220_ESIC_CHALLAN_SETT.Cmp_ID, dbo.T0220_ESIC_CHALLAN_SETT.Branch_ID, 
                      dbo.T0220_ESIC_CHALLAN_SETT.Bank_ID, dbo.T0220_ESIC_CHALLAN_SETT.Month, dbo.T0220_ESIC_CHALLAN_SETT.Year, dbo.T0220_ESIC_CHALLAN_SETT.Payment_Date, 
                      dbo.T0220_ESIC_CHALLAN_SETT.E_Code, dbo.T0220_ESIC_CHALLAN_SETT.Acc_Gr_No, dbo.T0220_ESIC_CHALLAN_SETT.Payment_Mode, 
                      dbo.T0220_ESIC_CHALLAN_SETT.Cheque_No, dbo.T0220_ESIC_CHALLAN_SETT.Total_SubScriber, dbo.T0220_ESIC_CHALLAN_SETT.Total_Wages_Due, 
                      dbo.T0220_ESIC_CHALLAN_SETT.Emp_Cont_Per, dbo.T0220_ESIC_CHALLAN_SETT.Employer_Cont_Per, dbo.T0220_ESIC_CHALLAN_SETT.Emp_Cont_Amount, 
                      dbo.T0220_ESIC_CHALLAN_SETT.Employer_Cont_Amount, dbo.T0220_ESIC_CHALLAN_SETT.Total_Amount, dbo.T0030_BRANCH_MASTER.Branch_Name
FROM         dbo.T0220_ESIC_CHALLAN_SETT WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0220_ESIC_CHALLAN_SETT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




