



CREATE VIEW [dbo].[V0065_Emp_Skill_Detail_Get]
AS
SELECT     dbo.T0065_EMP_SKILL_DETAIL_APP.Row_ID, dbo.T0065_EMP_SKILL_DETAIL_APP.Emp_Tran_ID, dbo.T0065_EMP_SKILL_DETAIL_APP.Emp_Application_ID, 
                      dbo.T0065_EMP_SKILL_DETAIL_APP.Approved_Emp_ID, dbo.T0065_EMP_SKILL_DETAIL_APP.Approved_Date, dbo.T0065_EMP_SKILL_DETAIL_APP.Rpt_Level, 
                      dbo.T0065_EMP_SKILL_DETAIL_APP.Cmp_ID, dbo.T0065_EMP_SKILL_DETAIL_APP.Skill_ID, dbo.T0065_EMP_SKILL_DETAIL_APP.Skill_Comments, 
                      dbo.T0065_EMP_SKILL_DETAIL_APP.Skill_Experience, dbo.T0040_SKILL_MASTER.Skill_Name, dbo.T0060_EMP_MASTER_APP.Alpha_Emp_Code, 
                      CAST(dbo.T0060_EMP_MASTER_APP.Date_Of_Join AS varchar(11)) AS Date_Of_Join, dbo.T0060_EMP_MASTER_APP.Emp_Full_Name, dbo.T0060_EMP_MASTER_APP.Branch_ID, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name
FROM         dbo.T0065_EMP_SKILL_DETAIL_APP WITH (NOLOCK) INNER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  ON dbo.T0065_EMP_SKILL_DETAIL_APP.Skill_ID = dbo.T0040_SKILL_MASTER.Skill_ID INNER JOIN
                      dbo.T0060_EMP_MASTER_APP WITH (NOLOCK)  ON dbo.T0065_EMP_SKILL_DETAIL_APP.Emp_Tran_ID = dbo.T0060_EMP_MASTER_APP.Emp_Tran_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0060_EMP_MASTER_APP.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID


