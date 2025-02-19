





CREATE VIEW [dbo].[V0040_LEAVE_MASTER]
AS
SELECT     dbo.T0100_LEAVE_APPLICATION.Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name AS Employee_Name, 
                      dbo.T0100_LEAVE_APPLICATION.Application_Code, dbo.T0100_LEAVE_APPLICATION.Application_Date, 
                      dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID, dbo.T0100_LEAVE_APPLICATION.Application_Status, 
                      dbo.T0100_LEAVE_APPLICATION.Cmp_ID, dbo.T0100_LEAVE_APPLICATION.S_Emp_ID
FROM         dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_LEAVE_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      dbo.T0100_LEAVE_APPLICATION.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID




