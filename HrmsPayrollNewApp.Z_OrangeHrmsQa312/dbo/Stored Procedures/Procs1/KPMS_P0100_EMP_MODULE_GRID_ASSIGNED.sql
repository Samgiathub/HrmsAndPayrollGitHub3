-- EXEC KPMS_P0100_EMP_MODULE_GRID_ASSIGNED 119  
-- DROP PROCEDURE KPMS_P0100_EMP_MODULE_GRID_ASSIGNED  
CREATE PROCEDURE [dbo].[KPMS_P0100_EMP_MODULE_GRID_ASSIGNED]  
@rCmpId int,  
@rRoleId int  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @lResult VARCHAR(MAX) = ''  
  
 select @lResult = @lResult + '<ol class="dd-list"><li attrModuleId="' + CONVERT(varchar,ms.Module_Id) + '" class="dd-item">  
 <div class="dd-handle"><div class="menupages form-group">  
 <label class="form-group-label-header1">  
 <input type="checkbox" ' + case when mr.Module_Rights_Id is not null then 'checked="checked"' else '' end + '  
 class="form-check-input inlineCheckbox" attrModuleId="' + CONVERT(varchar,ms.Module_Id) + '">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + Module_Name + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>  
 <div class="checkbox-list">  
 <label class="checkbox-inline"><input type="checkbox" class="form-check-input inlineCheckbox inlineCheckbox1"  
 ' + case when isnull(mr.IsActive,0) = 1 then 'checked="checked"' else '' end + '>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Active</label></div>  
 </div></div></li></ol>'  
 from KPMS_T0110_Module_Master AS ms  
 left outer join KPMS_T0115_Module_Rights as mr on ms.Module_Id = mr.Module_Id and Emp_Role_Id = @rRoleId and mr.Cmp_Id = @rCmpId
 --where ms.Cmp_Id = @rCmpId   
 select @lResult as Result  
END  
  
 