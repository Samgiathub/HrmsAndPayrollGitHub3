






CREATE VIEW [dbo].[V0100_Leave_CF_Detail]
AS
SELECT     dbo.T0100_LEAVE_CF_DETAIL.LEAVE_CF_ID, dbo.T0100_LEAVE_CF_DETAIL.Cmp_ID, dbo.T0100_LEAVE_CF_DETAIL.Emp_ID, 
                      dbo.T0100_LEAVE_CF_DETAIL.Leave_ID, dbo.T0100_LEAVE_CF_DETAIL.CF_For_Date, dbo.T0100_LEAVE_CF_DETAIL.CF_From_Date, 
                      dbo.T0100_LEAVE_CF_DETAIL.CF_To_Date, dbo.T0100_LEAVE_CF_DETAIL.CF_P_Days, dbo.T0100_LEAVE_CF_DETAIL.CF_Leave_Days, 
                      dbo.T0100_LEAVE_CF_DETAIL.CF_Type, dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name,T0080_EMP_MASTER.Alpha_Emp_Code,
                      dbo.T0080_EMP_MASTER.Branch_ID,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID,dbo.T0080_EMP_MASTER.Dept_ID,  --Added By Jaina 13-08-2016
                      dbo.T0040_LEAVE_MASTER.Leave_Type, dbo.T0100_LEAVE_CF_DETAIL.Advance_Leave_Balance
FROM         dbo.T0100_LEAVE_CF_DETAIL WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER  WITH (NOLOCK) ON dbo.T0100_LEAVE_CF_DETAIL.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0100_LEAVE_CF_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID




