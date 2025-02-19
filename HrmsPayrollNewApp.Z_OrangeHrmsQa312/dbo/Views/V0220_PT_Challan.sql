



CREATE VIEW [dbo].[V0220_PT_Challan]
AS
SELECT     dbo.T0220_PT_CHALLAN.Challan_Id, dbo.T0220_PT_CHALLAN.Cmp_ID, dbo.T0220_PT_CHALLAN.Month, dbo.T0220_PT_CHALLAN.Year, 
                      dbo.T0220_PT_CHALLAN.Payment_Date, dbo.T0220_PT_CHALLAN.Bank_ID, dbo.T0220_PT_CHALLAN.Bank_Name, dbo.T0220_PT_CHALLAN.Tax_Amount, 
                      dbo.T0220_PT_CHALLAN.Tax_Return_Amount, dbo.T0220_PT_CHALLAN.Interest_Amount, dbo.T0220_PT_CHALLAN.Penalty_Amount, 
                      dbo.T0220_PT_CHALLAN.Other_Amount, dbo.T0220_PT_CHALLAN.Total_Amount,
					  dbo.T0030_BRANCH_MASTER.Branch_Name
					  ,IsNull(dbo.T0220_PT_CHALLAN.Branch_ID_Multi, Cast(dbo.T0220_PT_CHALLAN.Branch_ID As Varchar(MAX))) As Branch_ID_Multi,
					   (
							SELECT STUFF((SELECT ',' + BRANCH_NAME FROM T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN 
							(SELECT CAST(DATA AS NUMERIC) AS BRANCH_ID FROM DBO.Split(IsNull(Branch_ID_Multi, Cast(dbo.T0220_PT_CHALLAN.Branch_ID As Varchar(Max))), '#')) MB ON B.Branch_ID= MB.BRANCH_ID
							WHERE B.Cmp_ID=dbo.T0220_PT_CHALLAN.Cmp_ID FOR XML PATH('')),1,1,'') 
						) 
						AS Branch_Name_Multi
FROM         dbo.T0220_PT_CHALLAN WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0220_PT_CHALLAN.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




