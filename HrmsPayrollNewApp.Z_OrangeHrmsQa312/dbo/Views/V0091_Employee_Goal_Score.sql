





CREATE VIEW [dbo].[V0091_Employee_Goal_Score]
AS
SELECT     dbo.T0040_HRMS_Goal_Master.Goal_Title, dbo.T0091_Employee_Goal_Score.Emp_Goal_S_id, dbo.T0091_Employee_Goal_Score.appr_detail_id, 
                      dbo.T0091_Employee_Goal_Score.For_date, dbo.T0091_Employee_Goal_Score.Emp_Goal_ID, dbo.T0091_Employee_Goal_Score.Goal_rate, 
                      dbo.T0091_Employee_Goal_Score.comments, dbo.T0091_Employee_Goal_Score.Goal_status, dbo.T0091_Employee_Goal_Score.Emp_status, 
                      dbo.T0090_EMP_GOAL_DETAILS.Goal_Status AS Gl_status, dbo.T0040_HRMS_Goal_Master.Description, dbo.T0090_EMP_GOAL_DETAILS.Emp_ID, 
                      dbo.T0090_EMP_GOAL_DETAILS.Cmp_ID, dbo.T0090_EMP_GOAL_DETAILS.Start_Date, dbo.T0090_EMP_GOAL_DETAILS.End_Date
FROM         dbo.T0040_HRMS_Goal_Master WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0090_EMP_GOAL_DETAILS WITH (NOLOCK)  ON dbo.T0040_HRMS_Goal_Master.Goal_id = dbo.T0090_EMP_GOAL_DETAILS.Goal_ID RIGHT OUTER JOIN
                      dbo.T0091_Employee_Goal_Score WITH (NOLOCK)  ON dbo.T0090_EMP_GOAL_DETAILS.Emp_Goal_ID = dbo.T0091_Employee_Goal_Score.Emp_Goal_ID




