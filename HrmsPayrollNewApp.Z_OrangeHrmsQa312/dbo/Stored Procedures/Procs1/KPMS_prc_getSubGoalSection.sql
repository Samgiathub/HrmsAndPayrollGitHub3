-- exec KPMS_prc_getSubGoalSection
-- drop proc KPMS_prc_getSubGoalSection
CREATE procedure [dbo].[KPMS_prc_getSubGoalSection]
as
begin
	declare @lResult varchar(max) = ''
	select @lResult = @lResult + '<tr><td>&nbsp;<i class="fas fa-chevron-double-right"></i></td><td><input class="form-control form-control-lg txtGoalName" type="text" placeholder="Goal Name" /></td>
	<td><select class="custom-select drpFrequency"><option value="0"> -- Select -- </option><option value="1">Monthly</option><option value="2">Quaterly</option><option value="3">Yearly</option></select></td><td>
	<select class="custom-select drpWeightageType"><option value="0"> -- Select -- </option><option value="1">Number</option><option value="2">Percentage</option></select></td><td>
	<input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" /></td><td><select class="custom-select drpStatusGoal"><option value="0"> -- Select -- </option><option value="1">Active</option>
	<option value="2">Inactive</option></select></td><td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" /></div></td><td><select class="custom-select drpModule"><option value="0"> -- Select -- </option>
	</select></td><td><select class="custom-select drpType"><option value="0"> -- Select -- </option><option value="1">On Target</option><option value="2">On Achievement</option></select></td>
	<td><input class="form-control form-control-lg txtValue" type="text" placeholder="51%" /></td><td><a href="javascript:;" onclick="RemoveSubGoal(this);"><i class="fas fa-trash float-right"></i></a></td></tr>'
	
	select @lResult as Result
end