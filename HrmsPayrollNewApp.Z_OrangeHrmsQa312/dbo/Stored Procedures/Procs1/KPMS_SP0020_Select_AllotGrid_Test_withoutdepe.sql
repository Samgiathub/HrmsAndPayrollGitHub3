CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_AllotGrid_Test_withoutdepe]               
(              
@Cmp_ID INT,              
@GoalAlt_ID INT,              
@GS_Id Int = NULL,              
@Goal varchar(5) = NULL,              
@rPageIndex INT,              
@rPageSize INT,              
@rSortBy VARCHAR(100)              
)              
as              
BEGIN              
DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = '',@lResult3 varchar(MAX)='',@lResult2 varchar(MAX)='',@lResult4 varchar(MAX)='',@lResult5 varchar(MAX) , @Type INT , @levelAssignId INT            
 IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Allotment_Master_Test WHERE Goal_Allot_ID=@GoalAlt_ID and IsActive < 2)              
 BEGIN                
  Declare @PivotColDedVar as NVARCHAR(MAX)                  
    Select @PivotColDedVar = List_Output  --+ ' , ' + '[Total_Int]'                   
    from (     SELECT STUFF((SELECT '<th class="g1" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_') + ']</th>'                  
    FROM KPMS_T0040_Level_Master    where level_Grp_Id = 1  and IsActive = 1                
      FOR XML PATH(''), TYPE)                  
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output                
    )  as T                  
        
		
              
    Declare @PivotColDedVar2 as NVARCHAR(MAX)                  
    Select @PivotColDedVar2 = List_Output  --+ ' , ' + '[Total_Int]'                   
    from (     SELECT STUFF((SELECT '    <th class="g2" width="10%">[' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_') + ']</th>'                  
      FROM KPMS_T0040_Level_Master    where level_Grp_Id = 2 --and IsActive = 1              
      FOR XML PATH(''), TYPE)                  
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output                
    )  as T                  
                  
   --select @lResult3 = @lResult3 + '<tr><th width="10%">Section</th><th width="10%">Goal</th><th width="10%">SubGoal</th><th width="10%">Type</th>'+ @PivotColDedVar + '</tr>'                
            
   IF OBJECT_ID(N'tempdb..#TmpLevelMaster') IS NOT NULL              
   BEGIN    
   
    DROP TABLE #TmpLevelMaster                                                                                                            
   END              
   select row_number() OVER (order by Level_Id) as Sr_no,* into #TmpLevelMaster from KPMS_T0040_Level_Master  where level_Grp_Id = 1 and IsActive = 1              
   Declare @Row as int = 0              
   Declare @LevelName as varchar(50) = ''              
   Declare @LevelId as varchar(50) = ''              
   select @Row= count(Level_Name) from #TmpLevelMaster              
   declare @count as int = 1              
   Declare @strg as varchar(max) = ''              
   while @count <= @Row              
   BEGIN              
    select @LevelName= Level_Name,@LevelId = Level_ID from #TmpLevelMaster where Sr_no = @count --and IsActive <2              
    set @strg = @strg + '<td attrGroupId="' + convert(Varchar,1) + '" attrLevelId="' + convert(varchar,@LevelId) + '">              
    <input class="form-control form-control-lg txt' + @LevelName + '" type="text" placeholder="Annual Target ( Level of Performance )" onblur="checkWeightage(this);" ></td>'              
    set @count = @count + 1              
   END              
            
               
   IF OBJECT_ID(N'tempdb..#TmpLevelMaster1') IS NOT NULL              
   BEGIN              
    DROP TABLE #TmpLevelMaster1                                                                                                            
   END              
   select row_number() OVER (order by Level_Id) as Sr_no,* into #TmpLevelMaster1 from KPMS_T0040_Level_Master  where level_Grp_Id = 2 and IsActive = 1              
   Declare @Row1 as int = 0              
   Declare @LevelName1 as varchar(50) = ''              
   Declare @LevelId1 as varchar(50) = ''              
   select @Row1 = count(Level_Name) from #TmpLevelMaster1              
   declare @count1 as int = 1              
   Declare @strg1 as varchar(max) = ''              
   while @count1 <= @Row1              
   BEGIN              
    select @LevelName1= Level_Name,@LevelId1 = Level_ID from #TmpLevelMaster1 where Sr_no = @count1 --and IsActive <2              
    set @strg1 = @strg1 + '<td attrGroupId="' + convert(Varchar,2) + '" attrLevelId="' + convert(varchar,@LevelId1) + '">              
    <input class="form-control form-control-lg txt' + @LevelName1 + '" type="text" placeholder="Slab-wise scores" onblur="checkWeightage(this);" ></td>'              
    set @count1 = @count1 + 1              
   END             
          
                 
 select @lResult3 = @lResult3 + dbo.[fnc_BindGridHeader]()            
            
    --select @lResult4 = @lResult4 +[dbo].[fnc_BindGridData](@Type,@levelAssignId)              
            
  select @lResult2 = @lResult2 + '<tr attrSectionId="' + convert(varchar,gsg.GSG_GoalSettingSection_Id) + '" attrGoalId="' + convert(varchar,gsg.GSG_Goal_Id) + '"              
  attrSubGoalId="' + convert(varchar,gsg.GSG_Sub_Goal_Id) + '" attrMainId="' + CONVERT(varchar,gsg.GSG_Id) + '" attrGoalSettingId="' + CONVERT(varchar,GSG_GoalSetting_Id) + '"              
  attrWeightageValue="' + CONVERT(varchar,gs.GS_WeightageValue) + '">              
  <td>' + sm.Section_Name + '</td>              
  <td>'+ gm.Goal_Name +'</td><td>'+ ssm.SubGoal_Name +'</td>              
  <td><select class="custom-select drpSectionWeightage"><option value="0">Select Type<option value="1">Number</option><option value="2">Percentage</option></select>'              
   +'</td>'+@strg+@strg1+'          
  <td> <input class="form-control form-control-lg" id="Targetid"  placeholder="Input" style="width:80px">        
  </td>          
  </tr>'              
             
  from KPMS_T0020_Goal_Master as gm              
  inner join KPMS_T0110_Goal_Setting_Goal_WithoutDepe as gsg on gsg.GSG_Goal_Id=gm.Goal_ID              
  inner join KPMS_T0100_Goal_Setting_WithoutDepe as gs on gs.GS_Id=gsg.GSG_GoalSetting_Id              
  inner join KPMS_T0020_Section_Master as sm on gsg.GSG_GoalSettingSection_Id=sm.Section_ID              
  inner join KPMS_T0020_SubGoal_Master as ssm on gsg.GSG_Sub_Goal_Id = ssm.SubGoal_ID              
  where GS_Id= @GS_Id and GSG_GoalSetting_Id = @GS_Id --and sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1 --group by Goal_Name,GSG_GoalSettingSection_Id,GSG_Goal_Id,GSG_Sub_Goal_Id              
                
 select @lResult2 as Result2 , @lResult3 as Result3              
 END              
END 

