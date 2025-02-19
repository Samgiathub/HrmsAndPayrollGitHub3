CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_ApprovalTargetGrid]                             
(                            
 @Cmp_ID INT,               
 @GoalAlt_ID INT,             
 @Emp_ID int                
)                            
as                            
BEGIN                      
    declare @PivotColDedVar as NVARCHAR(MAX)                                
    Select @PivotColDedVar = List_Output                                  
    from (     SELECT  STUFF((SELECT '  ''<td>''+ cast( ' + Replace(CAST(Level_Name AS VARCHAR(100)),' ','_') + ' as varchar(20))+''</td>''+'                        
      FROM KPMS_T0040_Level_Master   where  cmp_id = @Cmp_ID and IsActive = 1  FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,2,' ') List_Output                              
    )  as T                       
    SET @PivotColDedVar = left(@PivotColDedVar,len(@PivotColDedVar)-1)                      
                   
   --select [dbo].[fnc_LevelAchi](1,1,1,1,21162)  
  
   Declare @Sql as varchar(max)                      
   SET @Sql =                       
   '                       
   DECLARE @Result AS varchar(MAX)                      
   DECLARE @Title AS varchar(MAX)                      
                    
   SELECT @Result = COALESCE(@Result + '' '', '''') + CONVERT(nvarchar(max), data)+ '' ''                       
   From (                      
   Select                       
''<tr WeightageType =''+WeightageType+'' GSG_FrequecyId =''+GSG_FrequecyId1+'' attrSectionId =''+ GSG_GoalSettingSection_Id +'' attrGoalId='' + GSG_Goal_Id + ''  attrSubGoalId='' + GSG_Sub_Goal_Id+''  attrMainId='' +GSG_Id+'' attrGoalSettingId='' + GSG_GoalSetting_Id +'' >''+                      
   ''<td>''+Section_Name+ ''</td>'' +                      
   ''<td>''+Goal_Name +''</td>''+                      
   ''<td>''+SubGoal_Name +''</td>''
   +''<td>''+cast(GSG_IsDependency as varchar(20)) +''</td>''  
   +''<td>''+cast(GSG_Depend_Type_Id as varchar(20)) +''</td>''
   +'+@PivotColDedVar + '                        
    +''<td>''+cast(TargetValues as varchar(20)) +''</td>''                          
	  +''<td>''+ GSG_Frequecy +''</td>''      
		+''<td>''+ GSG_FrequecyTotal +''</td>''      
    	+''<td>''+ GSG_FrequecyPerTotal +''</td>''    
		+''<td>''+ LevelAchi +''</td>''      
	   +''<td>''+ Score +''</td>''      

     +''</tr>'' as data                      
   FROM                       
      (  select                        
      la_LevelAssignId,Section_Name,Goal_Name,SubGoal_Name
	  ,case GSG_IsDependency when 0 then ''-'' else [dbo].[Fnc_Depend](GSG_Depend_Goal_Id) END as GSG_IsDependency
	  ,case GSG_Depend_Type_Id when 0 then ''-'' else [dbo].[Fnc_DependType](GSG_Depend_Type_Id,GSG_Depend_Goal_Id) END as GSG_Depend_Type_Id
	  ,level_name, B.la_LevelValue ,LA.TargetValues                  
     ,cast(tach.WeightageType as varchar(20)) as WeightageType  
	,cast(GSG_FrequecyId as varchar(20)) as GSG_FrequecyId1  
	 ,cast(GSG_GoalSettingSection_Id as varchar(20)) as GSG_GoalSettingSection_Id                    
     ,cast(GSG_Goal_Id as varchar(20)) as GSG_Goal_Id                    
     ,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Sub_Goal_Id                    
     ,cast(GSG_Sub_Goal_Id as varchar(20)) as GSG_Id                    
     ,cast(GSG_GoalSetting_Id as varchar(20)) as GSG_GoalSetting_Id           
	,[dbo].[fnc_BindFreqData](GSG_FrequecyId,'+ cast(@Emp_ID as varchar(20)) + ',la_LevelAssignId) as GSG_Frequecy   
	,[dbo].[fnc_BindFreqTotal]('+ cast(@Emp_ID as varchar(20)) + ',tach.TargetAchiveid) as GSG_FrequecyTotal     
   ,[dbo].[fnc_BindFreqPercentageTotal]('+ cast(@Emp_ID as varchar(20)) + ',tach.TargetAchiveid) as GSG_FrequecyPerTotal     
	,[dbo].[fnc_LevelAchi](GSG_FrequecyId,la_LevelAssignId,la_AllotmentId,'+ cast(@Emp_ID as varchar(20)) + ','+cast(@Cmp_ID as varchar(20))+') as LevelAchi  
	,[dbo].[fnc_AppraisalScore](GSG_FrequecyId,la_LevelAssignId,la_AllotmentId,'+ cast(@Emp_ID as varchar(20)) + ') as Score  
      from KPMS_T0040_Level_Master as A                      
      Inner Join tbl_LevelAssignValues as B On A.Level_ID = B.la_LevelId                       
      Inner Join  KPMS_T0020_Goal_Master as gm  On gm.Goal_ID = B.la_GoalId                             
      inner join KPMS_T0020_Section_Master as sm on sm.Section_ID  = B.la_SectionId                           
      inner join KPMS_T0020_SubGoal_Master as ssm on ssm.SubGoal_ID   = B.la_SubGoalId                             
      inner join  KPMS_T0100_Level_Assign  as LA On LA.level_assign_Id = B.la_LevelAssignId           
  and b.la_AllotmentId = la.Goal_Allotment_Id                    
                    
      inner join KPMS_T0110_Goal_Setting_Goal as gsg on gsg.GSG_Goal_Id= B.la_GoalId                       
      inner join KPMS_T0020_Goal_Allotment_Master_Test gat on gat.Goal_Setting_ID=gsg.GSG_GoalSetting_Id                       
      inner join KPMS_T0110_TargetAchivement tach on tach.targetvalue = La.TargetValues            
      And gsg.GSG_GoalSettingSection_Id= B.la_SectionId                    
      And gsg.GSG_Sub_Goal_Id = B.la_SubGoalId                    
      and gat.Goal_Allot_ID   = b.la_AllotmentId                     
       
                       
                    
    where gat.Emp_ID ='+ cast(@Emp_ID as varchar(20)) + ' and sm.IsActive=1 and gm.IsActive = 1 and ssm.IsActive = 1 and A.cmp_id ='+ cast(@Cmp_ID as varchar(20)) + '                    
      ) ps                    
   PIVOT                      
      ( max (la_LevelValue)                      
     FOR level_name IN ('+replace(replace(Replace(replace(replace(@PivotColDedVar,'''<td>''+',''),'+''</td>''','') ,'cast( ',''),'as varchar(20))',''),'+',',') +')                      
      ) AS pvt                       
      ) as A                      
                      
      SET @Title = ''<h1><td>Section Name</td><td>Goal Name</td><td>SubGoal Name</td><td>Depended_On</td><td>Depended_Type</td>'+replace(replace(replace(replace(@PivotColDedVar,'cast(',''),'as varchar(20))',''),'''',''),'+','')+'<td>Target</td><td>Achievement</td><td>Actual</td><td>Actual%</td><td>Level Achi.</td><td>Score</td></h1>''             
    
           
    Declare @lResult4 varchar(max) =''''  ,@lSatusResult varchar(MAX) = ''''                   
    Select @lResult4 = @lResult4 + GoalSheet_Name from KPMS_T0020_Goal_Allotment_Master_Test where Emp_ID='+ cast(@Emp_ID as varchar(20)) +'                     
                  
    --- select @ShortFall = @ShortFall + (targetvalue-Achivement) from KPMS_T0110_TargetAchivement where Emp_ID = @Emp_ID                   
                   
    SELECT @lSatusResult = ''<option value="0"> -- Select -- </option>''                  
    SELECT @lSatusResult = @lSatusResult + ''<option value="'' + CONVERT(VARCHAR,Appr_Status_ID) + ''"> ''+Status_Name+''</option>''                  
    FROM kpms_Approve_Status WITH(NOLOCK)                     
                    
   Declare @lResult6 varchar(max) =''''                 
           
   select @lResult6 = @lResult6 +  ''<b><p class="d-block font-weight-bold name"> '' + comment + ''   -  '' + ''</b><span class="date text-black-50">'' + date + ''</span></p>'' from kpms_tblComment as com inner join KPMS_T0020_Goal_Allotment_Master_Test on Goal_Allot_ID = goalAlt_id where goal_Allot_ID= '+ cast(@GoalAlt_ID as varchar(20)) +' and com.Cmp_Id ='+ cast(@Cmp_ID as varchar(20)) + '
          
      select @Result as Result2 , @Title as Result3  ,@lResult4  as Result4, @lSatusResult as SatusResult , @lResult6  as Result6                   
      '                      
     exec (@Sql)                     
                     
    select Emp_Full_Name as Name,isnull(Dept_Name,'') as Dept_Name,isnull(Branch_Name,'N/A') as Branch_Name,isnull(Desig_Name,'N/A') as Desig_Name from                    
    T0080_EMP_MASTER as em                    
    iNNER join T0040_DESIGNATION_MASTER as ds on ds.Desig_Id = em.Desig_Id                        
    Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON bm.BRANCH_ID = em.BRANCH_ID                      
    lEFT JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON em.Dept_Id = DT.Dept_Id                       
    INNER JOIN T0010_COMPANY_MASTER cm With(noLock) on cm.Cmp_Id=em.Cmp_ID                     
    where em.Emp_ID=@Emp_ID and em.Cmp_ID=@Cmp_ID                  
END       
  
-- ,[dbo].[fnc_BindFreqPercentageTotal]('+ cast(@Emp_ID as varchar(20)) + ',tach.TargetAchiveid,GSG_Goal_Id,la_LevelAssignId,'+cast(@Cmp_ID as varchar(20))+') as GSG_FrequecyPerTotal     

