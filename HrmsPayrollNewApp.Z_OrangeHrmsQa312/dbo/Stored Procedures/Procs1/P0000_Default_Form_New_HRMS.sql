
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Default_Form_New_HRMS]  
  @ver_update as tinyint = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Begin

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/b_home.gif' where Form_Name='HRMS Home'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name = 'Recruitment Panel'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Process_Master.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Recruitment Process Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Recruitment_Posted.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Recruitment Application'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Posted_Detail.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Recruitment Posted Detail'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Resume_Import_Data.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Resume Import'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Resume_Bank.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Posted Resume Collection'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Candidate_details.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Candidates Detail'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Master.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Provider_Master.aspx' , Form_Image_url = 'menu/fix.gif' where Form_name='Training Provider'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_View_Training_Approval.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training Plan'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Calander.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training Calendar'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Approval.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training Approval'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_View_Training_Feedback.aspx' , Form_Image_url = 'menu/fix.gif' where Form_name= 'Training Feedback'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Emp_feedback_detail.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training History'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Training_Questionnaire.aspx' , Form_Image_url = 'menu/fix.gif' where Form_Name='Training Questionnaire'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Appraisal'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Master_Rating.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Rating Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Master_Goal.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Goal Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Appraisal_General_Setting.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Appraisal General Setting'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Skill_General_Setting.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_name='Skill General Setting'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Assign_Goal.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Assign Goal'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Employee_Skill_Rating.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Employee Skill Rating'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Initiate_Appraisal.aspx?ID=1' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Initiate Appraisal'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Appraisal_Effection_Payroll.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Appraisal Approval'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Initiated_Appraisal_Report.aspx' , Form_Image_url = 'menu/company_structure.gif' where Form_Name='Initiate Appraisal Report'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Performance Appraisal'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_Master_Rating.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Performance Rating Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_Master_GoalType.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='GoalType Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_Master_SOL.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Competency Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_Master_SignoffSetting.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_name='Setting Master'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_ReviewGoal.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Review Employee Goal'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_ReviewPerformanceSummary.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Review Performance Summary'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/NewAppraisal_ReviewSOL.aspx' , Form_Image_url = 'menu/job_master.gif' where Form_Name='Review Competency'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/leave_management.gif' where Form_Name='HR Documents'
Update T0000_DEFAULT_FORM set Form_url = 'admin_associates/Master_hr_Document.aspx' , Form_Image_url = 'menu/leave_management.gif' where Form_Name='HR Document Master'
Update T0000_DEFAULT_FORM set Form_url = 'admin_associates/employee_hr_document.aspx' , Form_Image_url = 'menu/leave_management.gif' where Form_Name='Export Employee Document'
Update T0000_DEFAULT_FORM set Form_url = 'admin_associates/view_emp_doc_history.aspx' , Form_Image_url = 'menu/leave_management.gif' where Form_Name='Employee Document History'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HR_Home.aspx' , Form_Image_url = 'menu/desig.png' where Form_Name='Organogram'
Update T0000_DEFAULT_FORM set Form_url = 'admin_associates/desig_chart.aspx' , Form_Image_url = 'menu/desig.png' where Form_Name='Organization Organogram'
Update T0000_DEFAULT_FORM set Form_url = 'admin_associates/Org_chart.aspx' , Form_Image_url = 'menu/desig.png' where Form_Name='Employee Organogram'

Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Recruitment_Posted_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Recruitment Application BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Posted_Detail_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Recruitment Posted Detail BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/Resume_Import_Data_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Resume Import BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Candidate_Finalization_details.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Joining Status Updation'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Resume_Bank_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Posted Resume Collection BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Candidate_details_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Candidates Detail BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/FinalizedResumes_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Finalize Candidate BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/CandidateOffer_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Candidate For Offer BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_Candidate_Finalization_details_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Joining Status Updation BMA'
Update T0000_DEFAULT_FORM set Form_url = 'HRMS/HRMS_NewJoineesList_BMA.aspx' , Form_Image_url = 'menu/Recruitement.png' where Form_Name='Candidates OnBoard BMA'

end
