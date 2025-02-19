



CREATE VIEW [dbo].[V0050_Minimum_Wages_Master]
AS
SELECT     MW.Wages_ID, MW.cmp_Id, dbo.T0040_SkillType_Master.Skill_Name,dbo.T0020_STATE_MASTER.State_Name, MW.Wages_Value, REPLACE(CONVERT(varchar(25), 
                      MW.Effective_Date, 103), ' ', '/') AS Effective_Date, MW.State_ID,MW.SkillType_ID, MW.Effective_Date AS Eff_Date
FROM         dbo.T0020_STATE_MASTER WITH (NOLOCK) INNER JOIN					
             dbo.T0050_Minimum_Wages_Master MW WITH (NOLOCK)  ON dbo.T0020_STATE_MASTER.State_ID =MW.State_ID INNER JOIN
			 (SELECT MAX(Effective_Date)Eff_Date,SkillType_ID,State_ID  FROM T0050_Minimum_Wages_Master WITH (NOLOCK)  GROUP BY SkillType_ID,State_ID)MW1 ON MW.Effective_Date=MW1.Eff_Date AND MW.SkillType_ID=MW1.SkillType_ID AND MW.State_ID=MW1.State_ID
			 INNER JOIN  dbo.T0040_SkillType_Master WITH (NOLOCK)  ON MW.SkillType_ID = dbo.T0040_SkillType_Master.SkillType_ID

