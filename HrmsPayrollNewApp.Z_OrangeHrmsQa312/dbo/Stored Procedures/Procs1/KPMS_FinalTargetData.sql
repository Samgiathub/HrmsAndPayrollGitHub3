CREATE PROCEDURE [dbo].[KPMS_FinalTargetData]                                                                                                                                                                         
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
      FROM KPMS_T0040_Level_Master    where  IsActive = 1 and level_Grp_Id in (1,2)  and Cmp_ID = @Cmp_ID 
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
		''<tr WeightageType =''+WeightageType+'' level_assign_Id =''+level_assign_Id+''  GSG_FrequecyId =''+GSG_FrequecyId1+'' attrSectionId =''+ GSG_GoalSettingSection_Id +'' attrGoalId='' + GSG_Goal_Id + ''  attrSubGoalId='' + GSG_Sub_Goal_Id+''  attrMainId='' +GSG_Id+'' attrGoalSettingId='' + GSG_GoalSetting_Id +'' >''+                      
		''<td>''+Section_Name+ ''</td>'' +                      
		''<td>''+Goal_Name +''</td>''+                      
		''<td>''+SubGoal_Name +''</td>''   
		+''<td>''+cast(GSG_IsDependency as varchar(20)) +''</td>''  
		+''<td>''+cast(GSG_Depend_Type_Id as varchar(20)) +''</td>'' +'+@PivotColDedVar + '  
		+''<td>''+cast(TargetValues as varchar(20)) +''</td>''       
		+''<td>''+cast(Actual_TargetValues as varchar(20)) +''</td>''    
		+'' <td>''+ GSG_Frequecy + ''</td>''                       
		+''</tr>'' as data                      
		FROM                       
		   (    select                        
		        la_LevelAssignId,Section_Name,Goal_Name,SubGoal_Name
				,case GSG_IsDependency when 0 then ''-'' else [dbo].[Fnc_Depend](GSG_Depend_Goal_Id) END as GSG_IsDependency
				,case GSG_Depend_Type_Id when 0 then ''-'' else [dbo].[Fnc_DependType](GSG_Depend_Type_Id,GSG_Depend_Goal_Id) END as GSG_Depend_Type_Id
				,level_name
				,case when la_LvlGrpId = 1 and  WeightageType = 2 then cast(B.la_LevelValue as varchar(20))  + ''%'' else  cast(B.la_LevelValue as varchar(20)) end	as la_LevelValue				
				,case GSG_Depend_Type_Id when 0 then cast(LA.TargetValues as varchar(20)) else cast(LA.TargetValues as varchar(20)) + ''%'' END as TargetValues
			    ,cast(level_assign_Id as varchar(20)) as level_assign_Id  
				,cast(WeightageType as varchar(20)) as WeightageType  
				,cast(GSG_FrequecyId as varchar(20)) as GSG_FrequecyId1  
				,cast(GSG_GoalSettingSection_Id as varchar(20)) as GSG_GoalSettingSection_Id                    
				,cast(GSG_Goal_Id as varchar(20)) as GSG_Goal_Id                    
				,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Sub_Goal_Id                    
				,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Id                    
				,cast(GSG_GoalSetting_Id as varchar(20)) as GSG_GoalSetting_Id       
				 ,[dbo].[fnc_BindFreqData](GSG_FrequecyId,'+ cast(@Emp_ID as varchar(20)) + ',la_LevelAssignId) as GSG_Frequecy   
				 ,[dbo].[Fnc_Actual_TargetValue](GSG_Goal_Id,GSG_Sub_Goal_Id,gsg.GSG_GoalSetting_Id,la.Goal_Allotment_Id) as Actual_TargetValues
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
				 and gat.Goal_Allot_ID   = b.la_AllotmentId               
				 where Emp_ID ='+ cast(@Emp_ID as varchar(20)) + ' and sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1 and a.Cmp_ID='+ cast(@Cmp_ID as varchar(20)) +' and sm.Cmp_Id ='+ cast(@Cmp_ID as varchar(20)) +'                 
		   ) ps                      
		PIVOT                      
		   ( max (la_LevelValue)    
		        FOR level_name IN ('+replace(replace(Replace(replace(replace(@PivotColDedVar,'''<td>''+',''),'+''</td>''','') ,'cast( ',''),'as varchar(20))',''),'+',',') +')                      
		   ) AS pvt                       
		   ) as A                      
		                      
		   SET @Title = ''<h1><td>Section Name</td><td>Goal Name</td><td>SubGoal Name</td><td>Depended_On</td><td>Depended_Type</td>'+replace(replace(replace(replace(@PivotColDedVar,'cast(',''),'as varchar(20))',''),'''',''),'+','')+'<td>Target</td><td>Actual_TargetValue</td><td>Frequency</td></h1>''            
		          
		                         
		 Declare @lResult4 varchar(max) =''''                     
		 Select @lResult4 = @lResult4 + GoalSheet_Name from KPMS_T0020_Goal_Allotment_Master_Test where Emp_ID='+ cast(@Emp_ID as varchar(20)) +' and Cmp_Id ='+ cast(@Cmp_ID as varchar(20)) +'                         
		           
		  Declare @lResult6 varchar(max) =''''          
		 select @lResult6 = @lResult6 +  ''<b><p class="d-block font-weight-bold name">  '' + Emp_Full_Name + ''   :  '' + comment + ''   -  '' + ''</b><span class="date text-black-50">'' + date + ''</span></p>'' from kpms_tblComment  as tc inner join KPMS_T0020_Goal_Allotment_Master_Test on Goal_Allot_ID = goalAlt_id inner join T0080_EMP_MASTER as em on em.Emp_ID = tc.Eid where goal_Allot_ID= '+ cast(@GoalAlt_ID as varchar(20)) +' and tc.Cmp_Id ='+ cast(@Cmp_ID as varchar(20)) +'         
		     
		   select @Result as Result2 , @Title as Result3  ,@lResult4  as Result4 ,@lResult6  as Result6          
   '               
   --select @Sql
  exec (@Sql)                     
        
                      
END                    
