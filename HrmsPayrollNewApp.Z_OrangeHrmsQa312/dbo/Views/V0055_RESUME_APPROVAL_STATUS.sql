





CREATE VIEW [dbo].[V0055_RESUME_APPROVAL_STATUS]
AS
SELECT     dbo.T0055_RESUME_APPROVAL_STATUS.*, dbo.T0055_Resume_Master.Resume_Posted_date, dbo.T0055_Resume_Master.Rec_Post_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Branch_id
FROM         dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Resume_Master.Rec_Post_Id RIGHT OUTER JOIN
                      dbo.T0055_RESUME_APPROVAL_STATUS WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Resume_Id = dbo.T0055_RESUME_APPROVAL_STATUS.Resume_ID




