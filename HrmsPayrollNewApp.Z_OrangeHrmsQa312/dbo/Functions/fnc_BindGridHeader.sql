CREATE function [dbo].[fnc_BindGridHeader](@Cmp_Id int)          
returns varchar(max)          
as          
BEGIN        
 declare @lResult3 varchar(max) =''        
declare @PivotColDedVar as NVARCHAR(MAX)            
    Select @PivotColDedVar = List_Output  --+ ' , ' + '[Total_Int]'             
    from (     SELECT STUFF((SELECT '    <th class="g1" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_')  + '_G' + cast(level_Grp_Id as varchar(100)) + ']</th>'            
      FROM KPMS_T0040_Level_Master    where level_Grp_Id = 1  and IsActive = 1 and Cmp_ID = @Cmp_Id       
      FOR XML PATH(''), TYPE)            
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output          
    )  as T            
        
        
    Declare @PivotColDedVar2 as NVARCHAR(MAX)            
    Select @PivotColDedVar2 = List_Output  --+ ' , ' + '[Total_Int]'             
    from (     SELECT STUFF((SELECT '    <th class="g2" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_')  + '_G' + cast(level_Grp_Id as varchar(100)) + ']</th>'            
      FROM KPMS_T0040_Level_Master where level_Grp_Id = 2 and IsActive = 1 and Cmp_ID = @Cmp_Id     
      FOR XML PATH(''), TYPE)            
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output          
    )  as T            
            
			
 -- select @lResult3 = @lResult3 + '<tr><th width="10%">Section</th><th width="10%">Goal</th><th width="10%">SubGoal</th><th width="10%">Depended_On</th><th width="10%">Depended_Type</th><th width="10%">Type</th>'+ isnull(@PivotColDedVar,'') +' G1' + isnull(@PivotColDedVar2,'') + 'G2'+'<th>Target</th></tr>'          

    select @lResult3 = @lResult3 + '<tr><th min-width="150px">Section</th><th min-width="150px">Goal</th><th min-width="150px">SubGoal</th><th min-width="150px">Depended_On</th><th min-width="150px">Depended_Type</th><th min-width="150px">Type</th>'+ isnull(@PivotColDedVar,'') +' G1' + isnull(@PivotColDedVar2,'') + 'G2'+'<th min-width="150px">Target</th></tr>'          
  -- select @lResult3 = @lResult3 + '<tr><th width="10%">Section</th><th width="10%">Goal</th><th width="10%">SubGoal</th><th width="10%">Type</th><th>Target</th></tr>'          
        
   Return @lResult3;        
END