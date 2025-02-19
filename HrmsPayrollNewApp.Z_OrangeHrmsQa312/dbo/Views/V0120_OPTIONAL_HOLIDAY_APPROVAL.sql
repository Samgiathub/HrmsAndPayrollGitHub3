




CREATE VIEW [dbo].[V0120_OPTIONAL_HOLIDAY_APPROVAL]
AS
SELECT     dbo.T0120_Op_Holiday_Approval.Op_Holiday_Apr_ID, 
		   dbo.T0120_Op_Holiday_Approval.Op_Holiday_App_ID, 	
		   dbo.T0120_Op_Holiday_Approval.Emp_ID, 	
		   dbo.T0120_Op_Holiday_Approval.Cmp_ID, 	
		   dbo.T0120_Op_Holiday_Approval.HDay_ID, 	
		    Convert(varchar(10), T0040_HOLIDAY_MASTER.H_From_Date, 103) as H_From_Date,
		   Convert(varchar(10), T0040_HOLIDAY_MASTER.H_To_Date, 103) as H_To_Date,
		   dbo.T0120_Op_Holiday_Approval.S_Emp_ID, 	
		   dbo.T0120_Op_Holiday_Approval.Op_Holiday_Apr_Date, 	
		   dbo.T0120_Op_Holiday_Approval.Op_Holiday_Apr_Status as Op_Holiday_status, 	
		   dbo.T0120_Op_Holiday_Approval.Op_Holiday_Apr_Comments, 	
		   dbo.T0120_Op_Holiday_Approval.Created_By, 	
		   dbo.T0120_Op_Holiday_Approval.Date_Created, 	
		   dbo.T0120_Op_Holiday_Approval.Modify_By, 	
		   dbo.T0120_Op_Holiday_Approval.Date_Modified, 	
		   dbo.V0080_Employee_Master.Emp_First_Name,
		   dbo.V0080_Employee_Master.Emp_Second_Name, 
		   dbo.V0080_Employee_Master.Branch_Name,
		   dbo.V0080_Employee_Master.Branch_ID,
		   dbo.V0080_Employee_Master.Emp_Left,
		   V0080_Employee_Master.Alpha_Emp_Code,
           dbo.V0080_Employee_Master.Emp_Last_Name, dbo.V0080_Employee_Master.Emp_code, dbo.V0080_Employee_Master.Emp_Full_Name, 
           dbo.T0040_HOLIDAY_MASTER.Hday_Name, dbo.V0080_Employee_Master.Emp_Superior
           ,dbo.V0080_Employee_Master.Dept_ID  
FROM       dbo.V0080_Employee_Master WITH (NOLOCK) INNER JOIN
           dbo.T0120_Op_Holiday_Approval WITH (NOLOCK)  ON dbo.V0080_Employee_Master.Emp_ID = dbo.T0120_Op_Holiday_Approval.Emp_ID INNER JOIN
           dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK)  ON dbo.T0120_Op_Holiday_Approval.HDay_ID = dbo.T0040_HOLIDAY_MASTER.Hday_ID AND 
           dbo.T0120_Op_Holiday_Approval.HDay_ID = dbo.T0040_HOLIDAY_MASTER.Hday_ID


