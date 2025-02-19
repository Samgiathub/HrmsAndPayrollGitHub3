





CREATE VIEW [dbo].[V0001_Login_Details]
AS
SELECT     dbo.T0001_LOGIN_TYPE.Login_Type, dbo.T0015_LOGIN_RIGHTS.Login_Rights_ID, dbo.T0015_LOGIN_RIGHTS.Login_Type_ID, 
                      dbo.T0015_LOGIN_RIGHTS.Cmp_ID, dbo.T0015_LOGIN_RIGHTS.Is_Save, dbo.T0015_LOGIN_RIGHTS.Is_Edit, dbo.T0015_LOGIN_RIGHTS.Is_Delete, 
                      dbo.T0015_LOGIN_RIGHTS.Is_Report, dbo.T0011_LOGIN.Login_Name, dbo.T0011_LOGIN.Login_Password, dbo.T0015_LOGIN_RIGHTS.Login_ID
FROM         dbo.T0011_LOGIN WITH (NOLOCK) INNER JOIN
                      dbo.T0015_LOGIN_RIGHTS WITH (NOLOCK)  ON dbo.T0011_LOGIN.Login_ID = dbo.T0015_LOGIN_RIGHTS.Login_ID INNER JOIN
                      dbo.T0001_LOGIN_TYPE WITH (NOLOCK)  ON dbo.T0015_LOGIN_RIGHTS.Login_Type_ID = dbo.T0001_LOGIN_TYPE.Login_Type_ID




