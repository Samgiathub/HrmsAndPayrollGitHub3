﻿





CREATE VIEW [dbo].[V0090_HRMS_TRAININIG_STATUS]
AS
SELECT     dbo.T0100_TRAINING_APPLICATION.Training_App_ID, dbo.T0110_TRAINING_APPLICATION_DETAIL.Emp_ID AS Expr1, 
                      dbo.T0110_TRAINING_APPLICATION_DETAIL.Tran_App_Detail_ID, dbo.T0120_TRAINING_APPROVAL.Login_ID, 
                      dbo.T0120_TRAINING_APPROVAL.Training_Date, dbo.T0120_TRAINING_APPROVAL.Place, dbo.T0120_TRAINING_APPROVAL.Faculty, 
                      dbo.T0120_TRAINING_APPROVAL.Company_Name, dbo.T0120_TRAINING_APPROVAL.Description, dbo.T0120_TRAINING_APPROVAL.Training_Cost, 
                      dbo.T0120_TRAINING_APPROVAL.Apr_Status, dbo.T0120_TRAINING_APPROVAL.Training_End_Date, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Training_Apr_Detail_ID, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Training_Apr_ID, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_ID, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Cmp_ID, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_S_ID, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Feedback, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Superior_Feedback, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Feedback_Date, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Sup_feedback_date, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Eval_Rate, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Sup_Eval_Rate, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Is_Attend
FROM         dbo.T0100_TRAINING_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0110_TRAINING_APPLICATION_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0100_TRAINING_APPLICATION.Training_App_ID = dbo.T0110_TRAINING_APPLICATION_DETAIL.Training_App_ID INNER JOIN
                      dbo.T0120_TRAINING_APPROVAL WITH (NOLOCK)  ON 
                      dbo.T0100_TRAINING_APPLICATION.Training_App_ID = dbo.T0120_TRAINING_APPROVAL.Training_App_ID INNER JOIN
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS  WITH (NOLOCK) ON 
                      dbo.T0120_TRAINING_APPROVAL.Training_Apr_ID = dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Training_Apr_ID




