


CREATE VIEW [dbo].[V0090_EMP_HR_DOC_Detail_Candidate]
AS
SELECT     dbo.T0090_EMP_HR_DOC_Detail.accetpeted, dbo.T0090_EMP_HR_DOC_Detail.accepted_date, dbo.T0090_EMP_HR_DOC_Detail.Emp_doc_ID, 
                      dbo.T0090_EMP_HR_DOC_Detail.HR_DOC_ID, dbo.T0090_EMP_HR_DOC_Detail.Emp_id, dbo.T0090_EMP_HR_DOC_Detail.Doc_content, 
                      dbo.T0040_HR_DOC_MASTER.Doc_Title, dbo.T0090_EMP_HR_DOC_Detail.cmp_id, 
                      CASE WHEN accetpeted = 0 THEN 'Pending' WHEN accetpeted = 1 THEN 'Accepted' ELSE 'Rejected' END AS accepeted_status, 
                      dbo.T0090_EMP_HR_DOC_Detail.Login_id, T0010_COMPANY_MASTER_1.Domain_Name, CASE WHEN isnull(login_name, '') 
                      = '' THEN 'Auto Generated' ELSE replace(login_name, T0010_COMPANY_MASTER_1.domain_name, '') END AS login_name, 
                      dbo.T0010_COMPANY_MASTER.Image_name, dbo.T0010_COMPANY_MASTER.Cmp_Name, ISNULL(dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      'All') AS Dept_Name, ISNULL(dbo.T0040_DESIGNATION_MASTER.Desig_Name, 'All') AS Desig_Name, 
                      ISNULL(dbo.T0030_BRANCH_MASTER.Branch_Name, 'All') AS Branch_Name, ISNULL(dbo.T0040_GRADE_MASTER.Grd_Name, 'All') AS Grd_Name, 
                      dbo.T0060_RESUME_FINAL.Grd_ID, dbo.T0060_RESUME_FINAL.Dept_ID, dbo.T0060_RESUME_FINAL.Desig_Id, dbo.T0060_RESUME_FINAL.Branch_ID, 
                      dbo.T0055_Resume_Master.Resume_Code as  Emp_code, dbo.T0055_Resume_Master.Emp_First_Name, dbo.T0055_Resume_Master.Gender, 
                      cast(dbo.T0055_Resume_Master.Emp_First_Name as varchar(max)) + ' ' + cast(isnull(T0055_Resume_Master.Emp_Second_Name,'') as varchar(max)) +' '+ cast(isnull(T0055_Resume_Master.Emp_Last_Name,'') as varchar(max))  as  Emp_Full_Name, 
                      ISNULL(CAST(isnull(dbo.T0055_Resume_Master.Resume_Code,'') AS varchar(50)) 
                      + ' - ' + cast(isnull(dbo.T0055_Resume_Master.Emp_First_Name,'') as varchar(max)) + '' + cast(isnull(T0055_Resume_Master.Emp_Second_Name,'') as varchar(max)) +''+ cast(isnull(T0055_Resume_Master.Emp_Last_Name,'') as varchar(max)), 'All') AS emp_full_name_new
                      ,isnull(T0090_EMP_HR_DOC_Detail.type,0) as type
FROM         dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_1 WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON T0010_COMPANY_MASTER_1.Cmp_Id = dbo.T0011_LOGIN.Cmp_ID RIGHT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0090_EMP_HR_DOC_Detail WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0060_RESUME_FINAL WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.resume_id = dbo.T0055_Resume_Master.resume_id ON 
                      dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0060_RESUME_FINAL.Grd_ID ON 
                      dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0060_RESUME_FINAL.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id ON 
                      dbo.T0090_EMP_HR_DOC_Detail.Emp_id = dbo.T0055_Resume_Master.Resume_id ON 
                      dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0090_EMP_HR_DOC_Detail.cmp_id LEFT OUTER JOIN
                      dbo.T0040_HR_DOC_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_HR_DOC_Detail.HR_DOC_ID = dbo.T0040_HR_DOC_MASTER.HR_DOC_ID ON 
                      dbo.T0011_LOGIN.Login_ID = dbo.T0090_EMP_HR_DOC_Detail.Login_id

					where T0090_EMP_HR_DOC_Detail.type = 1




