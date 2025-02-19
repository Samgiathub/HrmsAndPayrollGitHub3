





CREATE VIEW [dbo].[V0090_HRMS_RATING_DETAILS]
AS
SELECT     dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID, dbo.T0055_Interview_Process_Detail.Cmp_ID, 
                      dbo.T0055_Interview_Process_Detail.Rec_Post_ID, dbo.T0055_Interview_Process_Detail.Process_ID, 
                      dbo.T0055_Interview_Process_Detail.S_Emp_ID, dbo.T0055_Interview_Process_Detail.Dis_No, 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name, dbo.T0055_HRMS_Interview_Schedule.Interview_Schedule_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id AS Expr3, dbo.T0055_HRMS_Interview_Schedule.Resume_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.Rating, dbo.T0055_HRMS_Interview_Schedule.Schedule_Date, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Time, dbo.T0055_HRMS_Interview_Schedule.Process_Dis_No, 
                      dbo.T0055_Resume_Master.Emp_First_Name, dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Other_Email, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, 
                      dbo.T0055_Resume_Master.Initial + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name,
                       '') + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, dbo.T0040_HRMS_General_Setting.Actual_Rate, 
                      dbo.T0055_Resume_Master.Basic_Salary, dbo.T0055_Resume_Master.Date_Of_Join, dbo.T0050_HRMS_Recruitment_Request.Job_Title, 
                      ISNULL(dbo.T0055_HRMS_Interview_Schedule.Comments, '') AS Comments
FROM         dbo.T0040_HRMS_General_Setting WITH (NOLOCK) INNER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) ON 
                      dbo.T0040_HRMS_General_Setting.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID INNER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  ON 
                      dbo.T0040_HRMS_General_Setting.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id INNER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK) ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID INNER JOIN
                      dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK)  INNER JOIN
                      dbo.T0055_Interview_Process_Detail WITH (NOLOCK) ON 
                      dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id = dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID ON 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID AND 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_HRMS_Interview_Schedule.Rec_Post_Id AND 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Interview_Process_Detail.Rec_Post_ID INNER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK) ON dbo.T0055_HRMS_Interview_Schedule.Resume_Id = dbo.T0055_Resume_Master.Resume_Id




