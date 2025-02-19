CREATE PROCEDURE [dbo].[KPMS_P0100_EMP_PAGE_GRID_ASSIGNED]  
@rCmpId int,  
@rRoleId int,  
@rModuleId int  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @lResult VARCHAR(MAX) = ''  
  
 select @lResult = @lResult + '<ol id="mnuTitle_1" class="dd-list"><li class="dd-item" attrmenuid="' + CONVERT(varchar,ms.Module_Id) + '"><div class="dd-handle"><div class="menupages form-group">  
 <label class="form-group-label-header">'+ Module_Name +'</label>  
 <div class="checkbox-list"><label class="checkbox-inline"><input type="checkbox" class="form-check-input inlineCheckbox inlineCheckbox1" onclick="CheckUnCheckALL(this,1,1);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;View</label>  
 <label class="checkbox-inline"><input type="checkbox" class="form-check-input inlineCheckbox inlineCheckbox2" onclick="CheckUnCheckALL(this,2,1);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Create</label>  
 <label class="checkbox-inline"><input type="checkbox" class="form-check-input inlineCheckbox inlineCheckbox3" onclick="CheckUnCheckALL(this,3,1);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Modify</label>  
 <label class="checkbox-inline"><input type="checkbox" class="form-check-input inlineCheckbox inlineCheckbox4" onclick="CheckUnCheckALL(this,4,1);">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Delete</label></div></div></div></li>  
 ' + dbo.fnc_getPageDetailsByModuleId(ms.Module_Id,@rCmpId,@rRoleId) + '</ol>'  
 from KPMS_T0110_Module_Master AS ms   
--  where ms.Cmp_Id = @rCmpId and  ms.IsActive= 1 and ms.Module_Id = @rModuleId   
 where  ms.IsActive= 1 and ms.Module_Id = @rModuleId --and ms.Cmp_Id = @rCmpId
 select @lResult as Result  
END