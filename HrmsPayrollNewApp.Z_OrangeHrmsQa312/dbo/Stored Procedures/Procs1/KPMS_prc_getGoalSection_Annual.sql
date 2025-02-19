-- exec KPMS_prc_getGoalSection  
-- drop proc KPMS_prc_getGoalSection  
CREATE procedure [dbo].[KPMS_prc_getGoalSection_Annual] 
@index varchar(10),
@Goalindex varchar(10)
as  
begin  
 declare @lResult varchar(max) = ''  
 select @lResult = @lResult + '<tr><td><select class="custom-select txtGoalName'+@index+'_'+@Goalindex+'" id="drpGoal" onchange="DrpSec3(2)"><option value="0">--select--</option></select></td> 
 <td><select class="custom-select txtSubGoalName'+@index+'_'+@Goalindex+'" id="drpSubGoal"><option value="0">--select--</option></select></td>
 <td><select class="custom-select drpFrequency">  
 <option value="0"> -- Select -- </option><option value="1">Monthly</option><option value="2">Quaterly</option><option value="3">Yearly</option></select></td>
 <td><input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" /></td>  
 <td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" />  
 </div></td><td><select class="custom-select drpModule" onchange="getModuleid(this);" disabled><option value="0"> -- Select -- </option></select></td><td><select class="custom-select drpType" disabled><option value="0"> -- Select -- </option><option value="1">On Target</option>  
 <option value="2">On Achievement</option></select></td>  <td><a href="javascript:;" onclick="AddGoal(this);"><i class="fas fa-plus-circle float-right" style="float:none !important;"></i></a><a href="javascript:;" onclick="RemoveGoal(this);"><i class="fas fa-trash float-right" style="float:none !important;"></i></a></td></tr></tbody></table></div></div></td></tr>'  
  
 select @lResult as Result  
end