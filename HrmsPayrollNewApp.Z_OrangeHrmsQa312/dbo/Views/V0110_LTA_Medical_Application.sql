





CREATE VIEW [dbo].[V0110_LTA_Medical_Application]
AS
SELECT     TOP 100 PERCENT dbo.T0110_LTA_Medical_Application.Cmp_ID, dbo.T0110_LTA_Medical_Application.LM_App_ID, 
                      dbo.T0110_LTA_Medical_Application.Emp_ID, dbo.T0110_LTA_Medical_Application.APP_Date, dbo.T0110_LTA_Medical_Application.APP_Code, 
                      dbo.T0110_LTA_Medical_Application.APP_Amount, dbo.T0110_LTA_Medical_Application.APP_Comments, 
                      dbo.T0110_LTA_Medical_Application.File_Name1, dbo.T0110_LTA_Medical_Application.File_Name, dbo.T0110_LTA_Medical_Application.System_Date,
                       dbo.T0110_LTA_Medical_Application.APP_Status, dbo.T0110_LTA_Medical_Application.Leave_From_Date, 
                      dbo.T0110_LTA_Medical_Application.Leave_to_Date, dbo.T0110_LTA_Medical_Application.no_of_Days, dbo.T0110_LTA_Medical_Application.Type_ID, 
                      CASE WHEN T0110_LTA_Medical_Application.Type_ID = 1 THEN 'LTA' WHEN T0110_LTA_Medical_Application.type_id = 2 THEN 'Medical' END AS Type_Name,
                       dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      CASE WHEN app_status = 0 THEN 'Pending' WHEN app_status = 1 THEN 'Approved' WHEN app_status = 2 THEN 'Rejected' END AS Status, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0120_LTA_Medical_Approval.LM_Apr_ID, dbo.T0095_INCREMENT.Branch_ID
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID RIGHT OUTER JOIN
                      dbo.T0110_LTA_Medical_Application WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0120_LTA_Medical_Approval WITH (NOLOCK)  ON dbo.T0110_LTA_Medical_Application.LM_App_ID = dbo.T0120_LTA_Medical_Approval.LM_App_ID ON 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0110_LTA_Medical_Application.Emp_ID




