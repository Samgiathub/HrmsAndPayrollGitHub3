
  
  
  
  
  
  
  
  
  
  
  
--ALTER view [dbo].[V0100_Claim_Application_New]  
--AS  
--SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name,   
--                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name,   
--                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No,   
--                      dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, dbo.T0080_EMP_MASTER.Emp_code,   
--                      dbo.T0080_EMP_MASTER.Emp_Superior,   
--                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_New,   
--                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code  
--FROM         dbo.T0100_CLAIM_APPLICATION LEFT OUTER JOIN  
--                      dbo.T0040_CLAIM_MASTER ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN  
--                      dbo.T0080_EMP_MASTER ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN  
--                      dbo.T0095_INCREMENT ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID  
  
  
  
--GO  
CREATE VIEW [dbo].[V0100_Claim_Application_New_backup_301021]  
AS  
SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, --dbo.T0040_CLAIM_MASTER.Claim_Name,   
                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name,   
                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No,   
                      dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, dbo.T0080_EMP_MASTER.Emp_code,   
                      SEMP.Emp_Full_Name as S_emp_name,dbo.T0100_CLAIM_APPLICATION.S_Emp_ID as S_emp_ID,   
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_New,   
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,SEMP.Emp_Full_Name as Supervisor, dbo.T0095_INCREMENT.Desig_ID,  
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,  --Added By Jaina 15-09-2015  
                      case when Submit_Flag=0 then 'Submitted' else 'Drafted' End as Draft_status,  
                      Submit_Flag,dbo.T0095_INCREMENT.Dept_ID,   --Added By Jaina 12-08-2016  
                      ISNULL(dbo.T0095_INCREMENT.Grd_ID, 0) as Grd_ID,'01/01/1900' As Claim_Apr_Date,  
      ISNULL(REVERSE(STUFF(REVERSE((SELECT DISTINCT   CD.Claim_Name + ','  
                            FROM          V0100_Claim_Application_New_Detail CD WITH (NOLOCK)  
                            WHERE      CD.Claim_App_ID IN  
                                                       (SELECT     cast(data AS numeric(18, 0))  
                                                         FROM          dbo.Split(ISNULL(dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, '0'), '#')  
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') AS Claim_Name 
														
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK) LEFT OUTER JOIN  
                      dbo.T0040_CLAIM_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN  
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.S_Emp_ID = SEMP.Emp_ID left join  
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID  
  
  
  
  
