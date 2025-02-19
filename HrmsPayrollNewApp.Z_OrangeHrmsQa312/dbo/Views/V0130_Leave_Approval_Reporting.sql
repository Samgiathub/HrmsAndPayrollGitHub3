





CREATE VIEW [dbo].[V0130_Leave_Approval_Reporting]
AS
SELECT     dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Assign_As, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Reason, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS Leave_Approver, dbo.T0010_COMPANY_MASTER.Cmp_Name, 
                      dbo.T0010_COMPANY_MASTER.Cmp_Address, dbo.T0010_COMPANY_MASTER.Cmp_Phone, dbo.T0120_LEAVE_APPROVAL.Cmp_ID, 
                      dbo.T0120_LEAVE_APPROVAL.Emp_ID, dbo.T0100_LEAVE_APPLICATION.Application_Code, dbo.T0080_EMP_MASTER.Emp_Left
FROM         dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK) INNER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID AND 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Cmp_ID = dbo.T0040_LEAVE_MASTER.Cmp_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      dbo.T0120_LEAVE_APPROVAL.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.S_Emp_ID = T0080_EMP_MASTER_1.Emp_ID AND 
                      dbo.T0120_LEAVE_APPROVAL.Cmp_ID = T0080_EMP_MASTER_1.Cmp_ID INNER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id INNER JOIN
                      dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK)  ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID = dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID AND 
                      dbo.T0120_LEAVE_APPROVAL.Cmp_ID = dbo.T0100_LEAVE_APPLICATION.Cmp_ID




