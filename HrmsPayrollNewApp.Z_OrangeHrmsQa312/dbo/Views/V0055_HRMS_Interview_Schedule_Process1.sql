





CREATE VIEW [dbo].[V0055_HRMS_Interview_Schedule_Process1]
AS
SELECT     dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID, dbo.T0055_Interview_Process_Detail.Cmp_ID, 
                      dbo.T0055_Interview_Process_Detail.Rec_Post_ID, dbo.T0055_Interview_Process_Detail.Process_ID, 
                       dbo.T0055_Interview_Process_Detail.S_Emp_ID, dbo.T0055_Interview_Process_Detail.Dis_No, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Date, dbo.T0055_HRMS_Interview_Schedule.Rating, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Time, dbo.T0055_HRMS_Interview_Schedule.Status, 
                      dbo.T0055_HRMS_Interview_Schedule.Process_Dis_No, dbo.T0055_HRMS_Interview_Schedule.Resume_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.Interview_Schedule_Id
FROM         dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK) INNER JOIN
                      dbo.T0055_Interview_Process_Detail WITH (NOLOCK)  ON 
                      dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id = dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID




