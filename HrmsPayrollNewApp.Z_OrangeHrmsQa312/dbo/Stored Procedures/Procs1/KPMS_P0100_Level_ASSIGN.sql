-- EXEC KPMS_P0100_Level_ASSIGN                    
-- DROP PROCEDURE KPMS_P0100_Level_ASSIGN                    
CREATE PROCEDURE [dbo].[KPMS_P0100_Level_ASSIGN]               
@rCmpId int,              
@GoalSheet_Id int,                    
@GS_Id int,                    
@rPermissionStr VARCHAR(MAX),                    
@rType INT  ,                  
@Cmp_ID Int,                  
@GoalaltId Int,                  
@GoalSheet_Name Varchar(300),                  
@Effect_date Varchar(300),                  
@Dept_ID varchar(max),                  
@Desig_ID varchar(max),                  
@Emp_Id varchar(max),                  
--@Status Varchar(300),                  
@User_ID Int,            
@rFlag int              
AS                    
BEGIN                   
 SET NOCOUNT ON;                    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                    
 SET ARITHABORT ON;                    
 SELECT @Effect_date = CASE ISNULL(@Effect_date,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Effect_date, 105), 23) END                  
                  
 declare @tblemp table(tid int identity(1,1),e_empId int,e_MainId int,IsLock int)                  
     
    
    
 If @Emp_Id <> ''                  
 BEGIN                    
       
    
  INSERT INTO [KPMS_T0020_Goal_Allotment_Master_Test]                  
  (                  
  [Cmp_ID],[Goal_Setting_ID],[GoalSheet_Name],[Galt_Effect_Date],[User_Id],[Created_Date],Emp_ID,Dept_ID,Desig_ID                  
  )                   
  ---SELECT I.Cmp_ID,@GoalaltId,@GoalSheet_Name,@Effect_date,@User_ID,GETDATE(),@Emp_Id,I.Dept_ID,I.Desig_Id                  
  SELECT I.Cmp_ID,@GoalaltId,@GoalSheet_Name,@Effect_date,@User_ID,GETDATE(),I.Emp_Id,I.Dept_ID,I.Desig_Id                  
  FROM dbo.T0080_EMP_MASTER I WITH (NOLOCK)                  
  inner join dbo.Split(@Emp_Id,',') on I.Emp_ID = Data            
  left join KPMS_T0020_Goal_Allotment_Master_Test MT on I.Emp_ID = MT.Emp_ID            
  WHERE I.CMP_ID = @Cmp_ID     
  ---AND I.Emp_Id = @Emp_Id     
  and Data <> '' and Goal_Allot_ID is null            
    
  insert into @tblemp                  
  select i.Emp_ID,Goal_Allot_ID ,IsLock from KPMS_T0020_Goal_Allotment_Master_Test i                    
  inner join dbo.Split(@Emp_Id,',') on i.Emp_ID = Data where [Goal_Setting_ID] = @GoalaltId       
        
    
 END                  
 ELSE IF @Dept_ID <> ''                  
 BEGIN                   
  INSERT INTO [KPMS_T0020_Goal_Allotment_Master_Test]                  
  (                  
  [Cmp_ID],[Goal_Setting_ID],[GoalSheet_Name],[Galt_Effect_Date],[User_Id],[Created_Date],Emp_ID,Dept_ID,Desig_ID                  
  )                   
  SELECT I.Cmp_ID,@GoalaltId,@GoalSheet_Name,@Effect_date,@User_ID,GETDATE(),I.Emp_ID,I.Dept_ID,I.Desig_Id                  
  FROM dbo.T0080_EMP_MASTER I WITH (NOLOCK)                  
  inner join dbo.Split(@Dept_ID,',') on Dept_ID = Data              
  left join KPMS_T0020_Goal_Allotment_Master_Test MT on I.Emp_ID = MT.Emp_ID            
  WHERE I.CMP_ID = @Cmp_ID and Data <> '' and Goal_Allot_ID is null                
                  
  insert into @tblemp                  
  select i.Emp_ID,Goal_Allot_ID,IsLock from KPMS_T0020_Goal_Allotment_Master_Test i                  
  inner join dbo.T0080_EMP_MASTER emp on i.Emp_ID = emp.Emp_ID                  
  inner join dbo.Split(@Dept_ID,',') on emp.Dept_ID = Data where [Goal_Setting_ID] = @GoalaltId                 
 END                  
 ELSE IF @Desig_ID <> ''                  
 BEGIN                   
  INSERT INTO [KPMS_T0020_Goal_Allotment_Master_Test]                  
  (                  
  [Cmp_ID],[Goal_Setting_ID],[GoalSheet_Name],[Galt_Effect_Date],[User_Id],[Created_Date],Emp_ID,Desig_ID,Dept_ID                  
  )                   
  SELECT I.Cmp_ID,@GoalaltId,@GoalSheet_Name,@Effect_date,@User_ID,GETDATE(),I.Emp_ID,I.Desig_Id,I.Dept_ID                  
  FROM dbo.T0080_EMP_MASTER I WITH (NOLOCK)                    
  inner join dbo.Split(@Desig_ID,',') on I.Desig_Id = Data               
  left join KPMS_T0020_Goal_Allotment_Master_Test MT on I.Emp_ID = MT.Emp_ID            
  WHERE I.CMP_ID = @Cmp_ID and Data <> '' and Goal_Allot_ID is null                     
                  
  insert into @tblemp                  
  select i.Emp_ID,Goal_Allot_ID,IsLock from KPMS_T0020_Goal_Allotment_Master_Test i                  
  inner join dbo.T0080_EMP_MASTER emp on i.Emp_ID = emp.Emp_ID                  
  inner join dbo.Split(@Desig_ID,',') on emp.Desig_Id = Data where [Goal_Setting_ID] = @GoalaltId                 
 END                  
 if @rFlag = 2              
 begin              
  update KPMS_T0020_Goal_Allotment_Master_Test set IsLock =1 from @tblemp where Goal_Allot_ID = e_MainId and Cmp_Id = @Cmp_ID            
 End            
            
      
    
    
 DECLARE @lXML XML                    
 SET @lXML = CAST(@rPermissionStr AS xml)                  
                    
 DECLARE @tbltmp TABLE                  
 (                  
 tid INT IDENTITY(1,1),MainId INT,t_GoalSettingId int,t_SectionId int,t_GoalId int,t_SubGoalId int,                  
 t_WeightageType int,t_LevelValues varchar(5000),t_LevelGrpValues varchar(5000),t_LevelAssignId int,t_TargetValues int              
 )                          
 INSERT INTO @tbltmp                    
 SELECT T.c.value('@MainId','INT') AS MainId,                    
 T.c.value('@GoalSettingId','INT') AS GoalSettingId,                    
 T.c.value('@SectionId','INT') AS SectionId,                    
 T.c.value('@GoalId','INT') AS GoalId,                    
 T.c.value('@SubGoalId','INT') AS SubGoalId,                    
 T.c.value('@WeightageType','INT') AS WeightageType,                 
 T.c.value('@LevelValues','varchar(5000)') AS LevelValues,  
 T.c.value('@LevelGrpValues','varchar(5000)') AS LevelGrpValues,0,  
 T.c.value('@TargetValues','INT') AS TargetValues            
 FROM @lXML.nodes('/Permissions/Permission') AS T(c)                    
                  
 declare @tblmain table                  
 (                  
  tid int identity(1,1),t_MainId INT,tt_GoalSettingId int,tt_SectionId int,tt_GoalId int,tt_SubGoalId int, --t_SectionName varchar(300), t_GoalName  varchar(300), t_SubGoalName  varchar(300),              
  tt_WeightageType int,tt_LevelValues varchar(5000),tt_LevelGrpValues varchar(5000),tt_LevelAssignId int,tt_MainId int,tt_TargetValues int                  
 )                  
 insert into @tblmain                  
 select MainId,t_GoalSettingId,t_SectionId,t_GoalId,t_SubGoalId,t_WeightageType,t_LevelValues,t_LevelGrpValues,t_LevelAssignId,e_MainId,t_TargetValues from @tbltmp cross apply @tblemp                  
             
-- delete w from KPMS_T0100_Level_Assign w inner join @tblmain on Goal_Allotment_Id =tt_MainId            
             
 MERGE KPMS_T0100_Level_Assign AS TARGET                    
 USING @tblmain AS SOURCE ON tt_MainId = Goal_Allotment_Id  AND SectionId =tt_SectionId and GoalId=tt_GoalId and SubGoalId = tt_SubGoalId                   
 WHEN NOT MATCHED BY TARGET THEN                            
  INSERT                    
  (                    
   GoalSettingId,SectionId,GoalId,SubGoalId,WeightageType,LevelValues,LevlGrpValues,GoalSheet_Id,Goal_Allotment_Id,TargetValues,Cmp_Id              
  )                    
  VALUES                    
  (                    
   tt_GoalSettingId,tt_SectionId,tt_GoalId,tt_SubGoalId,tt_WeightageType,tt_LevelValues,tt_LevelGrpValues,@GoalSheet_Id,tt_MainId,tt_TargetValues,@Cmp_ID                
  );                  
          
update @tblmain set tt_LevelAssignId = level_assign_Id,tt_WeightageType=WeightageType,tt_TargetValues=TargetValues   
from KPMS_T0100_Level_Assign LA inner join @tblmain TM on LA.Goal_Allotment_Id = TM.tt_MainId where GoalSettingId = tt_GoalSettingId          
and SectionId = tt_SectionId and GoalId = tt_GoalId and SubGoalId = tt_SubGoalId and GoalSheet_Id = @GoalSheet_Id and Cmp_Id = @Cmp_ID
        
 delete w from tbl_LevelAssignValues w inner join @tblmain on la_LevelAssignId = tt_LevelAssignId  and Cmp_Id = @Cmp_ID        
     
 declare @i int,@cnt int                
 select @i = 1, @cnt = COUNT(1) from @tblmain                
 while @i <= @cnt                
 begin                
  declare @LevelAssignId int = 0,@levelstr varchar(5000)='',@levelGrpstr varchar(5000)='',@SectionId int =0,@GoalId int =0,@SubGoalId int =0,@lMainId int                
  select @LevelAssignId = tt_LevelAssignId,@Sectionid=tt_SectionId,@GoalId = tt_GoalId,@SubGoalId = tt_SubGoalId,@levelstr = tt_LevelValues,@levelGrpstr = tt_LevelGrpValues,@lMainId = tt_MainId from @tblmain where tid = @i                
 
 Insert into tbl_LevelAssignValues  (la_AllotmentId,la_LevelAssignId,la_SectionId,la_GoalId,la_SubGoalId,Cmp_Id,la_LevelId,la_LevelValue,la_LvlGrpId)              

 select @lMainId,@LevelAssignId,@Sectionid,@GoalId,@SubGoalId,@Cmp_ID,val1,val2 , GrpGroup_Id FROM dbo.Split(@levelstr,',')   
 Inner Join  
  (select Left(data,CHARINDEX('-',Data)-1) as GrpGroup_Id,  
  -----Replace(replace(left(data,CHARINDEX('-',Data)+1),'-',''),' ','') as GrpLeavel_Id  
  Replace(replace(Right(data,CHARINDEX('-',Data)),'-',''),' ','') as GrpLeavel_Id  
  From [dbo].[Split](@levelGrpstr,',') WHERE data <> '' 
  ) as a  
 On Replace(Replace(left(data,CHARINDEX('-',Data)),'-',''),' ','') = GrpLeavel_Id  
 CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'-') --WHERE data <> ''    
  
  
  --insert into tbl_LevelAssignValues  (la_AllotmentId,la_LevelAssignId,la_SectionId,la_GoalId,la_SubGoalId,la_LevelId,la_LevelValue)              
  --select @lMainId,@LevelAssignId,@Sectionid,@GoalId,@SubGoalId,val1,val2 FROM dbo.Split(@levelstr,',') CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'-') WHERE data <> ''                
          
  select @LevelAssignId = 0,@levelstr = ''                
  select @i = @i + 1                
 end                
 select * from @tblmain                
END        
        
--select  * from tbl_LevelAssignValues        
--la_Id la_AllotmentId la_LevelAssignId la_LevelId la_LevelValue la_SectionId la_GoalId la_SubGoalId   
  