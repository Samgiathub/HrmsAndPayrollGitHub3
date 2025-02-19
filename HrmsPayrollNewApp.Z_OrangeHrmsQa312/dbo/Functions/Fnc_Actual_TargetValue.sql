CREATE function [dbo].[Fnc_Actual_TargetValue](@GSGGOALID int,@GSG_Sub_GOALID int,@GSG_GOALSETTING_ID int,@Goal_Allotment_Id int)          
returns varchar(max)          
as          
BEGIN        
		DECLARE @DEPENDEND INT,@D_Type INT,@Freq_Id INT,@Dpend_Goalid INT,@TargetValue INT,@DEPTARGETVALUE INT,@ISDEPENDED INT,@Month_Num VARCHAR(300),@ACHIEVEMENT INT,@COUNTGOALID INT
		DECLARE @Actual_TargetValue INT
		select @Month_Num = MONTH(DATEADD(MM,-1,GETDATE()))
		DECLARE @DEP_TMP2 TABLE(RN INT,GID INT,SUB_GID INT,D_GID INT,TARGETVAL INT,D_Type INT,FREQ_ID INT)
		DECLARE @DEP_TMP3 TABLE(RN INT,GID INT,SUB_GID INT,D_GID INT,ACHIEVEMENT INT,D_Type INT,FREQ_ID INT)

		SELECT @D_Type = GSG_Depend_Type_Id FROM KPMS_T0110_Goal_Setting_Goal WHERE GSG_GOAL_ID = @GSGGOALID and GSG_GoalSetting_Id =@GSG_GOALSETTING_ID 
		SELECT @TargetValue	= TargetValues FROM KPMS_T0100_Level_Assign WHERE GOALID = @GSGGOALID and Goal_Allotment_Id = @Goal_Allotment_Id AND SUBGOALID = @GSG_Sub_GOALID 		
		SELECT @Freq_Id	= GSG_FrequecyId FROM KPMS_T0110_Goal_Setting_Goal WHERE GSG_GOAL_ID = @GSGGOALID and GSG_GoalSetting_Id = @GSG_GOALSETTING_ID 
		SELECT @ISDEPENDED = GSG_IsDependency FROM KPMS_T0110_Goal_Setting_Goal WHERE GSG_GOAL_ID = @GSGGOALID and GSG_GoalSetting_Id = @GSG_GOALSETTING_ID AND GSG_Sub_Goal_Id = @GSG_Sub_GOALID 
		SELECT @Dpend_Goalid = GSG_DEPEND_GOAL_ID FROM KPMS_T0110_GOAL_SETTING_GOAL WHERE GSG_GOAL_ID = @GSGGOALID AND GSG_GOALSETTING_ID = @GSG_GOALSETTING_ID
		SELECT @DEPTARGETVALUE = TARGETVALUES FROM KPMS_T0100_LEVEL_ASSIGN WHERE GOALID = @Dpend_Goalid AND GOAL_ALLOTMENT_ID = @Goal_Allotment_Id
		SELECT @COUNTGOALID = Count(GSG_Goal_Id) from KPMS_T0110_Goal_Setting_Goal where GSG_Goal_Id = @Dpend_Goalid and GSG_GoalSetting_Id = @GSG_GOALSETTING_ID
		
		IF(@ISDEPENDED = 1)
		BEGIN		
		 IF(@COUNTGOALID > 1)
			BEGIN
					IF(@D_Type = 1)-- TARGET
						BEGIN					
								INSERT INTO @DEP_TMP2
								SELECT 1,GSG_Goal_Id,GSG_Sub_Goal_Id,@Dpend_Goalid,((TargetValues) * CAST(@TargetValue AS NUMERIC(18,2))/100),@D_Type,@Freq_Id 
								from  KPMS_T0110_Goal_Setting_Goal AS GSG inner join KPMS_T0100_Level_Assign as la on la.SubGoalId =  gsg.GSG_Sub_Goal_Id AND Goal_Allotment_Id = @Goal_Allotment_Id AND GoalSettingId = @GSG_GOALSETTING_ID
								WHERE GSG_Goal_Id = @Dpend_Goalid 

								SELECT @Actual_TargetValue = sum(TARGETVAL) FROM @DEP_TMP2
						END
					ELSE -- ACHIEVEMENT
						BEGIN	
								SELECT @ACHIEVEMENT = ACHIEVEMENT FROM KPMS_T0110_TARGETACHIVEMENT WHERE MONTH_NUM = @MONTH_NUM AND GOALID = @Dpend_Goalid and goalAlt_id = @Goal_Allotment_Id --AND subgoalid = @GSG_Sub_GOALID

								INSERT INTO @DEP_TMP3
								SELECT 1,gsg.goalid,gsg.subgoalid,@Dpend_Goalid,((Achievement) * CAST(@TargetValue AS NUMERIC(18,2))/100),@D_Type,@Freq_Id 
								from  KPMS_T0110_TARGETACHIVEMENT AS GSG inner join KPMS_T0100_Level_Assign as la on la.SubGoalId =  gsg.subgoalid AND Goal_Allotment_Id = @Goal_Allotment_Id AND GoalSettingId = @GSG_GOALSETTING_ID
								WHERE gsg.goalid = @Dpend_Goalid 

									 --set @Actual_TargetValue = CASE WHEN @ACHIEVEMENT IS NULL THEN @TargetValue else (SELECT sum(ACHIEVEMENT) FROM @DEP_TMP3)  end

								SELECT @Actual_TargetValue = sum(ACHIEVEMENT) FROM @DEP_TMP3
						END				
			END --IF(@COUNTGOALID > 0)
		ELSE
			BEGIN
					IF(@D_Type = 1)-- TARGET
						BEGIN				
							SET @Actual_TargetValue =  (@DEPTARGETVALUE) * CAST(@TargetValue AS NUMERIC(18,2))/100 
						END
					ELSE -- ACHIEVEMENT
						BEGIN
							SELECT @ACHIEVEMENT = ACHIEVEMENT FROM KPMS_T0110_TARGETACHIVEMENT WHERE MONTH_NUM = @MONTH_NUM AND GOALID = @Dpend_Goalid and goalAlt_id = @Goal_Allotment_Id --AND subgoalid = @GSG_Sub_GOALID 
							SET @DEPTARGETVALUE = @ACHIEVEMENT
							set @Actual_TargetValue = CASE WHEN @ACHIEVEMENT IS NULL THEN @TargetValue  else  (@DEPTARGETVALUE) * CAST(@TargetValue AS NUMERIC(18,2))/100  end
							--SET @Actual_TargetValue =  (@DEPTARGETVALUE) * CAST(@TargetValue AS NUMERIC(18,2))/100 
						END				
			END ----ELSE(@COUNTGOALID > 0)
			END --IF(@ISDEPENDED = 1)
		ELSE --(IF NOT DEPENDED)
			BEGIN
					SET @Actual_TargetValue =  @TargetValue 
			END
	return  @Actual_TargetValue
END   

