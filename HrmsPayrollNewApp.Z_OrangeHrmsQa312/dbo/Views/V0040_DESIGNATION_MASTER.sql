





CREATE VIEW [dbo].[V0040_DESIGNATION_MASTER]    
AS    
SELECT     dbo.T0040_DESIGNATION_MASTER.Desig_ID, dbo.T0040_DESIGNATION_MASTER.Cmp_ID, dbo.T0040_DESIGNATION_MASTER.Desig_Dis_No,     
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_DESIGNATION_MASTER.Def_ID, dbo.T0040_DESIGNATION_MASTER.Parent_ID,     
                      ISNULL(dbo.T0040_DESIGNATION_MASTER.Is_Main,0) AS Is_Main, ISNULL(T0040_DESIGNATION_MASTER_1.Desig_Name, 'Main') AS Parent_Name    
           ,dbo.T0040_DESIGNATION_MASTER.Desig_Code  , dbo.T0040_DESIGNATION_MASTER.Absconding_Reminder,dbo.T0040_DESIGNATION_MASTER.IsActive,dbo.T0040_DESIGNATION_MASTER.InActive_EffeDate       
           ,dbo.T0040_DESIGNATION_MASTER.Mode_Of_Travel,CASE WHEN dbo.T0040_DESIGNATION_MASTER.IsActive=1 THEN 'awards_link'	WHEN dbo.T0040_DESIGNATION_MASTER.IsActive=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END  as Status_Color                   
           FROM dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) LEFT OUTER JOIN    
                      dbo.T0040_DESIGNATION_MASTER AS T0040_DESIGNATION_MASTER_1  WITH (NOLOCK) ON     
                      dbo.T0040_DESIGNATION_MASTER.Parent_ID = T0040_DESIGNATION_MASTER_1.Desig_ID    
  



