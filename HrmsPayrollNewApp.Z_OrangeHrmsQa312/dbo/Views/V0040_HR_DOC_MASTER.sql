





CREATE VIEW [dbo].[V0040_HR_DOC_MASTER]
AS
SELECT     dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_HR_DOC_MASTER.Display_Joinining, dbo.T0040_HR_DOC_MASTER.Doc_content, 
                      dbo.T0040_HR_DOC_MASTER.Desig_id, dbo.T0040_HR_DOC_MASTER.Dept_id, dbo.T0040_HR_DOC_MASTER.Grd_id, 
                      dbo.T0040_HR_DOC_MASTER.Branch_id, dbo.T0040_HR_DOC_MASTER.Cmp_id, dbo.T0040_HR_DOC_MASTER.Doc_Title, 
                      dbo.T0040_HR_DOC_MASTER.HR_DOC_ID, CASE WHEN Display_Joinining = 0 THEN 'No' ELSE 'Yes' END AS Display_Joinining_name, 
                      dbo.T0040_HR_DOC_MASTER.gender, CASE WHEN gender = 'F' THEN 'Female' WHEN gender = 'M' THEN 'Male' ELSE 'Any' END AS gender_name
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0040_HR_DOC_MASTER WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0040_HR_DOC_MASTER.Grd_id LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0040_HR_DOC_MASTER.Dept_id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0040_HR_DOC_MASTER.Desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0040_HR_DOC_MASTER.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID




