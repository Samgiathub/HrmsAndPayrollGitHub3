


CREATE VIEW [dbo].[V0250_Password_Format_Setting]
AS
SELECT     dbo.T0040_Password_Format.Format, dbo.T0040_Password_Format.Name, dbo.T0250_Password_Format_Setting.Format_ID, 
                      dbo.T0250_Password_Format_Setting.Cmp_ID, dbo.T0250_Password_Format_Setting.Pwd_ID, 
                      dbo.T0250_Password_Format_Setting.Name AS Page_Name
FROM         dbo.T0040_Password_Format WITH (NOLOCK) INNER JOIN
                      dbo.T0250_Password_Format_Setting WITH (NOLOCK)  ON dbo.T0040_Password_Format.Pwd_Frmt_ID = dbo.T0250_Password_Format_Setting.Format_ID


