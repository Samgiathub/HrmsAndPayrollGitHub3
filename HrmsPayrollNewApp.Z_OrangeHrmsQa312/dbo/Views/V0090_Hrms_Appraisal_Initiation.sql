





CREATE VIEW [dbo].[V0090_Hrms_Appraisal_Initiation]
AS
SELECT     dbo.T0011_LOGIN.Login_Name, dbo.T0090_Hrms_Appraisal_Initiation.*
FROM         dbo.T0090_Hrms_Appraisal_Initiation WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0090_Hrms_Appraisal_Initiation.Login_Id = dbo.T0011_LOGIN.Login_ID




