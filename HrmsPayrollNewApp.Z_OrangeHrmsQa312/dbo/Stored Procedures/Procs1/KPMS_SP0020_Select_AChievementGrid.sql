CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_AChievementGrid]                           
(                          
 @Cmp_ID INT,                         
 @Emp_ID int,                    
 @GoalAlt_ID INT,                          
 @GS_Id Int = NULL,                          
 @Goal varchar(5) = NULL,                          
 @rPageIndex INT,                          
 @rPageSize INT,                          
 @rSortBy VARCHAR(100)                          
)                          
as                          
BEGIN                          
                  
declare @PivotColDedVar as NVARCHAR(MAX)                              
    Select @PivotColDedVar = List_Output  --+ ' , ' + '[Total_Int]'                               
    from (     SELECT  STUFF((SELECT '  ''<td>''+ cast( ' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_') + ' as varchar(20))+''</td>''+'                      
      FROM KPMS_T0040_Level_Master    where  IsActive = 1 and level_Grp_Id in (1,2)  
      FOR XML PATH(''), TYPE)                              
      .value('.','NVARCHAR(MAX)'),1,2,' ') List_Output                            
    )  as T                     
 SET @PivotColDedVar = left(@PivotColDedVar,len(@PivotColDedVar)-1)                    
           
         
        
                    
Declare @Sql as varchar(max)                 
        
SET @Sql =                     
'                     
DECLARE @Result AS varchar(MAX)                    
DECLARE @Title AS varchar(MAX)                    
DECLARE @Eid AS varchar(MAX)                    
                  
                  
SELECT @Result = COALESCE(@Result + '' '', '''') + CONVERT(nvarchar(max), data)+ '' ''                     
From (                    
Select                     
''<tr attrSectionId =''+ GSG_GoalSettingSection_Id +'' attrGoalId='' + GSG_Goal_Id + ''  attrSubGoalId='' + GSG_Sub_Goal_Id+''  attrMainId='' +GSG_Id+'' attrGoalSettingId='' + GSG_GoalSetting_Id +'' >''+                    
''<td>''+Alpha_Emp_Code+''</td>''+
''<td>''+Emp_Full_Name+ ''</td>'' +  
''<td>''+Section_Name+ ''</td>'' +  
''<td>''+Section_Name+ ''</td>'' +                    
''<td>''+Goal_Name +''</td>''+                    
''<td>''+SubGoal_Name +''</td>'' +'+@PivotColDedVar + '                      
+''<td>''+cast(TargetValues as varchar(20)) +''</td>''                    
+''<td> <input class="form-control form-control-lg" id="AchiveTargetid"  placeholder="Input"> </td>''                     
+''</tr>'' as data                    
FROM                     
   (  select                      
     la_LevelAssignId,Alpha_Emp_Code,Emp_Full_Name,Section_Name,Goal_Name,SubGoal_Name,level_name, B.la_LevelValue ,LA.TargetValues                   
  ,cast(GSG_GoalSettingSection_Id as varchar(20)) as GSG_GoalSettingSection_Id                  
  ,cast(GSG_Goal_Id as varchar(20)) as GSG_Goal_Id                  
  ,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Sub_Goal_Id                  
  ,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Id                  
  ,cast(GSG_GoalSetting_Id as varchar(20)) as GSG_GoalSetting_Id                   
   from KPMS_T0040_Level_Master as A                    
   Inner Join tbl_LevelAssignValues as B On A.Level_ID = B.la_LevelId                     
   Inner Join  KPMS_T0020_Goal_Master as gm  On gm.Goal_ID = B.la_GoalId                           
   inner join KPMS_T0020_Section_Master as sm on sm.Section_ID  = B.la_SectionId                         
   inner join KPMS_T0020_SubGoal_Master as ssm on ssm.SubGoal_ID   = B.la_SubGoalId                           
   inner join  KPMS_T0100_Level_Assign  as LA On LA.level_assign_Id = B.la_LevelAssignId                    
   and b.la_AllotmentId = la.Goal_Allotment_Id                  
                  
   inner join KPMS_T0110_Goal_Setting_Goal as gsg on gsg.GSG_Goal_Id= B.la_GoalId                     
   inner join KPMS_T0020_Goal_Allotment_Master_Test gat on gat.Goal_Setting_ID=gsg.GSG_GoalSetting_Id        
      inner join T0080_EMP_MASTER em on em.Emp_ID = gat.Emp_ID
   And gsg.GSG_GoalSettingSection_Id= B.la_SectionId                  
   And gsg.GSG_Sub_Goal_Id = B.la_SubGoalId                  
   and gat.Goal_Allot_ID   = b.la_AllotmentId             
                     
                  
 where gat.Emp_ID ='+ cast(@Emp_ID as varchar(20)) + ' and sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1                   
   ) ps                    
PIVOT                    
   ( max (la_LevelValue)  
        FOR level_name IN ('+replace(replace(Replace(replace(replace(@PivotColDedVar,'''<td>''+',''),'+''</td>''','') ,'cast( ',''),'as varchar(20))',''),'+',',') +')                    
   ) AS pvt                     
   ) as A                    
                    
   SET @Title = ''<h1><td>Alpha_Emp_Code</td><td>Name</td><td>Section Name</td><td>Goal Name</td><td>SubGoal Name</td>'+replace(replace(replace(replace(@PivotColDedVar,'cast(',''),'as varchar(20))',''),'''',''),'+','')+'<td>Target</td><td>Achivement</td></h1>''                    
                    
   select @Result as Result2     
   '                    
  exec (@Sql)                   
      
                    
END                      
        
