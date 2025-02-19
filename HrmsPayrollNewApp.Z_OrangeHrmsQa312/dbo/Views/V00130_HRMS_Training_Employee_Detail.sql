





CREATE VIEW [dbo].[V00130_HRMS_Training_Employee_Detail]
AS
SELECT     dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Date, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_End_Date, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Type, dbo.T0120_HRMS_TRAINING_APPROVAL.Cmp_ID, 
                      CASE WHEN (dbo.T0140_HRMS_TRAINING_Feedback_New.is_attend = 1) THEN 'Yes' ELSE 'No' END AS Attend, 
                      dbo.T0040_Hrms_Training_master.Training_name, dbo.T0140_HRMS_TRAINING_Feedback_New.Emp_s_Id, 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Status
FROM         dbo.T0140_HRMS_TRAINING_Feedback_New WITH (NOLOCK) INNER JOIN
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Tran_Emp_Detail_Id = dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Tran_emp_Detail_ID RIGHT OUTER
                       JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  ON dbo.T0040_Hrms_Training_master.Training_id = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id ON
                       dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_Apr_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID




