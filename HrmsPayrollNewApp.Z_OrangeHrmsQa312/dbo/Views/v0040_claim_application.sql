


CREATE VIEW [dbo].[v0040_claim_application]
AS
SELECT     dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_CLAIM_MASTER.Claim_ID, 
                      dbo.T0040_CLAIM_MASTER.Cmp_ID, dbo.T0040_CLAIM_MASTER.Claim_Name, dbo.T0040_CLAIM_MASTER.Claim_Max_Limit
FROM         dbo.T0040_CLAIM_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0040_CLAIM_MASTER.Cmp_ID = dbo.T0030_BRANCH_MASTER.Cmp_ID




