    
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_altGoal_Master_Test] 
(                          
@Cmp_ID INT,                          
@GoalAlt_ID INT,                          
@GS_Id Int = NULL,                          
@Goal varchar(5) = NULL,                          
@Emp_Name varchar(20)= NULL,                          
@rPageIndex INT,                          
@rPageSize INT,                          
@rSortBy VARCHAR(100)                          
)                          
as                          
BEGIN                          
 IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Allotment_Master_Test WHERE Goal_Allot_ID=@GoalAlt_ID and IsActive < 2)                          
 BEGIN                          
  DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''                          
  DECLARE @lTotalRecords INT = 0                          
  SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 7 else @rPageSize end                          
                          
  CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)                           
                           
  INSERT INTO #Temp                          
  SELECT Goal_Allot_ID FROM KPMS_T0020_Goal_Allotment_Master_Test gm WITH(NOLOCK) join T0080_EMP_MASTER em on gm.Emp_ID=em.Emp_ID                          
  WHERE IsActive < 2 and gm.Cmp_ID=@Cmp_ID                           
  AND (Goal_Setting_ID LIKE @Goal + '%' OR @Goal = '' or @Goal = '0')                          
  AND (gm.Emp_ID LIKE @Emp_Name + '%' OR @Emp_Name = '' or  @Emp_Name = '0')ORDER BY Goal_Allot_ID desc                          
  select @lTotalRecords = COUNT(1) from #Temp           -- ISNULL([Emp_ID],'') as Emp_ID                  
  SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)                          
         
 --select * from #Temp        
        
 select @lResult = @lResult + '<tr>                       
  <td>' + isnull(GoalSheet_Name,'') + '</td>                           
  <td>' + isnull( CONVERT(VARCHAR,Dept_Name),'') + '</td>                          
  <td>' + isnull( CONVERT(VARCHAR,Desig_Name),'') + '</td>       
  <td>' + isnull( CONVERT(VARCHAR,Alpha_Emp_Code),'') + '</td>    
  <td>' + isnull( CONVERT(VARCHAR,Emp_Full_Name),'') + '</td>                                
  <td> '                         
  + case when IsLock = 0 then '<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Goal_Allot_ID) +')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>'else'<i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i>'end+    
  
    
      
              
 '' + case when IsLock = 0 then '<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>'else'<i class="fa fa-trash fa-lg" aria-hidden="true"></i>'end+'              
  
    
                            
 </td></tr>' from KPMS_T0020_Goal_Allotment_Master_Test as gam                     
   Inner join T0080_EMP_MASTER as em on em.Emp_ID = gam.Emp_ID                    
  Inner join T0040_DEPARTMENT_MASTER dsm on dsm.Dept_Id = em.Dept_Id                          
  Inner join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = em.Desig_ID                               
 ,#Temp where Goal_Allot_ID = rId                           
    and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid                           
                           
                    
                    
 select @lResult as Result,@lPaging as Paging                          
 END                          
 ELSE                          
 BEGIN                          
       declare @lResult6 varchar(max) = ''           
  declare @lResult3 varchar(max) =''  , @lResult4 varchar(max) ='' , @lResult5 varchar(max) ='',@type int, @levelAssignId int                   
  select @lResult3 = @lResult3 + dbo.[fnc_BindGridHeader](@Cmp_ID)                      
    
                               
  select distinct @lResult6 = @lResult6 + '<td attrLevelId="' + convert(varchar,Level_ID) + '" attrgroupid="' + convert(varchar,level_Grp_Id) + '">                                      
  <input class="form-control form-control-lg txt' + Level_Name + '" type="text" placeholder="Input" value="' + CONVERT(varchar,la_LevelValue) + '" onkeypress="isNumberKey(event);"/></td>'                                  
  FROM KPMS_T0040_Level_Master inner join tbl_LevelAssignValues on Level_ID = la_LevelId                          
  where IsActive = 1 and la_AllotmentId =   @GoalAlt_ID               
        
    
  --select * from KPMS_T0100_Level_Assign as la inner join KPMS_T0020_Goal_Master as gm on la.GoalId=gm.Goal_Id                  
  --inner join KPMS_T0110_Goal_Setting_Goal as gsg on gsg.GSG_Goal_Id=gm.Goal_ID    --add extra                
  --inner join KPMS_T0100_Goal_Setting as gs on gs.GS_Id=gsg.GSG_GoalSetting_Id       -- add extra                
  --inner join KPMS_T0020_Section_Master as sm on sm.Section_ID=la.SectionId                    
  --inner join KPMS_T0020_SubGoal_Master as subg on subg.SubGoal_ID = la.SubGoalID                    
  --inner join KPMS_T0020_Goal_Allotment_Master_Test as gam on gam.Goal_allot_ID=la.Goal_allotment_Id               
  --Where (@GoalAlt_ID = 0 Or Goal_Allot_ID=@GoalAlt_ID)        
      
      
  ---select [dbo].[fnc_BindGridData](1,1)    
  --level_assign_Id    
    
  select @lResult4 = @lResult4 +                   
  '<tr attrSectionId="' + convert(varchar,gsg.GSG_GoalSettingSection_Id) + '" attrGoalId="' + convert(varchar,gsg.GSG_Goal_Id) + '"                          
  attrSubGoalId="' + convert(varchar,gsg.GSG_Sub_Goal_Id) + '" attrMainId="' + CONVERT(varchar,gsg.GSG_Id) + '" attrGoalSettingId="' + CONVERT(varchar,GSG_GoalSetting_Id) + '"                          
  attrWeightageValue="' + CONVERT(varchar,gs.GS_WeightageValue) + '">                 
   <td>' + CONVERT(VARCHAR,Section_Name)  +'</td>                      
   <td>'+ CONVERT(VARCHAR,Goal_Name) +'</td>                    
   <td>'+ CONVERT(VARCHAR,SUBGoal_Name) +'</td>                    
   <td><select class="custom-select drpSectionWeightage">                
   <option value="0">Select Type                
   <option value="1" '+ CASE WHEN WeightageType = 1 then 'selected="selected"' ELSE '' END +'>Number</option>                
   <option value="2" '+ CASE WHEN WeightageType = 2 then 'selected="selected"' ELSE '' END +'>Percentage</option></select>'                          
   +'</td> '          
   +[dbo].[fnc_BindGridData](@GoalAlt_ID,level_assign_Id) +'                   
  <td> <input class="form-control form-control-lg" id="Targetid"  placeholder="Input" value='+ CONVERT(varchar,TargetValues)+' style="width:80px">                    
  </td>                      
  </tr>'      
                  
  from KPMS_T0100_Level_Assign as la inner join KPMS_T0020_Goal_Master as gm on la.GoalId=gm.Goal_Id                  
  inner join KPMS_T0110_Goal_Setting_Goal as gsg on gsg.GSG_Goal_Id=gm.Goal_ID    --add extra                
  inner join KPMS_T0100_Goal_Setting as gs on gs.GS_Id=gsg.GSG_GoalSetting_Id       -- add extra                
  inner join KPMS_T0020_Section_Master as sm on sm.Section_ID=la.SectionId                    
  inner join KPMS_T0020_SubGoal_Master as subg on subg.SubGoal_ID = la.SubGoalID                    
  inner join KPMS_T0020_Goal_Allotment_Master_Test as gam on gam.Goal_allot_ID=la.Goal_allotment_Id               
  Where (@GoalAlt_ID = 0 Or Goal_Allot_ID=@GoalAlt_ID)                    
  order by level_assign_Id      
    
    
  SELECT ISNULL(Goal_Setting_ID,0) AS G_Id,ISNULL([Goal_Setting_ID],'') as Goal_Allot_ID,ISNULL([Dept_ID],'') as Dept_ID, ISNULL([GoalSheet_Name],'') as GoalSheet_Name,                          
  ISNULL([Desig_ID],'') as Desig_ID, ISNULL([Emp_ID],'') as Emp_ID                 
  ,CONVERT(VARCHAR, CONVERT(varchar, Galt_Effect_Date, 103)) as Effect_Date , @lResult3  as  EditSectionResult ,@lResult4 as Griddata                    
  from KPMS_T0020_Goal_Allotment_Master_Test as gam                          
  Where (@GoalAlt_ID = 0 Or Goal_Allot_ID=@GoalAlt_ID)                          
                    
 END                          
END           
      
          
 --+</td>           
 --  +[dbo].[fnc_BindGridData](@GoalAlt_ID) +'                   
 -- <td> <input class="form-control form-control-lg" id="Targetid"  placeholder="Input" value='+ CONVERT(varchar,TargetValues)+'>                    
 -- </td> 
