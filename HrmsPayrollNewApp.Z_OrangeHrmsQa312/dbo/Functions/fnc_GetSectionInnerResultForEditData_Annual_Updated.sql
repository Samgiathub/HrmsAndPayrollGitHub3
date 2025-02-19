-- select * from dbo.fnc_GetSectionInnerResultForEditData()    
-- drop function dbo.fnc_GetSectionInnerResultForEditData    
CREATE function [dbo].[fnc_GetSectionInnerResultForEditData_Annual_Updated](@rCmpId int,@rGoalSettingSetionId int)    
returns varchar(max)    
as    
begin    
 declare @lResult varchar(max) = ''      
 select @lResult = '<tr><td><select class="custom-select txtGoalName0_0" id="drpGoal" onchange="DrpSec3(2)"><option value="0">  select </option></select></td>    
 <td><select class="custom-select txtSubGoalName0_0" id="drpSubGoal"><option value="0"> select </option></select></td>    
 <td><select class="custom-select drpFrequency"><option value="0"> -- Select -- </option><option value="1" ' + CASE WHEN GSG_FrequecyId = 1 then 'selected="selected"' ELSE '' END + '>Monthly</option>    
 <option value="2" ' + CASE WHEN GSG_FrequecyId = 2 then 'selected="selected"' ELSE '' END + '>Quaterly</option>    
 <option value="3" ' + CASE WHEN GSG_FrequecyId = 3 then 'selected="selected"' ELSE '' END + '>Yearly</option></select></td>    
  <td><input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" value="' + convert(varchar,GSG_WeightageValue) + '" /></td>    
  <td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" ' + CASE WHEN GSG_IsDependency = 1 then 'checked="checked"' ELSE '' END + ' /></div></td>    
 <td><select class="custom-select drpModule" disabled>' + dbo.fnc_BindDependentExcel(@rCmpId,GM1.Goal_Name) + '</select></td>    
 <td><select class="custom-select drpType" disabled><option value="0"> -- Select -- </option>    
 <option value="1" ' + CASE WHEN GSG_Depend_Type_Id = 1 then 'selected="selected"' ELSE '' END + '>On Target</option>    
 <option value="2" ' + CASE WHEN GSG_Depend_Type_Id = 2 then 'selected="selected"' ELSE '' END + '>On Achievement</option></select></td>    
 <td><a href="javascript:;" onclick="AddGoal(this);"><i class="fas fa-plus-circle float-right"></i></a> <a href="javascript:;" onclick="RemoveGoal(this);"><i class="fas fa-trash float-right" style="float:none !important;"></i></a></td></tr>'    
 from KPMS_T0110_Goal_Setting_Goal    
 inner join KPMS_T0020_Goal_Master GM on GSG_Goal_Id = GM.Goal_ID    
 inner join KPMS_T0020_SubGoal_Master on GSG_Sub_Goal_Id = SubGoal_ID    
 left join KPMS_T0020_Goal_Master GM1 on GSG_Depend_Goal_Id = GM1.Goal_ID    
 where GSG_GoalSettingSection_Id = @rGoalSettingSetionId    
    
 return @lResult    
end

--<input class="form-control form-control-lg txtGoalName" type="text" placeholder="Goal Name" value="' + GM.Goal_Name + '" /></td>
--<input class="form-control form-control-lg txtSubGoalName" type="text" placeholder="Goal Name" value="' + SubGoal_Name + '" />