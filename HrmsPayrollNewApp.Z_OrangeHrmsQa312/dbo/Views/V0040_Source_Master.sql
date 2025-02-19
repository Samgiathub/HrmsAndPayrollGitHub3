



CREATE VIEW [dbo].[V0040_Source_Master]    
AS    
SELECT     
SM.*
,isnull(STM.Source_Type_Name,'') as Source_Type_Name
FROM         T0040_Source_Master as SM WITH (NOLOCK) LEFT JOIN    
                      t0030_source_type_master AS STM  WITH (NOLOCK) ON     
                      SM.Source_type_ID = STM.Source_type_Id
  



