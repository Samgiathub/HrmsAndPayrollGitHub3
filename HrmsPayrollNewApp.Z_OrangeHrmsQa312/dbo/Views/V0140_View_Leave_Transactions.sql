





CREATE VIEW [dbo].[V0140_View_Leave_Transactions]
AS
SELECT     SUM(l.Leave_Used) AS total_Used_Leave, ld.Leave_Days, l.Leave_ID, e.Emp_ID, e.Grd_ID, e.Cmp_ID, ld.Leave_Days - ISNULL(SUM(l.Leave_Used), 
                      0) AS balance, lm.Leave_Name, lm.Leave_Code, dbo.T0095_LEAVE_OPENING.Leave_Op_Days
FROM         dbo.T0140_LEAVE_TRANSACTION AS l WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID INNER JOIN
                      dbo.T0050_LEAVE_DETAIL AS ld WITH (NOLOCK)  ON e.Grd_ID = ld.Grd_ID AND e.Cmp_ID = ld.Cmp_ID AND l.Cmp_ID = ld.Cmp_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  ON ld.Leave_ID = lm.Leave_ID AND l.Leave_ID = lm.Leave_ID AND l.Cmp_ID = lm.Cmp_ID INNER JOIN
                      dbo.T0095_LEAVE_OPENING  WITH (NOLOCK) ON e.Emp_ID = dbo.T0095_LEAVE_OPENING.Emp_Id AND 
                      lm.Leave_ID = dbo.T0095_LEAVE_OPENING.Leave_ID INNER JOIN
                      dbo.T0095_LEAVE_OPENING AS T0095_LEAVE_OPENING_1 WITH (NOLOCK)  ON e.Emp_ID = T0095_LEAVE_OPENING_1.Emp_Id AND 
                      lm.Leave_ID = T0095_LEAVE_OPENING_1.Leave_ID
GROUP BY l.Leave_ID, e.Emp_ID, e.Cmp_ID, e.Grd_ID, ld.Leave_Days, lm.Leave_Name, lm.Leave_Code, dbo.T0095_LEAVE_OPENING.Leave_Op_Days




