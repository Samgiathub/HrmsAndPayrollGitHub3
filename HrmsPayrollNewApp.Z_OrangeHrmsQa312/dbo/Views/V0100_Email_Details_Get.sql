





CREATE VIEW [dbo].[V0100_Email_Details_Get]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name AS Email_From_Username, ed.EmailId, ed.Cmp_Id, 
                      ed.Email_From_UserId, ed.Email_To_UserId, ed.Email_Subject, 
                      ed.Email_Messages, ed.Email_Datetime, ed.Email_Type, 
                      ed.Email_From_Status, ed.Email_To_Status, ed.Email_Read_Status, 
                      ed.Email_Css, T0080_EMP_MASTER_1.Emp_Full_Name AS Email_To_Username
FROM         dbo.T0100_Email_Details ed WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1  WITH (NOLOCK) ON 
                      ed.Email_To_UserId = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON ed.Email_From_UserId = dbo.T0080_EMP_MASTER.Emp_ID




