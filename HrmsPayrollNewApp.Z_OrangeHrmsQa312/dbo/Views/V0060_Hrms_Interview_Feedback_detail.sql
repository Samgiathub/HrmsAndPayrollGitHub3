





CREATE VIEW [dbo].[V0060_Hrms_Interview_Feedback_detail]
AS
SELECT     dbo.T0045_HRMS_R_PROCESS_TEMPLATE.QUE_Detail, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.IS_Title, 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Is_Description, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Is_Raiting, 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.is_dynamic, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Dis_No, 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Process_ID, dbo.T0060_Hrms_Interview_Feedback_detail.*, dbo.T0011_LOGIN.Login_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, CASE WHEN isnull(t0011_login.emp_id, 0) 
                      = 0 THEN t0011_login.login_name ELSE t0080_emp_master.emp_full_name END AS Approve_by
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0011_LOGIN.Emp_ID RIGHT OUTER JOIN
                      dbo.T0060_Hrms_Interview_Feedback_detail WITH (NOLOCK)  ON 
                      dbo.T0011_LOGIN.Login_ID = dbo.T0060_Hrms_Interview_Feedback_detail.Login_id LEFT OUTER JOIN
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK)  ON 
                      dbo.T0060_Hrms_Interview_Feedback_detail.Process_Q_ID = dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Process_Q_ID




