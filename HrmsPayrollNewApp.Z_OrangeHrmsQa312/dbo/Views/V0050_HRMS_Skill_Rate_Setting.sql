





CREATE VIEW [dbo].[V0050_HRMS_Skill_Rate_Setting]  
AS  
SELECT     dbo.T0050_HRMS_Skill_Rate_Setting.Skill_d_id, dbo.T0050_HRMS_Skill_Rate_Setting.cmp_id, dbo.T0050_HRMS_Skill_Rate_Setting.Dept_Id,   
                      dbo.T0050_HRMS_Skill_Rate_Setting.Branch_Id, dbo.T0050_HRMS_Skill_Rate_Setting.Grd_id, dbo.T0050_HRMS_Skill_Rate_Setting.desig_id,   
                      dbo.T0050_HRMS_Skill_Rate_Setting.avg_Skill_Actual_Rate, dbo.T0050_HRMS_Skill_Rate_Setting.avg_Skill_R_Rate_Min,   
                      dbo.T0050_HRMS_Skill_Rate_Setting.avg_Skill_R_Rate_Max, dbo.T0050_HRMS_Skill_Rate_Setting.skill_Eval_duration,   
                      dbo.T0050_HRMS_Skill_Rate_Setting.fore_date, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name,   
                      dbo.T0030_BRANCH_MASTER.Branch_Code, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name  
FROM       dbo.T0050_HRMS_Skill_Rate_Setting WITH (NOLOCK) LEFT OUTER JOIN  
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON   
                      dbo.T0050_HRMS_Skill_Rate_Setting.desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN  
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Skill_Rate_Setting.Dept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN  
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Skill_Rate_Setting.Branch_Id = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN  
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Skill_Rate_Setting.Grd_id = dbo.T0040_GRADE_MASTER.Grd_ID  




