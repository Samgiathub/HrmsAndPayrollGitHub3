





CREATE VIEW [dbo].[V0040_Cost_Category_Center]
AS
SELECT     dbo.T0040_Cost_Center.Tally_Center_ID, dbo.T0040_Cost_Category.Tally_Cat_ID, dbo.T0040_Cost_Center.Cmp_ID, 
                      dbo.T0040_Cost_Center.Cost_Center, dbo.T0040_Cost_Category.Cost_Category
FROM         dbo.T0040_Cost_Center WITH (NOLOCK) INNER JOIN
                      dbo.T0040_Cost_Category WITH (NOLOCK)  ON dbo.T0040_Cost_Center.Tally_Cat_ID = dbo.T0040_Cost_Category.Tally_Cat_ID




