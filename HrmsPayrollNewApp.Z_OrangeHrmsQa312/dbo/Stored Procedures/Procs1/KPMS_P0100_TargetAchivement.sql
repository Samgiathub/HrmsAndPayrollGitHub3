CREATE PROCEDURE [dbo].[KPMS_P0100_TargetAchivement]            
@rCmpId int,                  
@GoalSheet_Id int,                  
@goalAlt_id int,          
@GS_Id int,                        
@rPermissionStr VARCHAR(MAX),     
@rType INT ,              
@Emp_ID INT,              
@Cmp_ID int,              
@User_ID Int      
--@id int
AS            
BEGIN            
 SET NOCOUNT ON;            
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;            
 SET ARITHABORT ON;            
            
                
 DECLARE @RM VARCHAR(MAX)='' ,@Scheme_ID varchar(max)=''             
            
  Select @RM = @RM + convert(varchar,R_Emp_ID) FROM T0090_EMP_REPORTING_DETAIL  R inner join (              
     SELECT Max(effect_date) AS Effect_Date              
     FROM   T0090_EMP_REPORTING_DETAIL               
     WHERE  effect_date <= Getdate() AND Emp_ID = @Emp_ID               
     ) Q on q.Effect_Date = r.Effect_Date              
     and Emp_ID = @Emp_ID              
            
 select @Scheme_ID = @Scheme_ID +  convert(varchar,Scheme_ID)  from V0095_EMP_SCHEME where Scheme_Type = 'GOAL' and Effective_Date = (select max(Effective_Date) from V0095_EMP_SCHEME where Scheme_Type ='GOAL' and Emp_ID = @Emp_ID)             
        
 BEGIN            
  IF ISNULL(@Scheme_ID,'') = ''            
    Begin                
   select -101         
  -- Raiserror('@@Scheme is not apply to this Employee',18,2)        
     return            
    End                 
             
 Else            
	--DROP TABLE IF EXISTS #tbltmp
 -- DROP TABLE IF EXISTS #temp2


	   DECLARE @lXML XML            
	   SET @lXML = CAST(@rPermissionStr AS xml)            
            
	   DECLARE @tbltmp TABLE            
	   (            
		 tid INT IDENTITY(1,1),t_SectionId int,t_GoalId int,t_SubGoalId int,t_TargetValues varchar(5000),t_freqid int,t_WeightageType int
		 , t_levelAssignid int,t_Ach int,t_month varchar(5000),t_monthNum varchar(5000) ,T_Level numeric,t_GoalSettingId int   --,goalAltId int            
	   )  

	   INSERT INTO @tbltmp            
	   SELECT            
		T.c.value('@SectionId','INT'),         
		T.c.value('@GoalId','INT'),            
		T.c.value('@SubGoalId','INT'),
		T.c.value('@TargetValues','varchar(5000)'),      
		T.c.value('@Frequency_Id','INT') ,
		T.c.value('@weightagetype','INT'),
		T.c.value('@levelAssignid','INT'),
		T.c.value('@Achivement','INT')    
		,T.c.value('@Month','varchar(5000)')
		,T.c.value('@Month_Num','varchar(5000)')
		,T.c.value('@lv','int')
		,T.c.value('@GoalSettingId','int')
		FROM @lXML.nodes('/Permissions/Permission') AS T(c)                  
		MERGE KPMS_T0110_TargetAchivement AS TARGET            
		USING @tbltmp AS SOURCE ON levelAssignid = t_levelAssignid and Cmp_Id = @Cmp_ID  and Month = t_month
		WHEN MATCHED THEN            
		UPDATE SET Achievement = t_ach 
		WHEN NOT MATCHED BY TARGET THEN                            
		INSERT            
		(            
		 SectionId,GoalId,SubGoalId,targetvalue,Freq_id,emp_id,R_Emp_ID,Scheme_ID,goalAlt_id,WeightageType,levelAssignid,Month,Achievement,Actual_Target,Cmp_Id,Month_Num,goal_setting_ID 
		)            
		VALUES            
		(           
		 t_SectionId,t_GoalId,t_SubGoalId,t_TargetValues,t_freqid,@Emp_ID,@RM,@Scheme_ID,@goalAlt_id,t_WeightageType,t_levelAssignid,t_month,t_Ach,t_Level,@Cmp_ID,t_monthNum,t_GoalSettingId
		);

		--select t_monthNum from @tbltmp

	   create table #tbltmp 
	   (            
		 tid INT IDENTITY(1,1),t_SectionId int,t_GoalId int,t_SubGoalId int,t_TargetValues varchar(5000),t_freqid int,t_WeightageType int, t_levelAssignid int,t_Ach int
		 ,t_month varchar(5000),t_GoalSettingId int,t_monthNum varchar(5000) --,t_acho int --,goalAltId int           
		 ,T_Level numeric
	   )            
	   INSERT INTO #tbltmp            
	   SELECT            
		T.c.value('@SectionId','INT'),         
		T.c.value('@GoalId','INT'),            
		T.c.value('@SubGoalId','INT'),
		T.c.value('@TargetValues','varchar(5000)'),      
		T.c.value('@Frequency_Id','INT') ,
		T.c.value('@weightagetype','INT'),
		T.c.value('@levelAssignid','INT'),
		T.c.value('@Achivement','INT')    
		,T.c.value('@Month','varchar(5000)')
		,T.c.value('@GoalSettingId','int')
		,T.c.value('@Month_Num','varchar(5000)')	
		,0 as Lev
		FROM @lXML.nodes('/Permissions/Permission') AS T(c) 
			
			--select t_monthNum from #tbltmp

		select distinct t_SectionId,	t_GoalId,	t_SubGoalId,	t_TargetValues,	t_freqid,	t_WeightageType,	t_levelAssignid,	t_Ach,	t_month ,t_monthNum,t_GoalSettingId
		,[dbo].[Fnc_Actual_TargetValue](t_GoalId,t_SubGoalId,t_GoalSettingId,@goalAlt_id) as t_Level
		into #temp2
		From #tbltmp T 
		inner join KPMS_T0110_TargetAchivement jt on t.t_levelAssignid = jt.levelAssignid  
		MERGE KPMS_T0110_TargetAchivement AS jt            
		USING #temp2 AS SOURCE ON t_levelAssignid = jt.levelAssignid and Cmp_Id = @Cmp_ID
		WHEN MATCHED THEN            
		UPDATE SET  Actual_Target = t_Level 
		   WHEN NOT MATCHED BY TARGET THEN                            
		INSERT            
		(            
		 SectionId,GoalId,SubGoalId,targetvalue,Freq_id,emp_id,R_Emp_ID,Scheme_ID,goalAlt_id,WeightageType,levelAssignid,Month,Achievement,Actual_Target,Cmp_Id,Month_Num,goal_setting_ID
		)            
		VALUES            
		(           
		 t_SectionId,t_GoalId,t_SubGoalId,t_TargetValues,t_freqid,@Emp_ID,@RM,@Scheme_ID,@goalAlt_id,t_WeightageType,t_levelAssignid,t_month,t_Ach,t_Level,@Cmp_ID,t_monthNum,t_GoalSettingId
		);
		
		--select * from #temp2
		
	END             
       select 1 as result;    
END


