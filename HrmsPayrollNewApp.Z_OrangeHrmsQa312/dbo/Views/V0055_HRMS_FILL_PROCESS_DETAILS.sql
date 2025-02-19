





CREATE VIEW [dbo].[V0055_HRMS_FILL_PROCESS_DETAILS]
AS
SELECT     dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name,dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID, dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID, 
                      dbo.T0055_Interview_Process_Detail.Cmp_ID, dbo.T0055_Interview_Process_Detail.Rec_Post_ID, 
                      dbo.T0055_Interview_Process_Detail.Process_ID AS Expr1, dbo.T0055_Interview_Process_Detail.S_Emp_ID, 
                      dbo.T0055_Interview_Process_Detail.Dis_No
FROM         dbo.T0055_Interview_Process_Detail WITH (NOLOCK) INNER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) ON 
                      dbo.T0055_Interview_Process_Detail.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID




