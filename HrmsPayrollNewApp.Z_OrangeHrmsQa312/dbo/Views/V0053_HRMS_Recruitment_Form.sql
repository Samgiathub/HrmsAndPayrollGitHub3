





CREATE VIEW [dbo].[V0053_HRMS_Recruitment_Form]
AS
SELECT     dbo.T0053_HRMS_Recruitment_Form.*, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, 
                      dbo.T0052_HRMS_Posted_Recruitment.Job_title
FROM         dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0053_HRMS_Recruitment_Form WITH (NOLOCK) ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0053_HRMS_Recruitment_Form.Rec_Post_Id




