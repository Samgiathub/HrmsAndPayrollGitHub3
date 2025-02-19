CREATE procedure [dbo].[KPMS_prc_LoadTargetDataFromSheet1]            
@GS_Id Int = NULL,      
@rXMLStr varchar(max)        
as          
begin          
          
  DROP TABLE IF EXISTS [dbo].[#TMPExcelData ];         
    DROP TABLE IF EXISTS [dbo].[kpms_tblExcelData ];        
    
  exec (@rXMLStr);        
         
  DECLARE @lResult nvarchar(max) = '',@lResult2 varchar(max) = ''           
  SELECT ROW_NUMBER() over (order by ORDINAL_POSITION) as Rid,COLUMN_NAME into #TMPExcelData      
  FROM Orange_Version_03102019.INFORMATION_SCHEMA.COLUMNS         
  WHERE TABLE_NAME = 'kpms_tblExcelData'        
    
  Declare @RowCount as numeric(18,0) = 1        
  Declare @Tmpcount as numeric(18,0) = 0        
  SELECT @Tmpcount = COUNT(1) from #TMPExcelData        
  Declare @ColVal as Varchar(100) = ''         
    
  DROP TABLE IF EXISTS [dbo].[#TMP ];      
    
  SELECT * INTO #TMP FROM kpms_tblExcelData WHERE 1=0    
    
  DECLARE @lResult3 varchar(max) = '' ,@lResultCol varchar(max) = '',@lResult5 varchar(max) = ''               
  SELECT @Tmpcount = COUNT(1) from #TMPExcelData    
  set @RowCount = 1    
  while @RowCount <= @Tmpcount         
  Begin        
 Select @ColVal = COLUMN_NAME from #TMPExcelData where Rid = @RowCount        
    
 select @lResult2 = @lResult2 + '<th>'+@ColVal+'</th>'     
      
 IF @lResultCol = ''     
 BEGIN     
  select  @lResultCol = '''<td> ''+' +  @ColVal + '+'' </td>'' as '+ @ColVal +' ,'     
 END    
 ELSE    
 BEGIN    
  select @lResultCol =  @lResultCol + '''<td> ''+' +  @ColVal + '+ ''</td>'' as '+ @ColVal +' ,'    
 END    
    
   set @RowCount = @RowCount + 1        
  END    
      
  set @lResultCol = substring(@lResultCol, 1, (len(@lResultCol) - 1))    
      
  set @lResult3 =  'insert into #TMP     
      select ' + @lResultCol + ' from kpms_tblExcelData'     
    
      
  exec(@lResult3)    
    
  Declare @listStr VARCHAR(MAX) = ''    
   
   
 Select  @listStr = @listStr + C.String + char(13)    
 From  #tmp A    
 Cross Apply (Select XMLData = cast((Select A.* for XML RAW) as xml)) B    
 Cross Apply (    
              Select distinct gm.Goal_Name, sm.Section_Name,ssm.SubGoal_Name, String ='<tr attrSectionId="' + convert(varchar,gsg.GSG_GoalSettingSection_Id) + '" attrGoalId="' + convert(varchar,gsg.GSG_Goal_Id) + '"              
  attrSubGoalId="' + convert(varchar,gsg.GSG_Sub_Goal_Id) + '" attrMainId="' + CONVERT(varchar,gsg.GSG_Id) + '" attrGoalSettingId="' + CONVERT(varchar,GSG_GoalSetting_Id) + '"              
  attrWeightageValue="' + CONVERT(varchar,gs.GS_WeightageValue) + '">'+ Stuff((Select ',' +Value     
               From  (    
                        Select  Value  = ''+attr.value('.','varchar(max)')+''    
                         From  B.XMLData.nodes('/row') as A(r)    
                         Cross Apply A.r.nodes('./@*') AS B(attr)    
                     ) X    
               For XML Path ('')),1,1,'') + '</tr>'     
from KPMS_T0020_Goal_Master as gm            
  inner join KPMS_T0110_Goal_Setting_Goal as gsg on gsg.GSG_Goal_Id=gm.Goal_ID            
  inner join KPMS_T0100_Goal_Setting as gs on gs.GS_Id=gsg.GSG_GoalSetting_Id            
  inner join KPMS_T0020_Section_Master as sm on gsg.GSG_GoalSettingSection_Id=sm.Section_ID            
  inner join KPMS_T0020_SubGoal_Master as ssm on gsg.GSG_Sub_Goal_Id = ssm.SubGoal_ID            
  where GS_Id= @GS_Id and GSG_GoalSetting_Id = @GS_Id  and  sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1     
             ) C    

where c.Section_Name = trim(replace(replace(a.Section,'<td>',''),'</td>',''))
and c.Goal_Name = trim(replace(replace(a.Goal,'<td>',''),'</td>',''))
and c.SubGoal_Name = trim(replace(replace(A.SubGoal ,'<td>',''),'</td>',''))

 
    
 Select @lResult5 = replace(replace(replace(@listStr,'&lt;','<'),'&gt;','>'),',','') --as Result    
 select @lResult = @lResult + '<hr><table class="table" id="mytable" style=" display: block; border: 1px solid #ddd; overflow: scroll;"><thead id="tblHeader"><tr>'+@lResult2+' </tr></thead>    
 <tbody id="tblData2">'+@lResult5+'</tbody>    
 </table><div id="dvPagination" class="pagination alternate dataTables_paginate"></div>'        
    select @lResult as lResult2       
	




 END        