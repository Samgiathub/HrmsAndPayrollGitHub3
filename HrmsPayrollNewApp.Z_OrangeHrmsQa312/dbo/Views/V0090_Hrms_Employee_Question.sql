





CREATE VIEW [dbo].[V0090_Hrms_Employee_Question]
AS
SELECT     dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION.Question, dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION.Que_Description, 
                      dbo.T0090_Hrms_Employee_Introspection.Emp_Inspection_Id, dbo.T0090_Hrms_Employee_Introspection.Inspection_Status, 
                      dbo.T0090_Hrms_Employee_Introspection.Que_Rate, dbo.T0090_Hrms_Employee_Introspection.Answer, 
                      dbo.T0090_Hrms_Employee_Introspection.For_Date, dbo.T0090_Hrms_Employee_Introspection.Emp_Status, 
                      dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION.Appr_id, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Emp_Id, 
                      dbo.T0090_Hrms_Employee_Introspection.Que_Id, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Appr_Detail_Id, 
                      dbo.T0090_Hrms_Employee_Introspection.Cmp_ID, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Appr_Int_Id
FROM         dbo.T0090_Hrms_Employee_Introspection WITH (NOLOCK) INNER JOIN
                      dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WITH (NOLOCK) ON 
                      dbo.T0090_Hrms_Employee_Introspection.Que_Id = dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION.Que_id INNER JOIN
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK) ON 
                      dbo.T0090_Hrms_Employee_Introspection.Appr_Detail_Id = dbo.T0090_Hrms_Appraisal_Initiation_Detail.Appr_Detail_Id




