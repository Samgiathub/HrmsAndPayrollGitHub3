





CREATE VIEW [dbo].[V0055_HRMS_Skill_Rate_Detail]
AS
SELECT     dbo.T0055_HRMS_Skill_Rate_Detail.*, dbo.T0040_SKILL_MASTER.Skill_Name
FROM         dbo.T0050_HRMS_Skill_Rate_Setting WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK)  ON 
                      dbo.T0050_HRMS_Skill_Rate_Setting.Skill_d_id = dbo.T0055_HRMS_Skill_Rate_Detail.Skill_d_id LEFT OUTER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  ON dbo.T0055_HRMS_Skill_Rate_Detail.Skill_ID = dbo.T0040_SKILL_MASTER.Skill_ID




