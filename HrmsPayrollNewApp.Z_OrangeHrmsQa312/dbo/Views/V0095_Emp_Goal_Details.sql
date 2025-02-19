





CREATE VIEW [dbo].[V0095_Emp_Goal_Details]
AS
SELECT     dbo.T0090_EMP_GOAL_DETAILS.*, dbo.T0040_HRMS_Goal_Master.Goal_Title, dbo.T0090_EMP_GOAL_DETAILS.Goal_ID AS Expr1
FROM         dbo.T0090_EMP_GOAL_DETAILS WITH (NOLOCK) INNER JOIN
                      dbo.T0040_HRMS_Goal_Master WITH (NOLOCK)  ON dbo.T0090_EMP_GOAL_DETAILS.Goal_ID = dbo.T0040_HRMS_Goal_Master.Goal_id




