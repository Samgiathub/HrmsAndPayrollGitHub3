




CREATE VIEW [dbo].[V0090_HRMS_EMP_SKILL_SETTING]
AS
SELECT     SS.Emp_Skill_ID, SS.Skill_R_ID, SS.Emp_ID, SS.Skill_ID, SS.Skilll_Rate_Given, SD.Cmp_ID, EM.Emp_Full_Name, SM.Skill_Name, SD.For_Date, 
                      SD.S_Emp_ID, EM1.Emp_Full_Name AS Emp_S_Full_Name, SD.Login_ID, SS.Skill_Actual_Rate, EM.Branch_ID, EM.Desig_Id, 
                      SD.Skill_Actual_Rate AS Total_Actual_Rate, SD.Skill_Rate_Given AS Total_Given_Rate, ISNULL(SS.Skill_Rate_Employee, 0) AS Skill_Rate_Employee, 
                      ISNULL(SS.Skill_Rate_Superior, 0) AS Skill_Rate_Superior
FROM         dbo.T0055_HRMS_EMP_SKILL_DETAILS AS SD WITH (NOLOCK) INNER JOIN
                      dbo.T0090_HRMS_EMP_SKILL_SETTING AS SS WITH (NOLOCK)  ON SD.Skill_R_ID = SS.Skill_R_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON SS.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0040_SKILL_MASTER AS SM WITH (NOLOCK)  ON SS.Skill_ID = SM.Skill_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS EM1 WITH (NOLOCK)  ON SD.S_Emp_ID = EM1.Emp_ID



