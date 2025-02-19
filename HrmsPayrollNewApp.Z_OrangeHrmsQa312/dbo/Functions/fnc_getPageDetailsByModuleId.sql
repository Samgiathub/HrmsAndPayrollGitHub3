-- select dbo.fnc_getPageDetailsByModuleId(1)  
-- drop function dbo.fnc_getPageDetailsByModuleId  
CREATE FUNCTION [dbo].[fnc_getPageDetailsByModuleId](@rModuleId INT,@rCmpId int,@rRoleId int)  
RETURNS VARCHAR(MAX)  
AS  
BEGIN  
 DECLARE @lResult VARCHAR(MAX) = ''  
  
 SELECT @lResult = @lResult + '<ol class="dd-list"><li class="dd-item" attrpageid=' + CONVERT(varchar,pm.Page_Id) + '><div class="dd-handle"><div class="menupages form-group"><label class="form-group-label-child">' + Page_Name + '</label>  
 <div class="checkbox-list"><label class="checkbox-inline"><input type="checkbox" ' + case when isnull(pr.Is_View,0) = 1 then 'checked="checked"' else '' end + ' class="form-check-input inlineCheckbox inlineCheckbox1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;V
iew</label>  
 <label class="checkbox-inline"><input type="checkbox" ' + case when isnull(pr.Is_Save,0) = 1 then 'checked="checked"' else '' end + ' class="form-check-input inlineCheckbox inlineCheckbox2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Create</label>  
 <label class="checkbox-inline"><input type="checkbox" ' + case when isnull(pr.Is_Edit,0) = 1 then 'checked="checked"' else '' end + ' class="form-check-input inlineCheckbox inlineCheckbox3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Modify</label>  
 <label class="checkbox-inline"><input type="checkbox" ' + case when isnull(pr.Is_Delete,0) = 1 then 'checked="checked"' else '' end + ' class="form-check-input inlineCheckbox inlineCheckbox4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Delete</label>  
 </div></div></div></li></ol>'  
 FROM KPMS_T0120_Page_Master PM  
 left join KPMS_T0125_Page_Rights PR on PR.Page_Id = pm.Page_Id and PR.Module_Id = @rModuleId and pr.Cmp_Id = @rCmpId and pr.Emp_Role_Id = @rRoleId  
 where pm.Module_Id = @rModuleId --and pm.Cmp_Id = @rCmpId  
  
 RETURN @lResult  
END