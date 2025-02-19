




CREATE VIEW [dbo].[V0150_LEAVE_CANCELLATION_APPROVAL_MAIN_BACKUP_MEHUL_29122022]
AS
SELECT  Distinct   LC.Cmp_Id, LC.Emp_Id, LC.Leave_Approval_id, LC.Leave_id,
					  --LC.For_date, 
					  Convert(varchar(12),LC.Request_Date,103) as For_Date,
					  LC.Is_Approve, ISNULL(LC.MComment, '') AS MComment,
                      --LC.Actual_Leave_Day, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, ISNULL(CAST(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID AS varchar(10)), 
                      '') AS Leave_Application_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS S_Emp_Full_Name, dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period,
					  dbo.T0080_EMP_MASTER.Branch_ID, 
                      LC.A_Emp_Id, 
                      --LC.Tran_id, 
                       LC.Leave_Approval_id as Tran_id,
                      dbo.T0040_LEAVE_MASTER.Apply_Hourly,
                      dbo.T0040_LEAVE_MASTER.Default_Short_Name   --Added By Jaina 25-11-2015
                      ,dbo.T0080_EMP_MASTER.Dept_ID --Ankit
                      ,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID --added by jimit 02122016
                      ,Convert(varchar(11),LC.Request_Date,120) AS L_For_Date 
					  ,S_Emp_ID
FROM         dbo.T0150_LEAVE_CANCELLATION AS LC WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON LC.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK)  ON LC.Leave_Approval_id = dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON LC.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_Superior = T0080_EMP_MASTER_1.Emp_ID
GROUP BY LC.Cmp_Id, LC.Emp_Id, LC.Leave_Approval_id, LC.Leave_id,-- LC.For_date,
					  LC.Request_Date,
					  LC.Is_Approve, ISNULL(LC.MComment, ''), LC.Actual_Leave_Day, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, ISNULL(CAST(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID AS varchar(10)), ''), 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, T0080_EMP_MASTER_1.Emp_Full_Name, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, dbo.T0080_EMP_MASTER.Branch_ID, LC.A_Emp_Id, LC.Tran_id, 
                      dbo.T0040_LEAVE_MASTER.Apply_Hourly,
                      dbo.T0040_LEAVE_MASTER.Default_Short_Name   --Added By Jaina 25-11-2015
                      ,dbo.T0080_EMP_MASTER.Dept_ID
					  ,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID
					  ,S_Emp_ID




