





CREATE VIEW [dbo].[V0055_HRMS_Interview_Schedule_Process]
AS
SELECT     dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID AS Expr1, dbo.T0055_Interview_Process_Detail.Process_ID, 
                      dbo.T0055_Interview_Process_Detail.S_Emp_ID, dbo.T0055_Interview_Process_Detail.Dis_No, dbo.T0055_Interview_Process_Detail.Cmp_ID, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0055_Interview_Process_Detail.Rec_Post_ID, 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name, dbo.T0055_HRMS_Interview_Schedule.Interview_Schedule_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id, dbo.T0055_HRMS_Interview_Schedule.Rating, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Date, dbo.T0055_HRMS_Interview_Schedule.Schedule_Time, 
                      dbo.T0055_HRMS_Interview_Schedule.Process_Dis_No, dbo.T0055_HRMS_Interview_Schedule.Status, 
                      dbo.T0055_HRMS_Interview_Schedule.Resume_Id, ISNULL(dbo.T0055_HRMS_Interview_Schedule.Comments, '') AS Comments
FROM         dbo.T0055_Interview_Process_Detail WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0055_Interview_Process_Detail.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)  ON 
                      dbo.T0055_Interview_Process_Detail.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID RIGHT OUTER JOIN
                      dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK)  ON 
                      dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID = dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id




