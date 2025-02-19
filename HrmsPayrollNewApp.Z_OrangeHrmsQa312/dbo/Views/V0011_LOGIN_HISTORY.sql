





CREATE VIEW [dbo].[V0011_LOGIN_HISTORY]
AS
SELECT     dbo.T0011_Login_History.Row_ID, dbo.T0011_Login_History.Cmp_ID, dbo.T0011_Login_History.Login_ID, dbo.T0011_Login_History.Login_Date, 
                      dbo.T0011_Login_History.Ip_Address, dbo.T0011_LOGIN.Login_Name, dbo.T0010_COMPANY_MASTER.Cmp_Name
FROM         dbo.T0011_Login_History WITH (NOLOCK) INNER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0011_Login_History.Login_ID = dbo.T0011_LOGIN.Login_ID INNER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0011_Login_History.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id AND 
                      dbo.T0011_LOGIN.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id




