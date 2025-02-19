CREATE function [dbo].[fnc_BindAchievement_GridHeader]()          
returns varchar(max)          
as          
BEGIN        
 declare @lResult3 varchar(max) =''        
declare @PivotColDedVar as NVARCHAR(MAX)            
    Select @PivotColDedVar = List_Output  --+ ' , ' + '[Total_Int]'             
    from (     SELECT STUFF((SELECT '    <th class="g1" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_')  + '_G' + cast(level_Grp_Id as varchar(100)) + ']</th>'            
      FROM KPMS_T0040_Level_Master    where level_Grp_Id = 1  and IsActive = 1          
      FOR XML PATH(''), TYPE)            
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output          
    )  as T            
        
        
    Declare @PivotColDedVar2 as NVARCHAR(MAX)            
    Select @PivotColDedVar2 = List_Output  --+ ' , ' + '[Total_Int]'             
    from (     SELECT STUFF((SELECT '    <th class="g2" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_')  + '_G' + cast(level_Grp_Id as varchar(100)) + ']</th>'            
      FROM KPMS_T0040_Level_Master    where level_Grp_Id = 2 and IsActive = 1        
      FOR XML PATH(''), TYPE)            
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output          
    )  as T            
            
  select @lResult3 = @lResult3 + '<tr><th width="10%">Section</th><th width="10%">Goal</th><th width="10%">SubGoal</th><th width="10%">Type</th>'+ isnull(@PivotColDedVar,'') + isnull(@PivotColDedVar2,'') +'<th>Target</th><th>Achievement</th></tr>'          
  -- select @lResult3 = @lResult3 + '<tr><th width="10%">Section</th><th width="10%">Goal</th><th width="10%">SubGoal</th><th width="10%">Type</th><th>Target</th></tr>'          
        
   Return @lResult3;        
END   