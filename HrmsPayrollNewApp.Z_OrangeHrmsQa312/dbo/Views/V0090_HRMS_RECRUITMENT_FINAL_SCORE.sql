





CREATE VIEW [dbo].[V0090_HRMS_RECRUITMENT_FINAL_SCORE]
AS
SELECT     dbo.T0055_Resume_Master.Initial, dbo.T0055_Resume_Master.Emp_First_Name, dbo.T0055_Resume_Master.Emp_Last_Name, 
                      dbo.T0055_Resume_Master.Initial + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name,
                       '') + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, dbo.T0055_Resume_Master.Gender, 
                      dbo.T0055_Resume_Master.Present_Street, dbo.T0055_Resume_Master.Present_City, dbo.T0055_Resume_Master.Present_State, 
                      dbo.T0055_Resume_Master.Present_Post_Box, dbo.T0055_Resume_Master.Permanent_Street, dbo.T0055_Resume_Master.Permanent_City, 
                      dbo.T0055_Resume_Master.Permanent_State, dbo.T0055_Resume_Master.Permanentt_Post_Box, dbo.T0055_Resume_Master.Mobile_No, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Present_Loc, dbo.T0055_Resume_Master.Marital_Status, 
                      dbo.T0055_Resume_Master.Home_Tel_no, dbo.T0055_Resume_Master.Other_Email, dbo.T0055_Resume_Master.Date_Of_Birth, 
                      dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Permanent_Loc_ID, 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Trans_ID, dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Resume_ID, 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Cmp_ID, dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Rec_Job_Code, 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Process_ID, dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Rec_Post_ID, 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Actual_Rate, dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Given_Rate, 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Notes, dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Status AS Status1, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID, dbo.T0050_HRMS_Recruitment_Request.Job_Title,dbo.T0055_Resume_Master.DAte_OF_Join ,
                      dbo.T0090_App_Master.Status AS R_Status
FROM         dbo.T0090_App_Master WITH (NOLOCK) INNER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0090_App_Master.Resume_Id = dbo.T0055_Resume_Master.Resume_Id RIGHT OUTER JOIN
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE WITH (NOLOCK) INNER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) ON 
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id INNER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK) ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID ON 
                      dbo.T0055_Resume_Master.Resume_Id = dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE.Resume_ID




