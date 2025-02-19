





CREATE VIEW [dbo].[V0090_Emp_Skill_Setting]
AS
SELECT     dbo.T0090_HRMS_EMP_SKILL_SETTING.Skill_R_ID, dbo.T0055_HRMS_EMP_SKILL_DETAILS.For_Date, 
                      dbo.T0090_HRMS_EMP_SKILL_SETTING.Emp_Skill_ID, dbo.T0090_HRMS_EMP_SKILL_SETTING.Emp_ID, 
                      dbo.T0090_HRMS_EMP_SKILL_SETTING.Skill_ID, dbo.T0090_HRMS_EMP_SKILL_SETTING.Skilll_Rate_Given, 
                      dbo.T0040_SKILL_MASTER.Skill_Name, dbo.T0055_HRMS_EMP_SKILL_DETAILS.Cmp_ID, 
                      dbo.T0055_HRMS_Skill_Rate_Detail.Skill_Actual_Rate
FROM         dbo.T0090_HRMS_EMP_SKILL_SETTING WITH (NOLOCK) INNER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_EMP_SKILL_SETTING.Skill_ID = dbo.T0040_SKILL_MASTER.Skill_ID INNER JOIN
                      dbo.T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK)  ON dbo.T0040_SKILL_MASTER.Skill_ID = dbo.T0055_HRMS_Skill_Rate_Detail.Skill_ID LEFT OUTER JOIN
                      dbo.T0055_HRMS_EMP_SKILL_DETAILS WITH (NOLOCK)  ON dbo.T0090_HRMS_EMP_SKILL_SETTING.Skill_R_ID = dbo.T0055_HRMS_EMP_SKILL_DETAILS.Skill_R_ID




