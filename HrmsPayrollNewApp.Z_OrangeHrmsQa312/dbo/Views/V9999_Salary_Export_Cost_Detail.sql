





CREATE VIEW [dbo].[V9999_Salary_Export_Cost_Detail]
AS
SELECT     dbo.T0040_Cost_Category.Cost_Category, dbo.T0040_Cost_Center.Cost_Center, dbo.T9999_Salary_Export.Vch_No, 
                      dbo.T9999_Salary_Export.Vch_Type, dbo.T9999_Salary_Export_Cost_Detail.Sal_Exp_ID, dbo.T9999_Salary_Export_Cost_Detail.Sal_Exp_Trn_ID, 
                      dbo.T9999_Salary_Export_Cost_Detail.Cost_Center_ID, dbo.T9999_Salary_Export_Cost_Detail.Amount, dbo.T0040_Cost_Center.Tally_Cat_ID
FROM         dbo.T0040_Cost_Category WITH (NOLOCK) INNER JOIN
                      dbo.T0040_Cost_Center WITH (NOLOCK)  ON dbo.T0040_Cost_Category.Tally_Cat_ID = dbo.T0040_Cost_Center.Tally_Cat_ID INNER JOIN
                      dbo.T9999_Salary_Export_Cost_Detail WITH (NOLOCK)  ON 
                      dbo.T0040_Cost_Center.Tally_Center_ID = dbo.T9999_Salary_Export_Cost_Detail.Cost_Center_ID INNER JOIN
                      dbo.T9999_Salary_Export WITH (NOLOCK)  ON dbo.T9999_Salary_Export_Cost_Detail.Sal_Exp_ID = dbo.T9999_Salary_Export.Sal_Exp_Id




