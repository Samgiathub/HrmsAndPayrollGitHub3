-- select * from dbo.fnc_GetSectionInnerResult()    
-- drop function dbo.fnc_GetSectionInnerResult    
CREATE function [dbo].[fnc_GetSectionInnerResult_Annual](@rXML varchar(max),@rSectionName varchar(300),@rCmpId int)    
returns varchar(max)    
as    
begin    
 DECLARE @lResult varchar(max) = ''    
 DECLARE @lCnt int,@li int = 1    
 DECLARE @lXML XML    
 SET @lXML = CAST(@rXML AS xml)    
    
 DECLARE @tbltmp TABLE    
 (    
  tid INT IDENTITY(1,1),t_SectionName varchar(300),t_SectionWeightageValue varchar(50),
  t_GoalName varchar(300),t_SubGoalName varchar(300),t_Frequency varchar(50),t_WeightageValue varchar(50),t_IsDependent varchar(10),    
  t_DependentModule varchar(300),t_DependentType varchar(50),t_DependentValue varchar(50)    
 )    
 INSERT INTO @tbltmp    
 SELECT T.c.value('@SectionName','varchar(300)') AS SectionName,    
 T.c.value('@SectionWeightageValue','varchar(50)') AS SectionWeightageValue,       
 T.c.value('@GoalName','varchar(300)') AS GoalName,    
 T.c.value('@SubGoalName','varchar(300)') AS SubGoalName,    
 T.c.value('@Frequency','varchar(50)') AS Frequency,    
 T.c.value('@WeightageValue','varchar(50)') AS WeightageValue,      
 T.c.value('@IsDependent','varchar(10)') AS IsDependent,    
 T.c.value('@DependentModule','varchar(300)') AS DependentModule,    
 T.c.value('@DependentType','varchar(50)') AS DependentType,    
 T.c.value('@DependentValue','varchar(50)') AS DependentValue    
 FROM @lXML.nodes('/GoalCreations/Goals') AS T(c)    
 where T.c.value('@SectionName','varchar(300)') = @rSectionName    
     
 select @lCnt = COUNT(1),@li = 1 from @tbltmp    
    
 while @li <= @lCnt    
 begin    
  declare @lGoalName varchar(300) = '',@lSubGoalName varchar(300) = '',@lWeightageValue varchar(50) = '',    
  @lIsDependent varchar(10) = '',@lDependentModule varchar(300) = '',@lDependentType varchar(50) = '',    
  @lDependentValue varchar(50) = '',@lFrequency varchar(50) = ''    
    
  select @lGoalName = t_GoalName,@lSubGoalName = t_SubGoalName,@lWeightageValue = t_WeightageValue,@lFrequency = t_Frequency,    
  @lIsDependent = t_IsDependent,@lDependentModule = t_DependentModule,@lDependentType = t_DependentType,@lDependentValue = t_DependentValue from @tbltmp where tid = @li    
  and t_SectionName = @rSectionName    
    
  select @lResult = @lResult + '<tr><td><input class="form-control form-control-lg txtGoalName" type="text" placeholder="Goal Name" value="' + @lGoalName + '" /></td>    
  <td><input class="form-control form-control-lg txtSubGoalName" type="text" placeholder="Goal Name" value="' + @lSubGoalName + '" /></td>    
  <td><select class="custom-select drpFrequency"><option value="0"> -- Select -- </option><option value="1" ' + CASE WHEN @lFrequency = 'Monthly' then 'selected="selected"' ELSE '' END + '>Monthly</option>    
  <option value="2" ' + CASE WHEN @lFrequency = 'Quaterly' then 'selected="selected"' ELSE '' END + '>Quaterly</option>    
  <option value="3" ' + CASE WHEN @lFrequency = 'Yearly' then 'selected="selected"' ELSE '' END + '>Yearly</option></select></td>    
  <td><input class="form-control form-control-lg txtWeightageValue" type="text" placeholder="Weightage Value" value="' + @lWeightageValue + '" /></td>        
  <td><div class="custom-control"><input type="checkbox" class="chkDependency" onclick="getDependency(this);" ' + CASE WHEN @lIsDependent = 'True' or @lIsDependent = '1' then 'checked="checked"' ELSE '' END + ' /></div></td>    
  <td><select class="custom-select drpModule">' + dbo.fnc_BindDependentExcel(@rCmpId,@lDependentModule) + '</select></td>    
  <td><select class="custom-select drpType"><option value="0"> -- Select -- </option>    
  <option value="1" ' + CASE WHEN @lDependentType = 'On Target' then 'selected="selected"' ELSE '' END + '>On Target</option>    
  <option value="2" ' + CASE WHEN @lDependentType = 'On Achievement' then 'selected="selected"' ELSE '' END + '>On Achievement</option></select></td>    
    <td><a href="javascript:;" onclick="AddGoal(this);"><i class="fas fa-plus-circle float-right" style="float:none !important;"></i></a><a href="javascript:;" onclick="RemoveGoal(this);"><i class="fas fa-trash float-right" style="float:none !important;"></i></a></td></tr>'    
    
  select @li = @li + 1    
 end    
    
 return @lResult    
end