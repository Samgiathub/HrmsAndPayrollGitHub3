





CREATE VIEW [dbo].[V0090_Hrms_Emp_Skill_Details]  
AS  
SELECT     COUNT(V.Skilll_Rate_Given) AS Skill_Rate_Count, COUNT(V.Skilll_Rate_Given) * MAX(T.Rate_Value) AS Total_Rate, SUM(V.Skilll_Rate_Given)   
                      AS Skill_Rate_Given, V.Skill_ID, V.Emp_ID, V.Skill_Name, V.Cmp_ID
FROM         dbo.V0090_HRMS_EMP_SKILL_SETTING AS V WITH (NOLOCK) INNER JOIN  
                      dbo.T0030_HRMS_RATING_MASTER AS T WITH (NOLOCK)  ON V.Cmp_ID = T.Cmp_ID  
GROUP BY V.Skill_ID, V.Emp_ID, V.Skill_Name, V.Cmp_ID




