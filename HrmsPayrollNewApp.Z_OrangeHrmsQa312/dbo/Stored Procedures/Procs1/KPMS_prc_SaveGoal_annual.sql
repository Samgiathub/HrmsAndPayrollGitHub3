-- exec KPMS_prc_SaveGoal
-- drop proc KPMS_prc_SaveGoal
CREATE procedure [dbo].[KPMS_prc_SaveGoal_annual]
@GoalsettingID int,
@rCmpId int,
@rUserId int,
@rFromDate varchar(50),
@rToDate varchar(50),
@rSheetName varchar(300),
@rWeightageType int,
@rWeightageVal int,
@rStatus int,
@rSilverMin float,
@rSilverMax float,
@rGoldMin float,
@rGoldMax float,
@rPlatinumMin float,
@rPlatinumMax float,
@rRoyalPlatinumMin float,
@rRoyalPlatinumMax float,
@rPermissionStr varchar(max),
@rFlag int
as
begin
	DECLARE @lXML XML,@lGoalSettingId INT,@lGoalSettingSecId INT
	SET @lXML = CAST(@rPermissionStr AS xml)

	SELECT @rFromDate = CASE ISNULL(@rFromDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rFromDate, 105), 23) END
	SELECT @rToDate = CASE ISNULL(@rToDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rToDate, 105), 23) END

	DECLARE @tbltmp TABLE
	(
		tid INT IDENTITY(1,1),t_SectionId INT,t_SectionWeightageValue INT,t_GoalId INT,t_SubGoalId INT,t_GoalFrequecyId INT,t_GoalWeightageValue INT,
		t_GoalDependency BIT,t_GoalDependId INT,t_GoalTypeId INT,t_GoalSettingId INT,t_GoalSettingSectionId INT
	)
	INSERT INTO @tbltmp select
	T.c.value('@sid','INT') AS sid,
	T.c.value('@swv','INT') AS swv,
	T.c.value('@gid','INT') AS gid,
	T.c.value('@gsid','INT') AS sgid,
	T.c.value('@gfreq','INT') AS gfreq,
	T.c.value('@gwv','INT') AS gwv,
	T.c.value('@gdp','bit') AS gdp,
	T.c.value('@dgid','INT') AS dgid,
	T.c.value('@dtyp','INT') AS dtyp,
	0,0
	FROM @lXML.nodes('/Permissions/Permission') AS T(c)
	
	if not exists (select 1 from KPMS_T0100_Goal_Setting where GS_FromDate = @rFromDate and GS_ToDate = @rToDate and Cmp_Id = @rCmpId and IsLock = 0 )
	begin
		INSERT INTO KPMS_T0100_Goal_Setting
		(
			GS_SheetName,GS_FromDate,GS_ToDate,GS_WeightageTypeId,GS_WeightageValue,GS_StatusId,Cmp_Id
		)
		select @rSheetName,@rFromDate,@rToDate,@rWeightageType,@rWeightageVal,@rStatus,@rCmpId
		select @lGoalSettingId = SCOPE_IDENTITY()
	end
	else
	begin
		select @lGoalSettingId = GS_Id from KPMS_T0100_Goal_Setting where GS_FromDate = @rFromDate and GS_ToDate = @rToDate and Cmp_Id = @rCmpId
	end
	

	update @tbltmp set t_GoalSettingId = @lGoalSettingId
	if @rFlag = 2
	begin
		update KPMS_T0100_Goal_Setting set IsLock = 1,IsDraft = 0 where GS_Id = @lGoalSettingId
	end
	else if @rFlag = 3
	begin
		update KPMS_T0100_Goal_Setting set IsDraft = 1 where GS_Id = @lGoalSettingId
	end
	
	MERGE KPMS_T0110_Goal_Setting_Section AS TARGET
	USING @tbltmp AS SOURCE ON GSS_Goal_Setting_Id = @lGoalSettingId and Cmp_Id = @rCmpId and GSS_SectionId = t_SectionId
	WHEN MATCHED THEN
		UPDATE SET  GSS_SectionId = t_SectionId,GSS_WeightageValue = t_SectionWeightageValue 
	WHEN NOT MATCHED BY TARGET THEN
	INSERT 
	(
		GSS_Goal_Setting_Id,GSS_SectionId,GSS_WeightageValue,Cmp_Id
	)
	VALUES
	(
		@lGoalSettingId,t_SectionId,t_SectionWeightageValue,@rCmpId
	);

	---select @lGoalSettingSecId = GSS_Id from KPMS_T0110_Goal_Setting_Section where GSS_Goal_Setting_Id = @lGoalSettingId

	MERGE KPMS_T0110_Goal_Setting_Goal AS TARGET
	USING @tbltmp AS SOURCE ON GSG_GoalSetting_Id = @lGoalSettingId and Cmp_Id = @rCmpId 
	WHEN MATCHED THEN
		UPDATE SET GSG_GoalSettingSection_Id = t_GoalSettingSectionId,GSG_Goal_Id = t_GoalId,GSG_Sub_Goal_Id=t_SubGoalId,GSG_WeightageValue = t_GoalWeightageValue,
		GSG_IsDependency = t_GoalDependency,GSG_Depend_Goal_Id = t_GoalDependId,GSG_Depend_Type_Id = t_GoalTypeId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			GSG_GoalSetting_Id,GSG_GoalSettingSection_Id,GSG_Goal_Id,GSG_Sub_Goal_Id,GSG_FrequecyId,GSG_WeightageValue,GSG_IsDependency,
			GSG_Depend_Goal_Id,GSG_Depend_Type_Id,Cmp_Id
		)
		VALUES
		(
			@lGoalSettingId,t_SectionId,t_GoalId,t_SubGoalId,t_GoalFrequecyId,t_GoalWeightageValue,t_GoalDependency,
			t_GoalDependId,t_GoalTypeId,@rCmpId
		);
	
	if not exists(select 1 from KPMS_T0110_GoalSettingScore where GSB_GoalSettingId = @lGoalSettingId)
	begin
		INSERT INTO KPMS_T0110_GoalSettingScore
		(
			GSB_GoalSettingId,GSB_Title,GSB_Min,GSB_Max	
		)
		select @lGoalSettingId,'Silver',@rSilverMin,@rSilverMax

		union all

		select @lGoalSettingId,'Gold',@rGoldMin,@rGoldMax

		union all

		select @lGoalSettingId,'Platinum',@rPlatinumMin,@rPlatinumMax

		union all

		select @lGoalSettingId,'Royal Platinum',@rRoyalPlatinumMin,@rRoyalPlatinumMax
	end
	else
	begin
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rSilverMin,GSB_Max = @rSilverMax,Cmp_Id = @rCmpId where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Silver' and Cmp_Id = @rCmpId
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rGoldMin,GSB_Max = @rGoldMax,Cmp_Id = @rCmpId where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Gold' and Cmp_Id = @rCmpId
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rPlatinumMin,GSB_Max = @rPlatinumMax,Cmp_Id = @rCmpId where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Platinum' and Cmp_Id = @rCmpId
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rRoyalPlatinumMin,GSB_Max = @rRoyalPlatinumMax,Cmp_Id = @rCmpId where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Royal Platinum' and Cmp_Id = @rCmpId
	end

	select * from @tbltmp
end