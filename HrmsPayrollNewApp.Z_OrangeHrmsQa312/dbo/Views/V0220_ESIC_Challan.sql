





CREATE VIEW [dbo].[V0220_ESIC_Challan]
AS
SELECT     dbo.T0220_ESIC_CHALLAN.ESIC_Challan_ID, dbo.T0220_ESIC_CHALLAN.Cmp_ID, dbo.T0220_ESIC_CHALLAN.Branch_ID, 
                      dbo.T0220_ESIC_CHALLAN.Bank_ID, dbo.T0220_ESIC_CHALLAN.Month, dbo.T0220_ESIC_CHALLAN.Year, dbo.T0220_ESIC_CHALLAN.Payment_Date, 
                      dbo.T0220_ESIC_CHALLAN.E_Code, dbo.T0220_ESIC_CHALLAN.Acc_Gr_No, dbo.T0220_ESIC_CHALLAN.Payment_Mode, 
                      dbo.T0220_ESIC_CHALLAN.Cheque_No, dbo.T0220_ESIC_CHALLAN.Total_SubScriber, dbo.T0220_ESIC_CHALLAN.Total_Wages_Due, 
                      dbo.T0220_ESIC_CHALLAN.Emp_Cont_Per, dbo.T0220_ESIC_CHALLAN.Employer_Cont_Per, dbo.T0220_ESIC_CHALLAN.Emp_Cont_Amount, 
                      dbo.T0220_ESIC_CHALLAN.Employer_Cont_Amount, dbo.T0220_ESIC_CHALLAN.Total_Amount, dbo.T0030_BRANCH_MASTER.Branch_Name
                      ,dbo.T0220_ESIC_CHALLAN.Branch_ID_Multi,
                       (
							SELECT STUFF((SELECT ',' + BRANCH_NAME FROM T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN 
							(SELECT CAST(DATA AS NUMERIC) AS BRANCH_ID FROM DBO.Split(Branch_ID_Multi, '#')) MB ON B.Branch_ID= MB.BRANCH_ID
							WHERE B.Cmp_ID=dbo.T0220_ESIC_CHALLAN.Cmp_ID FOR XML PATH('')),1,1,'') 
						) 
						AS Branch_Name_Multi
                       
FROM         dbo.T0220_ESIC_CHALLAN WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0220_ESIC_CHALLAN.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




