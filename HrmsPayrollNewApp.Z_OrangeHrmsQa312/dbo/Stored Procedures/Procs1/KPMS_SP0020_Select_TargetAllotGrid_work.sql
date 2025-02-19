create PROCEDURE [dbo].[KPMS_SP0020_Select_TargetAllotGrid_work]                                                                                                                                                                         
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
          
		 --,[dbo].[fnc_BindFreqData](GSG_FrequecyId,'+ cast(@Emp_ID as varchar(20)) + ',la_LevelAssignId) as GSG_Frequecy   
Declare @Sql as varchar(max)              

        IF OBJECT_ID(N'tempdb..#TEMP') IS NOT NULL
		BEGIN
			DROP TABLE #TEMP
		END

		  CREATE TABLE #TEMP
		  (
			ROWID  NUMERIC(18,0),
			LA_LEVELASSIGNID  NUMERIC(18,0),
			GSG_FrequecyId  NUMERIC(18,0),
			SECTION_NAME VARCHAR(MAX),
			GOAL_NAME VARCHAR(250),
			SUBGOAL_NAME VARCHAR(250),
			la_LevelValue  VARCHAR(250),
			LEVEL_NAME VARCHAR(250),
			TARGETVALUES NUMERIC(18,0),
			WEIGHTAGETYPE VARCHAR(250),
			GSG_GOALSETTINGSECTION_ID VARCHAR(250),
			GSG_GOAL_ID VARCHAR(250),
			GSG_SUB_GOAL_ID VARCHAR(250),
			GSG_ID VARCHAR(250),
			GSG_GOALSETTING_ID VARCHAR(250)
		  )

		 --  CREATE TABLE #TEMP123
		 -- (
			--LA_LEVELASSIGNID  NUMERIC(18,0),
			--ROWID  NUMERIC(18,0),
		 -- )

			select distinct level_assign_Id,cast(ROW_NUMBER() OVER (ORDER BY level_assign_Id) as varchar(10)) as Row_Id 
			into #TEMP123 
			from KPMS_T0100_Level_Assign

		SET @Sql ='insert into #temp select                        
		 NULL,la_LevelAssignId,GSG_FrequecyId,Section_Name,Goal_Name,SubGoal_Name,level_name, B.la_LevelValue ,LA.TargetValues
		 ,cast(WeightageType as varchar(20)) as WeightageType  
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
		  And gsg.GSG_GoalSettingSection_Id= B.la_SectionId                    
		  And gsg.GSG_Sub_Goal_Id = B.la_SubGoalId                    
		  and gat.Goal_Allot_ID   = b.la_AllotmentId where Emp_ID ='+ cast(@Emp_ID as varchar(20)) + ' and sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1'

exec(@sql)

update t 
set t.ROWID = T12.Row_Id
from #temp t inner join #TEMP123 T12 on t.LA_LEVELASSIGNID = T12.level_assign_Id

Set @Sql = ''
SET @Sql ='DECLARE @Result AS varchar(MAX)
			DECLARE @Title AS varchar(MAX)                      
DECLARE @Eid AS varchar(MAX)                      
SELECT @Result = COALESCE(@Result + '' '', '''') + CONVERT(nvarchar(max), data)+ '' ''                       
From (                      
Select                       
''<tr WeightageType =''+WeightageType+'' attrSectionId =''+ GSG_GoalSettingSection_Id +'' attrGoalId='' + GSG_Goal_Id + ''  attrSubGoalId='' + GSG_Sub_Goal_Id+''  attrMainId='' +GSG_Id+'' attrGoalSettingId='' + GSG_GoalSetting_Id +'' >''+                      
''<td>''+Section_Name+ ''</td>'' +                      
''<td>''+Goal_Name +''</td>''+                      
''<td>''+SubGoal_Name +''</td>'' +'+@PivotColDedVar + '                        
+''<td>''+cast(TargetValues as varchar(20)) +''</td>''                       
+'' <td>''+ GSG_Frequecy + ''</td>''   
+''</tr>'' as data                      
FROM                       
   (             
	select LA_LEVELASSIGNID,GSG_FrequecyId,SECTION_NAME,GOAL_NAME,SUBGOAL_NAME	
	,la_LevelValue,LEVEL_NAME,TARGETVALUES,WEIGHTAGETYPE,GSG_GOALSETTINGSECTION_ID
	,GSG_GOAL_ID,GSG_SUB_GOAL_ID,GSG_ID	,GSG_GOALSETTING_ID
	,[dbo].[fnc_BindFreqData](GSG_FrequecyId,'+ cast(@Emp_ID as varchar(20)) + ',LA_LEVELASSIGNID) as GSG_Frequecy  from #temp
   ) ps                      
PIVOT                      
   ( max (la_LevelValue)    
        FOR level_name IN ('+replace(replace(Replace(replace(replace(@PivotColDedVar,'''<td>''+',''),'+''</td>''','') ,'cast( ',''),'as varchar(20))',''),'+',',') +')                      
   ) AS pvt                       
   ) as A                      
                      
   SET @Title = ''<h1><td>Section Name</td><td>Goal Name</td><td>SubGoal Name</td>'+replace(replace(replace(replace(@PivotColDedVar,'cast(',''),'as varchar(20))',''),'''',''),'+','')+'<td>Target</td><td>Frequency</td></h1>''            
          
                         
 Declare @lResult4 varchar(max) =''''                     
 Select @lResult4 = @lResult4 + GoalSheet_Name from KPMS_T0020_Goal_Allotment_Master_Test where Emp_ID='+ cast(@Emp_ID as varchar(20)) +'                     
           
  Declare @lResult6 varchar(max) =''''          
 select @lResult6 = @lResult6 +  ''<b><p class="d-block font-weight-bold name"> '' + comment + ''   -  '' + ''</b><span class="date text-black-50">'' + date + ''</span></p>'' from kpms_tblComment inner join KPMS_T0020_Goal_Allotment_Master_Test on Goal_Allot_ID = goalAlt_id where goal_Allot_ID= '+ cast(@GoalAlt_ID as varchar(20)) +'          
        
   select @Result as Result2 , @Title as Result3  ,@lResult4  as Result4 ,@lResult6  as Result6          
   '               
   --select @Sql
  exec (@Sql)                     
        
                      
END                    
--+''<td> <input class="form-control form-control-lg" id="AchiveTargetid"  placeholder="Input"> </td>''  