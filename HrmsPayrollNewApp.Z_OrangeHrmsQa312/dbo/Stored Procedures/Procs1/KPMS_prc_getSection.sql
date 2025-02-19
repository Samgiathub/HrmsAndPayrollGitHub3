-- exec KPMS_prc_getSection  
-- drop proc KPMS_prc_getSection  
CREATE procedure [dbo].[KPMS_prc_getSection]  
@rCmpId int  
as  
begin  
 declare @lResult varchar(max) = ''  
 select @lResult = @lResult + '<div class="col-md-12"><div class="card card-primary card-outline" group="sections"><div class="card-header"><div class="form-group"><div class="row"><div class="col-md-2" group="headersection">  
 <input type="text" name="Section_1" class="form-control txtSectionName" placeholder="Section A" /></div><div class="col-md-2" group="headersection"><select class="custom-select drpSectionWeightage"><option value="0"> -- Select -- </option>  
 <option value="1">Number</option><option value="2">Percentage</option></select></div><div class="col-md-1" group="headersection"><input type="text" name="Weightage_Value" class="form-control txtSectionWeightage" placeholder="80" />  
 </div><div class="col-md-2" group="headersection"><select class="custom-select drpSectionStatus"><option value="0"> -- Select -- </option><option value="1">Active</option><option value="2">Inactive</option></select></div>  
 <div class="col-md-2" group="headersection"><select id="Section" class="custom-select drpSectionMonth">' + dbo.fnc_BindMonthByYear(@rCmpId) + '</select></div><div class="col-md-3"><a href="javascript:;" onclick="RemoveSection(this);">  
 <i class="fas fa-trash float-right"></i></a></div></div></div></div><div class="collapse show"><div class="card-body table-responsive p-0 dvSection"><table class="table table-hover text-nowrap sectiontable"><thead><tr><th width="13%">Goal</th>  
 <th width="13%">Sub Goal</th><th width="10%">Frequency</th><th width="10%">Weightage Type</th><th width="8%">Weightage Value</th><th width="10%">Status</th><th width="5%">Dependency</th><th width="10%">Depen. Module</th>  
 <th width="10%">Depen. Type</th><th width="8%">Depen. Value</th><th width="5%">Action</th></tr></thead><tbody class="tblParentGoal"><tr>  
 <td><input class="form-control form-control-lg txtGoalName" type="text" placeholder="Goal Name" /></td>  
 <td><input class="form-control form-control-lg txtSubGoalName" type="text" placeholder="Goal Name" /></td><td><select class="custom-select drpFrequency"><option value="0"> -- Select -- </option><option value="1">Monthly</option>  
 <option value="2">Quaterly</option><option value="3">Yearly</option></select></td><td><select class="custom-select drpWeightageType">  
 <option value="0"> -- Select -- </option><option value="1">Number</option><option value="2">Percentage</option></select>  
 </td><td><input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" /></td><td><select class="custom-select drpStatusGoal"><option value="0"> -- Select -- </option><option value="1">Active</option>  
 <option value="2">Inactive</option></select></td><td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" /></div></td><td><select class="custom-select drpModule"><option value="0"> -- Select -- </option
></select></td>  
 <td><select class="custom-select drpType"><option value="0"> -- Select -- </option><option value="1">On Target</option><option value="2">On Achievement</option></select></td>  
 <td><input class="form-control form-control-lg txtValue" type="text" placeholder="51%" /></td>  
 <td><a href="javascript:;" onclick="AddGoal(this);"><i class="fas fa-plus-circle float-right"></i></a></td></tr></tbody></table></div></div></div></div>'  
  
 select @lResult as Result  
end