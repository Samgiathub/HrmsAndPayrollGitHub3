-- exec KPMS_prc_getSection  
-- drop proc KPMS_prc_getSection  
CREATE procedure [dbo].[KPMS_prc_getSection_annual]  
@rCmpId int,
@index varchar(10),
@Goalindex varchar(10)
as  
begin  
 declare @lResult varchar(max) = ''  

 --if @Goalindex<-1
	SET @Goalindex =0

 select @lResult = @lResult + '
 <div class="col-md-12"><div class="card card-primary card-outline" group="sections"><div class="card-header"><div class="form-group"><div class="row">
 <div class="col-md-2" group="headersection"><label>Section Name</label>
<select class="custom-select drpSectionName'+@index+'" id="drpSection" onchange="DrpSec2(1)"></select></div>
 <div class="col-md-3" group="headersection"><label>Weightage Value</label>
 <input type="text" name="Weightage_Value" class="form-control txtSectionWeightage" onkeypress="return isNumberKey(event);" placeholder="80" /></div><div class="col-md-3">
 <label>Section Type</label><select class="custom-select drpSectiontype0 id="drpSectionType"><option value="0">--Select--</option><option value="1">Section_A_Wise</option>
 <option value="2">Section_B_Wise</option></select></div>
 <div class="col-md-1"><a href="javascript:;" onclick="Valid_section(this);"><i class="fas fa-plus-circle float-right"></i></a></div><div class="col-md-0.25"><a href="javascript:;" onclick="RemoveSection(this);">
 <i class="fas fa-trash float-right"></i></a></div>
 </div></div></div><div class="collapse show"><div class="card-body table-responsive p-0 dvSection"><table class="table table-hover text-nowrap sectiontable"><thead><tr><th width="13%">Goal</th>  
 <th width="13%">Sub Goal</th><th width="10%">Frequency</th><th width="8%">Weightage Value</th><th width="5%">Dependency</th><th width="10%">Depen. Module</th>  
 <th width="10%">Depen. Type</th><th width="5%">Action</th></tr></thead><tbody class="tblParentGoal"><tr>  
<td><select class="custom-select txtGoalName'+@index+'_'+@Goalindex+'" id="drpGoal" onchange="DrpSec3(2)"><option value="0">--select--</option></select></td>
<td><select class="custom-select txtSubGoalName'+@index+'_'+@Goalindex+'" id="drpSubGoal"><option value="0">--select--</option></select></td>
 <td><select class="custom-select drpFrequency"><option value="0"> -- Select -- </option><option value="1">Monthly</option>  
 <option value="2">Quaterly</option><option value="3">Yearly</option></select></td><td><input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" /></td>
 <td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" /></div></td><td><select class="custom-select drpModule" onchange="getModuleid(this);" disabled><option value="0"> -- Select -- </option></select></td>  
 <td><select class="custom-select drpType" disabled><option value="0"> -- Select -- </option><option value="1">On Target</option><option value="2">On Achievement</option></select></td>  
   <td><a href="javascript:;" onclick="AddGoal(this);"><i class="fas fa-plus-circle float-right" style="float:none !important;"></i></a>
   <a href="javascript:;" onclick="RemoveGoal(this);"><i class="fas fa-trash float-right" style="float:none !important;"></i></a></td></tr></tbody></table></div></div></div></div>'  
  
 select @lResult as Result  
end

-- onclick="Valid_section(this);"