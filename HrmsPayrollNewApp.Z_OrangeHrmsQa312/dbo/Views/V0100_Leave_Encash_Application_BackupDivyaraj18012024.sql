



CREATE VIEW [dbo].[V0100_Leave_Encash_Application_BackupDivyaraj18012024]
AS
SELECT     dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Cmp_ID, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Emp_ID, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Code, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Date, 
                      CASE WHEN la.Lv_Encash_Apr_Status = 'A' THEN LA.Lv_Encash_Apr_Days ELSE dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Days END AS Lv_Encash_App_Days,
                       dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Status, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Comments, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Login_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.System_Date, dbo.T0040_LEAVE_MASTER.Leave_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Basic_Salary, dbo.T0080_EMP_MASTER.Grd_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_CompOff_Dates, dbo.T0040_LEAVE_MASTER.Leave_Count, dbo.T0040_LEAVE_MASTER.Default_Short_Name, 
                      dbo.T0040_LEAVE_MASTER.Max_Accumulate_Balance, dbo.T0040_LEAVE_MASTER.Apply_Hourly, dbo.T0095_INCREMENT.Vertical_ID, 
                      dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_Encash_Amount
FROM         dbo.T0100_LEAVE_ENCASH_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_LEAVE_ENCASH_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID Cross APPLY
                      (Select * from dbo.fn_getEmpIncrement(T0100_LEAVE_ENCASH_APPLICATION.Cmp_Id,T0100_LEAVE_ENCASH_APPLICATION.Emp_Id,T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Date)) Qry Inner JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON Qry.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0120_LEAVE_ENCASH_APPROVAL AS LA WITH (NOLOCK)  ON LA.Lv_Encash_App_ID = dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_ID

