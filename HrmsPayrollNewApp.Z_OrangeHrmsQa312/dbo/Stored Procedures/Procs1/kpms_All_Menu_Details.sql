CREATE PROCEDURE [dbo].[kpms_All_Menu_Details]      
AS      
BEGIN      
 SET NOCOUNT ON;      
 SET ARITHABORT ON;      
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;      
      
      
 DECLARE @lResult VARCHAR(MAX) = ''      
   
    
 select @lResult = @lResult +'
 <li class="nav-item">
                            <a href="#" class="nav-link">
                                  <i class="nav-icon far fas fa-bullseye"></i>  
                                <p>
                                     '+ Module_Name +'    
                                    <i class="fas fa-angle-left right"></i>
                                </p>
                            </a>
                            ' +  dbo.fnc_SubMenuDetails(ms.Module_Id) +'
			  </li>'
                      
from KPMS_T0110_Module_Master as ms  

	select  @lResult as Result

END
