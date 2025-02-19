



CREATE VIEW [dbo].[V0055_RESUME_VIEW]
AS
SELECT     ISNULL(dbo.T0052_HRMS_Posted_Recruitment.Job_title, '') AS Job_Title, dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id, 
                      isnull(dbo.T0055_Resume_Master.Initial,'') + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name,
                       '') + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, ISNULL(dbo.T0055_Resume_Master.Total_Exp, 0) AS Total_Experience, 
                      dbo.T0055_Resume_Master.Resume_Id, dbo.T0055_Resume_Master.Cmp_id, dbo.T0055_Resume_Master.Rec_Post_Id, 
                      dbo.T0055_Resume_Master.Resume_Posted_date, dbo.T0055_Resume_Master.Initial, dbo.T0055_Resume_Master.Emp_First_Name, 
                      dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, ISNULL(dbo.T0055_Resume_Master.Date_Of_Birth, 
                      '') AS Date_Of_Birth, dbo.T0055_Resume_Master.Marital_Status, dbo.T0055_Resume_Master.Gender, dbo.T0055_Resume_Master.Present_Street, 
                      dbo.T0055_Resume_Master.Present_City, dbo.T0055_Resume_Master.Present_State, dbo.T0055_Resume_Master.Present_Post_Box, 
                      dbo.T0055_Resume_Master.Permanent_Street, dbo.T0055_Resume_Master.Permanent_City, dbo.T0055_Resume_Master.Permanent_State, 
                      dbo.T0055_Resume_Master.Permanentt_Post_Box, dbo.T0055_Resume_Master.Home_Tel_no, ISNULL(dbo.T0055_Resume_Master.Mobile_No, 0) 
                      AS Mobile_No, dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Other_Email, dbo.T0055_Resume_Master.Cur_CTC, 
                      dbo.T0055_Resume_Master.Exp_CTC, dbo.T0055_Resume_Master.Resume_Name, dbo.T0055_Resume_Master.File_Name, 
                      dbo.T0055_Resume_Master.Resume_Status, dbo.T0055_Resume_Master.Final_CTC, dbo.T0055_Resume_Master.Date_Of_Join, 
                      dbo.T0055_Resume_Master.Basic_Salary, dbo.T0055_Resume_Master.Emp_Full_PF, dbo.T0055_Resume_Master.Emp_Fix_Salary, 
                      dbo.T0055_Resume_Master.Present_Loc, dbo.T0055_Resume_Master.Permanent_Loc_ID, ISNULL(dbo.T0001_LOCATION_MASTER.Loc_name, '') 
                      AS loc_name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Cat_ID, dbo.T0080_EMP_MASTER.Grd_ID, 
                      dbo.T0080_EMP_MASTER.Dept_ID, dbo.T0080_EMP_MASTER.Desig_Id, dbo.T0080_EMP_MASTER.Type_ID, dbo.T0080_EMP_MASTER.Shift_ID, 
                      dbo.T0080_EMP_MASTER.Bank_ID, dbo.T0055_Resume_Master.Non_Technical_Skill, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, 
                      dbo.T0055_Resume_Master.Resume_Code, dbo.T0055_Resume_Master.System_Date, dbo.T0050_HRMS_Recruitment_Request.Branch_id
FROM         dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id = dbo.T0080_EMP_MASTER.Emp_ID RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master  WITH (NOLOCK) ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Resume_Master.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Permanent_Loc_ID = dbo.T0001_LOCATION_MASTER.Loc_ID




