CREATE procedure [dbo].[KPMS_prc_LoadDataFromSheet_Annual]  
@rXMLStr varchar(max),    
@rCmpId int    
as    
begin    
 DECLARE @lResult varchar(max) = '',@lSectionResult varchar(max) = ''    
 DECLARE @lCnt int,@li int = 1    
 DECLARE @lXML XML    
 SET @lXML = CAST(@rXMLStr AS xml)    
    
 DECLARE @tbltmp TABLE    
 (    
  tid INT IDENTITY(1,1),t_SectionName varchar(300),t_SectionWeightageValue varchar(50)
  ,t_GoalName varchar(300),t_SubGoalName varchar(300),t_Frequency varchar(50),t_WeightageValue varchar(50),t_IsDependent varchar(10),    
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
     
 declare @tblSections table(tid int identity(1,1),tt_SectionName varchar(300),tt_SectionWeightageType varchar(50),tt_SectionWeightageValue varchar(50),tt_SectionStatus varchar(10),tt_Month varchar(10))    
 insert into @tblSections    
  select distinct t_SectionName,'','','','' from @tbltmp   
  
  
 select @lCnt = COUNT(1),@li = 1 from @tblSections    
    
 while @li <= @lCnt    
 begin    
  declare @lSectionName varchar(300) = '',

  @lSectionWeightageValue varchar(50) = ''

    
  select @lSectionName = tt_SectionName,@lSectionWeightageValue = tt_SectionWeightageValue from @tblSections where tid = @li    
    
  select @lSectionResult = @lSectionResult + '<div class="col-md-12"><div class="card card-primary card-outline" group="sections"><div class="card-header"><div class="form-group"><div class="row">    
  <div class="col-md-2" group="headersection"><label>Section Name</label><input type="text" name="Section_1" class="form-control txtSectionName" placeholder="Section A" value="' + @lSectionName + '" /></div>   
  <div class="col-md-3" group="headersection"><label>Weightage Value</label><input type="text" name="Weightage_Value" class="form-control txtSectionWeightage" onkeypress="return isNumberKey(event);" placeholder="80" value="' + @lSectionWeightageValue + '" /></div>      
 <div class="col-md-1"><a href="javascript:;" onclick="AddSection(this);"><i class="fas fa-plus-circle float-right"></i></a></div><div class="col-md-0.25"><a href="javascript:;" onclick="RemoveSection(this);"><i class="fas fa-trash float-right"></i></a></div></div></div></div><div class="collapse show"><div class="card-body table-responsive p-0 dvSection">    
  <table class="table table-hover text-nowrap sectiontable"><thead><tr><th width="13%">Goal</th><th width="13%">Sub Goal</th><th width="10%">Frequency</th>   
  <th width="8%">Weightage Value</th><th width="5%">Dependency</th><th width="10%">Depen. Module</th><th width="10%">Depen. Type</th>  
  <th width="5%">Action</th></tr></thead><tbody class="tblParentGoal">' + dbo.fnc_GetSectionInnerResult_Annual(@rXMLStr,@lSectionName,@rCmpId) + '</tbody></table></div></div></div></div>'    
    
  
  select @li = @li + 1    
 end    
     
 select @lSectionResult as Result    
  ---dbo.fnc_GetSectionInnerResult(@rXMLStr,@lSectionName,@rCmpId)  
end