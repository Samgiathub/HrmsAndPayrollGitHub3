


CREATE VIEW [dbo].[V_Email_Detail]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name AS Email_From_Username, dbo.Tbl_Email_Details.EmailId, dbo.Tbl_Email_Details.Cmp_Id, 
                      dbo.Tbl_Email_Details.Email_From_UserId, dbo.Tbl_Email_Details.Email_To_UserId, dbo.Tbl_Email_Details.Email_Subject, 
                      dbo.Tbl_Email_Details.Email_Messages, dbo.Tbl_Email_Details.Email_Datetime, dbo.Tbl_Email_Details.Email_Type, 
                      dbo.Tbl_Email_Details.Email_From_Status, dbo.Tbl_Email_Details.Email_To_Status, dbo.Tbl_Email_Details.Email_Read_Status, 
                      dbo.Tbl_Email_Details.Email_Css, T0080_EMP_MASTER_1.Emp_Full_Name AS Email_To_Username
FROM         dbo.Tbl_Email_Details WITH (NOLOCK)
			LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK) ON 
                      dbo.Tbl_Email_Details.Email_To_UserId = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.Tbl_Email_Details.Email_From_UserId = dbo.T0080_EMP_MASTER.Emp_ID

