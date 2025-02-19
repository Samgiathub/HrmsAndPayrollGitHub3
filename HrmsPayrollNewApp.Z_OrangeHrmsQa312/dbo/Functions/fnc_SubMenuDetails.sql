CREATE FUNCTION [dbo].[fnc_SubMenuDetails](@rModuleId INT)    
RETURNS VARCHAR(MAX)    
AS    
BEGIN    
 DECLARE @lResult VARCHAR(MAX) = ''    
    
 SELECT @lResult = @lResult +   
'<li class="nav-item"id='+ CONVERT(varchar,pm.Page_Id) +'>  
                                    <a href="./'+ Page_Name +'" class="nav-link">  
                                        <i class="far fa-circle nav-icon"></i>  
                                        <p> '+ Page_Name +' </p>  
                                    </a> </li>'  
 FROM KPMS_T0110_Module_Master as mm inner join KPMS_T0120_Page_Master as pm on pm.Module_Id = mm.Module_Id       
 where pm.Module_Id = @rModuleId   
  
-- FROM KPMS_T0110_Module_Master as mm inner join KPMS_T0120_Page_Master as pm on pm.Module_Id = mm.Module_Id      
  
 RETURN @lResult    
END