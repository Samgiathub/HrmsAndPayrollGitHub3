





CREATE VIEW [dbo].[V0090_hrms_Appraisal_Status_Report]
AS
SELECT     dbo.T0090_Hrms_Appraisal_Initiation.Appr_Int_Id, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Appr_Detail_Id, 
                      dbo.T0090_Hrms_Appraisal_Initiation.For_Date, dbo.T0090_Hrms_Appraisal_Initiation.Invoke_Emp, 
                      dbo.T0090_Hrms_Appraisal_Initiation.Invoke_Superior, dbo.T0090_Hrms_Appraisal_Initiation.Invoke_Team, 
                      dbo.T0090_Hrms_Appraisal_Initiation.Cmp_Id, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Emp_Id, 
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail.Is_Accept, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Is_Emp_Submit, 
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail.Is_Sup_submit, dbo.T0090_Hrms_Appraisal_Initiation_Detail.Is_team_submit, 
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail.start_date, dbo.T0090_Hrms_Appraisal_Initiation_Detail.End_date, 
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail.Increment_ID, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0090_HRMS_FINAL_SCORE.Inspection_status, dbo.T0090_HRMS_FINAL_SCORE.Emp_Status
FROM         dbo.T0090_Hrms_Appraisal_Initiation WITH (NOLOCK) INNER JOIN
                      dbo.T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK)  ON 
                      dbo.T0090_Hrms_Appraisal_Initiation.Appr_Int_Id = dbo.T0090_Hrms_Appraisal_Initiation_Detail.Appr_Int_Id INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_Hrms_Appraisal_Initiation_Detail.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0090_HRMS_FINAL_SCORE WITH (NOLOCK)  ON dbo.T0090_Hrms_Appraisal_Initiation_Detail.Emp_Id = dbo.T0090_HRMS_FINAL_SCORE.Emp_ID




