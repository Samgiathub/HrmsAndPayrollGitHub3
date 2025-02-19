





CREATE VIEW [dbo].[P0160_BranchName_Get]
AS
SELECT     dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0030_BRANCH_MASTER.Branch_Code, dbo.T0011_LOGIN.Login_ID, dbo.T0011_LOGIN.Branch_ID, 
                      dbo.T0011_LOGIN.Login_Name
FROM         dbo.T0030_BRANCH_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0011_LOGIN.Branch_ID




