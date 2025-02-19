





CREATE VIEW [dbo].[V0120_leave_Approval_Detail_Get]
AS
SELECT     dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID, dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID, dbo.T0120_LEAVE_APPROVAL.Cmp_ID, 
                      dbo.T0120_LEAVE_APPROVAL.Emp_ID, dbo.T0120_LEAVE_APPROVAL.S_Emp_ID, dbo.T0120_LEAVE_APPROVAL.Approval_Date, 
                      dbo.T0120_LEAVE_APPROVAL.Approval_Status, dbo.T0120_LEAVE_APPROVAL.Approval_Comments, dbo.T0120_LEAVE_APPROVAL.Login_ID, 
                      dbo.T0120_LEAVE_APPROVAL.System_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_ID, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Assign_As, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Reason, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0130_LEAVE_APPROVAL_DETAIL.Row_ID
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0120_LEAVE_APPROVAL.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0120_LEAVE_APPROVAL.S_Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0120_LEAVE_APPROVAL.S_Emp_ID LEFT OUTER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  INNER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  ON dbo.T0040_LEAVE_MASTER.Leave_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_ID ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID




