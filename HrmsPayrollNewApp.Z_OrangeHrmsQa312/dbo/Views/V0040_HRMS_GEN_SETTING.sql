





CREATE VIEW [dbo].[V0040_HRMS_GEN_SETTING]
AS
SELECT     dbo.T0052_HRMS_Posted_Recruitment.Job_title, dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name, 
                      dbo.T0040_HRMS_General_Setting.Gen_ID, dbo.T0040_HRMS_General_Setting.Rec_Post_ID, dbo.T0040_HRMS_General_Setting.Rec_Req_ID, 
                      dbo.T0040_HRMS_General_Setting.Process_ID, dbo.T0040_HRMS_General_Setting.For_Date, dbo.T0040_HRMS_General_Setting.Cmp_ID, 
                      dbo.T0040_HRMS_General_Setting.Login_ID, dbo.T0040_HRMS_General_Setting.Actual_Rate, dbo.T0040_HRMS_General_Setting.Min_Rate, 
                      dbo.T0040_HRMS_General_Setting.Max_Rate, dbo.T0040_HRMS_General_Setting.Sys_Date
FROM         dbo.T0040_HRMS_General_Setting WITH (NOLOCK) Left outer JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)  ON 
                      dbo.T0040_HRMS_General_Setting.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID LEFT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  ON dbo.T0040_HRMS_General_Setting.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id




