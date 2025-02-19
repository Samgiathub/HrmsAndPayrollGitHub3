




CREATE VIEW [dbo].[V0130_Training_employee_detail_chart]
AS
SELECT     dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Tran_emp_Detail_ID, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_App_ID, 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_Apr_ID, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_tran_status, 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.cmp_id, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_ID, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Date, 
                      dbo.T0040_Hrms_Training_master.Training_name, CASE WHEN dbo.T0040_Hrms_Training_master.Training_Type = 0 THEN 'Internal' ELSE 'External' END AS Type, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_Name, dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      CAST(dbo.T0080_EMP_MASTER.Emp_code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS emp_full_name_NEW, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_End_Date, CASE WHEN isnull(is_attend, 
                      0) = 0 THEN 'No' ELSE 'Yes' END AS is_attend_name, dbo.T0140_HRMS_TRAINING_Feedback_New.Tran_Feedback_ID, 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Reason, dbo.T0140_HRMS_TRAINING_Feedback_New.Emp_Score, 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Sup_Score, dbo.T0140_HRMS_TRAINING_Feedback_New.Sup_Comments, 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Sup_Suggestion, dbo.T0140_HRMS_TRAINING_Feedback_New.Status, 
                      dbo.T0140_HRMS_TRAINING_Feedback_New.Is_Attend AS is_attend
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id RIGHT OUTER JOIN
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)  INNER JOIN
                      dbo.T0140_HRMS_TRAINING_Feedback_New WITH (NOLOCK)  ON 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Tran_emp_Detail_ID = dbo.T0140_HRMS_TRAINING_Feedback_New.Tran_Emp_Detail_Id LEFT OUTER
                       JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID ON 
                      dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  ON dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id = dbo.T0040_Hrms_Training_master.Training_id ON 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_Apr_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID LEFT OUTER JOIN
                      dbo.T0050_HRMS_Training_Provider_master WITH (NOLOCK)  ON 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID = dbo.T0050_HRMS_Training_Provider_master.Training_Pro_ID




