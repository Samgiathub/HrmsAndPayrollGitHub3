





CREATE VIEW [dbo].[V010_Employee_ Leave]
AS
SELECT     dbo.T0080_EMP_MASTER.Desig_Id, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Second_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Last_Name, dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID, 
                      dbo.T0100_LEAVE_APPLICATION.S_Emp_ID, dbo.T0110_LEAVE_APPLICATION_DETAIL.From_Date, dbo.T0110_LEAVE_APPLICATION_DETAIL.To_Date, 
                      dbo.T0110_LEAVE_APPLICATION_DETAIL.Leave_Period
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_LEAVE_APPLICATION.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_LEAVE_APPLICATION.S_Emp_ID INNER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0100_LEAVE_APPLICATION.Leave_Application_ID = dbo.T0110_LEAVE_APPLICATION_DETAIL.Leave_Application_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0110_LEAVE_APPLICATION_DETAIL.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID




