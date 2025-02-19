





CREATE VIEW [dbo].[V0040_LM_SETTING]
AS
SELECT     dbo.T0040_LM_SETTING.Row_ID, dbo.T0040_LM_SETTING.Cmp_ID, dbo.T0040_LM_SETTING.Branch_id, dbo.T0040_LM_SETTING.for_Date, 
                      dbo.T0040_LM_SETTING.start_date, dbo.T0040_LM_SETTING.end_date, dbo.T0040_LM_SETTING.Max_limit, dbo.T0040_LM_SETTING.Type_ID, 
                      dbo.T0040_LM_SETTING.Effective_month, dbo.T0040_LM_SETTING.Effect_on_CTC, dbo.T0040_LM_SETTING.Cal_amount_Type, 
                      dbo.T0040_LM_SETTING.Show_Yearly, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      CASE WHEN Type_ID = 1 THEN 'LTA' WHEN Type_ID = 2 THEN 'Medical' END AS Type_Name, 
                      CASE WHEN Cal_amount_Type = 1 THEN 'Basic Salary' WHEN Cal_amount_Type = 2 THEN 'Gross Salary' END AS Cal_amount_Type_name, 
                      CASE WHEN Effect_on_CTC = 1 THEN 'Yes' ELSE 'No' END AS Effect_on_CTC_Name
FROM         dbo.T0040_LM_SETTING WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0040_LM_SETTING.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID




