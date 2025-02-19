




CREATE VIEW [dbo].[V0150_LEAVE_CANCELLATION_BACKUP_MEHUL_28_NOV_2022]
AS
SELECT     dbo.T0150_LEAVE_CANCELLATION.Tran_id, dbo.T0150_LEAVE_CANCELLATION.Cmp_Id, dbo.T0150_LEAVE_CANCELLATION.Emp_Id, 
                      dbo.T0150_LEAVE_CANCELLATION.Leave_Approval_id, dbo.T0150_LEAVE_CANCELLATION.Leave_id, dbo.T0150_LEAVE_CANCELLATION.For_date, 
                      dbo.T0150_LEAVE_CANCELLATION.Leave_period, dbo.T0150_LEAVE_CANCELLATION.Is_Approve, dbo.T0150_LEAVE_CANCELLATION.Comment, 
                      dbo.T0150_LEAVE_CANCELLATION.Request_Date, dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0150_LEAVE_CANCELLATION.MComment, dbo.T0150_LEAVE_CANCELLATION.Day_type, 
                      dbo.T0150_LEAVE_CANCELLATION.Actual_Leave_Day, dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0040_LEAVE_MASTER.Leave_Code, 
                      dbo.T0040_LEAVE_MASTER.Apply_Hourly
                      ,B.Vertical_ID,B.SubVertical_ID,B.Dept_ID  --Added By Jaina 1-10-2015
FROM         dbo.T0150_LEAVE_CANCELLATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER  WITH (NOLOCK) ON dbo.T0150_LEAVE_CANCELLATION.Leave_id = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0150_LEAVE_CANCELLATION.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID
                      INNER JOIN   --Added By Jaina 1-10-2015 Start
                      (
						SELECT I.Cmp_ID,I.Emp_ID,I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID
					    FROM T0095_INCREMENT As I WITH (NOLOCK) 
					    WHERE Increment_ID = (
												SELECT TOP 1 I1.Increment_ID 
												FROM T0095_INCREMENT I1 WITH (NOLOCK) 
												WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID 
												ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
											  )
                      )As B ON B.Emp_ID=dbo.T0080_EMP_MASTER.Emp_ID AND B.Cmp_ID=dbo.T0080_EMP_MASTER.Cmp_ID  --Added By Jaina 1-10-2015 End


