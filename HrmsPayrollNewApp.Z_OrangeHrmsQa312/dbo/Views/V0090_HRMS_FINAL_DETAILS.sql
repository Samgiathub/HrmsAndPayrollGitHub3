





CREATE VIEW [dbo].[V0090_HRMS_FINAL_DETAILS]
AS
SELECT     dbo.T0055_HRMS_Interview_Schedule.Interview_Schedule_Id, dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.Rec_Post_Id, dbo.T0055_HRMS_Interview_Schedule.Cmp_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id, dbo.T0055_HRMS_Interview_Schedule.Resume_Id, dbo.T0055_HRMS_Interview_Schedule.Rating, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Date, dbo.T0055_HRMS_Interview_Schedule.Schedule_Time, 
                      dbo.T0055_HRMS_Interview_Schedule.Process_Dis_No, dbo.T0055_HRMS_Interview_Schedule.Status, dbo.T0055_Resume_Master.Emp_First_Name,
                       dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0052_HRMS_Posted_Recruitment.Job_title, 
                      dbo.T0040_HRMS_General_Setting.Actual_Rate, dbo.T0055_Interview_Process_Detail.Process_ID, 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name
FROM         dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  INNER JOIN
                      dbo.T0055_Interview_Process_Detail WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Interview_Process_Detail.Rec_Post_ID ON
                       dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_General_Setting WITH (NOLOCK)  ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0040_HRMS_General_Setting.Rec_Post_ID RIGHT OUTER JOIN
                      dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0055_HRMS_Interview_Schedule.Resume_Id = dbo.T0055_Resume_Master.Resume_Id ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_HRMS_Interview_Schedule.Rec_Post_Id




