





CREATE VIEW [dbo].[V0100_AD_Grade_Branch_Wise]
AS
SELECT  GB.Tran_ID, GB.Cmp_ID, GB.AD_ID, GB.Effective_Date, GB.Grd_ID, GB.Branch_ID, GB.AD_Amount, 
		GB.SysDatetime, GB.UserID, BM.Branch_Name, GM.Grd_Name,AD.AD_NAme,Isnull(GB.AD_CALCULATE_ON,'0') as AD_CALCULATE_ON
FROM         dbo.T0100_AD_Grade_Branch_Wise AS GB WITH (NOLOCK) INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON GB.Branch_ID = BM.Branch_ID 
                      INNER JOIN dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK)  ON GB.Grd_ID = GM.Grd_ID
                      INNER JOIN dbo.T0050_AD_Master AD WITH (NOLOCK)  ON GB.AD_ID = AD.AD_ID




