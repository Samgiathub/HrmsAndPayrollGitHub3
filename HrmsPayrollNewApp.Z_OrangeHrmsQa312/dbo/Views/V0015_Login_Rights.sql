





CREATE VIEW [dbo].[V0015_Login_Rights]
AS
SELECT     dbo.T0015_LOGIN_RIGHTS.Login_Rights_ID, dbo.T0015_LOGIN_RIGHTS.Login_Type_ID, dbo.T0015_LOGIN_RIGHTS.Cmp_ID, 
                      dbo.T0015_LOGIN_RIGHTS.Login_ID, dbo.T0015_LOGIN_RIGHTS.Is_Save, dbo.T0015_LOGIN_RIGHTS.Is_Edit, dbo.T0015_LOGIN_RIGHTS.Is_Delete, 
                      dbo.T0015_LOGIN_RIGHTS.Is_Report, dbo.T0001_LOGIN_TYPE.Login_Type, dbo.T0015_LOGIN_RIGHTS.Branch_ID, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0011_LOGIN.Login_Name, dbo.T0011_LOGIN.Login_Password, dbo.T0011_LOGIN.Emp_ID, 
                      dbo.T0011_LOGIN.Is_Default
FROM         dbo.T0015_LOGIN_RIGHTS WITH (NOLOCK) INNER JOIN
                      dbo.T0001_LOGIN_TYPE WITH (NOLOCK)  ON dbo.T0015_LOGIN_RIGHTS.Login_Type_ID = dbo.T0001_LOGIN_TYPE.Login_Type_ID INNER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0015_LOGIN_RIGHTS.Login_ID = dbo.T0011_LOGIN.Login_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0015_LOGIN_RIGHTS.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




