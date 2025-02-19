


CREATE VIEW [dbo].[V0220_PF_Challan]
AS
SELECT     dbo.T0220_PF_CHALLAN.Pf_Challan_ID, dbo.T0220_PF_CHALLAN.Cmp_ID, dbo.T0220_PF_CHALLAN.Branch_ID, dbo.T0220_PF_CHALLAN.Bank_ID, 
                      dbo.T0220_PF_CHALLAN.Month, dbo.T0220_PF_CHALLAN.Year, dbo.T0220_PF_CHALLAN.Payment_Date, dbo.T0220_PF_CHALLAN.E_Code, 
                      dbo.T0220_PF_CHALLAN.Acc_Gr_No, dbo.T0220_PF_CHALLAN.Payment_Mode, dbo.T0220_PF_CHALLAN.Cheque_No, 
                      dbo.T0220_PF_CHALLAN.Total_SubScriber, dbo.T0220_PF_CHALLAN.Total_Wages_Due, dbo.T0220_PF_CHALLAN.Total_Challan_Amount, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name
					,IsNull(dbo.T0220_PF_CHALLAN.Branch_ID_Multi, Cast(dbo.T0220_PF_CHALLAN.Branch_ID As Varchar(MAX))) As Branch_ID_Multi,  --Change By Jaina 17-09-2015
					   (
							SELECT STUFF((SELECT ',' + BRANCH_NAME FROM T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN 
							(SELECT CAST(DATA AS NUMERIC) AS BRANCH_ID FROM DBO.Split(IsNull(Branch_ID_Multi, Cast(dbo.T0220_PF_CHALLAN.Branch_ID As Varchar(Max))), '#')) MB ON B.Branch_ID= MB.BRANCH_ID  --Change By Jaina 17-09-2015
							WHERE B.Cmp_ID=dbo.T0220_PF_CHALLAN.Cmp_ID FOR XML PATH('')),1,1,'') 
						) 
						AS Branch_Name_Multi
FROM         dbo.T0220_PF_CHALLAN WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0220_PF_CHALLAN.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID


