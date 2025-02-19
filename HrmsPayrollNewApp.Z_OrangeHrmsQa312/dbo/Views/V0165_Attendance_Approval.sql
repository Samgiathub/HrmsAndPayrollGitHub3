



CREATE VIEW [dbo].[V0165_Attendance_Approval]
AS
SELECT        AA.Att_Apr_ID, AA.Att_App_ID, AA.Emp_ID, AA.For_Date, AA.P_Days, EM.Alpha_Emp_Code, EM.Emp_Full_Name, AA.Remarks, AA.Shift_Sec, AA.Cmp_ID, AA.Approver_Emp_ID,
			  (Case When AA.Att_Status = 'R' Then 'Rejected' When AA.Att_Status = 'A' Then 'Approved' End) as Status
FROM            dbo.T0165_Attendance_Approval AS AA WITH (NOLOCK) INNER JOIN
                         dbo.T0080_EMP_MASTER AS EM  WITH (NOLOCK) ON AA.Emp_ID = EM.Emp_ID

