CREATE VIEW [dbo].[V0080_Canteen_Application_Backup_Bhavesh_24042023]
AS
SELECT        
    CN.App_Id, 
    ISNULL(CN.App_No, 'CN' + CAST(CN.App_Id AS nvarchar)) AS App_No, 
    FORMAT(CN.Receive_Date, 'dd/MM/yyyy') AS Receive_Date, 
    CN.Emp_Name,
    DM.Desig_Name,
    DPM.Dept_Name, 
    CN.Emp_Id, 
    CN.Cmp_Id, 
    CN.Food,  -- Explicitly specify the table alias
    CN.Duration, 
    CN.Canteen_Name, 
    CNM.Device_Name AS Canteen, 
    CASE 
        WHEN CN.Food = 1 THEN 'Breakfast' 
        WHEN CN.Food = 2 THEN 'Lunch' 
        WHEN CN.Food = 3 THEN 'Dinner' 
    END AS Food_Name, 
    CASE 
        WHEN CN.Duration = 0 THEN 'Unlimited' 
        WHEN CN.Duration = 1 THEN 'Limited' 
    END AS Duration_Name
FROM            
    dbo.T0080_CANTEEN_APPLICATION AS CN 
INNER JOIN
    dbo.T0040_IP_MASTER AS CNM ON CN.Canteen_Name = CNM.IP_ID
INNER JOIN 
    T0040_DESIGNATION_MASTER AS DM ON CN.Desig_Id = DM.Desig_ID
INNER JOIN 
    T0040_DEPARTMENT_MASTER AS DPM ON CN.Dept_Id = DPM.Dept_Id;