


CREATE VIEW [dbo].[V0052_HRMS_Recruitement_Posted]
AS
SELECT     dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID, dbo.T0050_HRMS_Recruitment_Request.Job_Title, 
                      dbo.T0050_HRMS_Recruitment_Request.Cmp_id, dbo.T0050_HRMS_Recruitment_Request.S_Emp_ID, 
                      dbo.T0050_HRMS_Recruitment_Request.Login_ID, dbo.T0050_HRMS_Recruitment_Request.Posted_date, 
                      dbo.T0050_HRMS_Recruitment_Request.Grade_Id, dbo.T0050_HRMS_Recruitment_Request.Desi_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Branch_id, dbo.T0050_HRMS_Recruitment_Request.Type_ID, 
                      dbo.T0050_HRMS_Recruitment_Request.Dept_Id, dbo.T0050_HRMS_Recruitment_Request.Skill_detail, 
                      dbo.T0050_HRMS_Recruitment_Request.Job_Description, dbo.T0050_HRMS_Recruitment_Request.No_of_vacancies, 
                      dbo.T0050_HRMS_Recruitment_Request.App_status, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_date, dbo.T0052_HRMS_Posted_Recruitment.Rec_Start_date, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, dbo.T0052_HRMS_Posted_Recruitment.Qual_Detail, 
                      dbo.T0052_HRMS_Posted_Recruitment.Experience_year, dbo.T0052_HRMS_Posted_Recruitment.Location, 
                      dbo.T0052_HRMS_Posted_Recruitment.Experience, dbo.T0052_HRMS_Posted_Recruitment.Email_id, 
                      dbo.T0052_HRMS_Posted_Recruitment.Posted_status, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_TYPE_MASTER.Type_Name, dbo.T0010_COMPANY_MASTER.Domain_Name,
                      CASE WHEN Location IS NOT NULL and Location <>'' THEN
                          ISNULL((SELECT     upper(isnull(Branch_Name,'')) + ' 》 ' + upper(isnull(branch_city,'')) + ','
                            FROM          v0030_branch_master d WITH (NOLOCK)
                            WHERE      d .Branch_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0052_HRMS_Posted_Recruitment.Location, ''), '#')
                                                         WHERE      data <> '') FOR XML path('')),'#') ELSE '#' END as Location_Preference 
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK) ON dbo.T0052_HRMS_Posted_Recruitment.Cmp_id = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER WITH (NOLOCK) ON dbo.T0050_HRMS_Recruitment_Request.Type_ID = dbo.T0040_TYPE_MASTER.Type_ID ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID ON 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0050_HRMS_Recruitment_Request.S_Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON 
                      dbo.T0050_HRMS_Recruitment_Request.Dept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id and dbo.T0052_HRMS_Posted_Recruitment.Cmp_id=dbo.T0050_HRMS_Recruitment_Request.Cmp_id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0050_HRMS_Recruitment_Request.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0050_HRMS_Recruitment_Request.Desi_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID




