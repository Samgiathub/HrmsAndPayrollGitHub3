





CREATE VIEW [dbo].[V0010_Employee_Leave_Application]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_First_Name + dbo.T0080_EMP_MASTER.Emp_Second_Name + dbo.T0080_EMP_MASTER.Emp_Last_Name AS Employee_Name,
                       dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID, dbo.T0110_LEAVE_APPLICATION_DETAIL.Row_ID, 
                      dbo.T0110_LEAVE_APPLICATION_DETAIL.From_Date, dbo.T0110_LEAVE_APPLICATION_DETAIL.To_Date, 
                      dbo.T0110_LEAVE_APPLICATION_DETAIL.Leave_Period, dbo.T0100_LEAVE_APPLICATION.Application_Status
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_LEAVE_APPLICATION.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_LEAVE_APPLICATION.S_Emp_ID INNER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID = dbo.T0110_LEAVE_APPLICATION_DETAIL.Leave_Application_ID




