





CREATE VIEW [dbo].[V0050_HRMS_Appraisal_Setting]
AS
SELECT     dbo.T0050_HRMS_APPRAISAL_SETTING.Appr_id, dbo.T0050_HRMS_APPRAISAL_SETTING.Cmp_id, 
                      dbo.T0050_HRMS_APPRAISAL_SETTING.Actual_Ctc, dbo.T0050_HRMS_APPRAISAL_SETTING.Experience, 
                      dbo.T0050_HRMS_APPRAISAL_SETTING.Min_Appraisal, dbo.T0050_HRMS_APPRAISAL_SETTING.Max_Appraisal, 
                      dbo.T0050_HRMS_APPRAISAL_SETTING.For_Date, dbo.T0050_HRMS_APPRAISAL_SETTING.Appraisal_Duration, 
                      dbo.T0030_BRANCH_MASTER.Branch_ID, ISNULL(dbo.T0030_BRANCH_MASTER.Branch_Name, 'Not Defined') AS Branch_Name, 
                      dbo.T0040_GRADE_MASTER.Grd_ID, ISNULL(dbo.T0040_GRADE_MASTER.Grd_Name, 'No Defined') AS Grd_name, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_ID, ISNULL(dbo.T0040_DESIGNATION_MASTER.Desig_Name, 'Not Defined') AS Desig_Name, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Id, ISNULL(dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 'Not Defined') AS Dept_Name
FROM         dbo.T0050_HRMS_APPRAISAL_SETTING WITH (NOLOCK) INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_APPRAISAL_SETTING.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_APPRAISAL_SETTING.Grade_id = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON 
                      dbo.T0050_HRMS_APPRAISAL_SETTING.Desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_APPRAISAL_SETTING.Dept_id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id




