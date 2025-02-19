-- exec KPMS_prc_SaveGoal
-- drop proc KPMS_prc_SaveGoal
CREATE procedure [dbo].[KPMS_prc_SaveGoal]
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
	DECLARE @lXML XML,@lGoalSettingId INT
	SET @lXML = CAST(@rPermissionStr AS xml)

	SELECT @rFromDate = CASE ISNULL(@rFromDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rFromDate, 105), 23) END
	SELECT @rToDate = CASE ISNULL(@rToDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rToDate, 105), 23) END

	DECLARE @tbltmp TABLE
	(
		tid INT IDENTITY(1,1),t_SectionName varchar(300),t_SectionWeightageTypeId INT,t_SectionWeightageValue INT,t_SectionStatusId INT,t_SectionMonth INT,
		t_GoalName varchar(300),t_SubGoalName varchar(300),t_GoalFrequecyId INT,t_GoalWeightageTypeId INT,t_GoalWeightageValue INT,t_GoalStatus INT,t_GoalDependency BIT,
		t_GoalDependId INT,t_GoalTypeId INT,t_GoalValue INT,t_SectionId INT,t_GoalId INT,t_SubGoalId INT,t_GoalSettingId INT,t_GoalSettingSectionId INT
	)
	INSERT INTO @tbltmp
	SELECT T.c.value('@sname','varchar(300)') AS sname,
	T.c.value('@swt','INT') AS swt,
	T.c.value('@swv','INT') AS swv,
	T.c.value('@ss','INT') AS ss,
	T.c.value('@sm','INT') AS sm,
	T.c.value('@gname','varchar(300)') AS gname,
	T.c.value('@gsname','varchar(300)') AS gsname,
	T.c.value('@gfreq','INT') AS gfreq,
	T.c.value('@gwt','INT') AS gwt,
	T.c.value('@gwv','INT') AS gwv,
	T.c.value('@gs','INT') AS gs,
	T.c.value('@gdp','bit') AS gdp,
	T.c.value('@gm','INT') AS gm,
	T.c.value('@gtyp','INT') AS gtyp,
	T.c.value('@gv','INT') AS gv,0,0,0,0,0
	FROM @lXML.nodes('/Permissions/Permission') AS T(c)

	UPDATE @tbltmp set t_SectionId = Section_ID from KPMS_T0020_Section_Master where t_SectionName = Section_Name and Cmp_Id = @rCmpId
	UPDATE @tbltmp set t_GoalId = Goal_ID from KPMS_T0020_Goal_Master where t_GoalName = Goal_Name and Cmp_Id = @rCmpId and Section_ID = t_SectionId
	UPDATE @tbltmp set t_SubGoalId = SubGoal_ID from KPMS_T0020_SubGoal_Master where t_SubGoalName = SubGoal_Name and Cmp_Id = @rCmpId and Goal_Id = t_GoalId

	DECLARE @tblSection TABLE
	(
		tid int identity(1,1),tt_SectionName varchar(300),tt_IsActive INT,tt_SectionId int,tt_MonthId int,tt_weightageId int,tt_weightageVal int,tt_GoalSettingSectionId int
	)
	INSERT INTO @tblSection
	select distinct t_SectionName,t_SectionStatusId,0,t_SectionMonth,t_SectionWeightageTypeId,t_SectionWeightageValue,0 from @tbltmp

	MERGE KPMS_T0020_Section_Master AS TARGET
	USING @tblSection AS SOURCE ON Section_Name = tt_SectionName and Cmp_Id = @rCmpId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			Cmp_Id,Section_Name,IsActive,User_Id
		)
		VALUES
		(
			@rCmpId,tt_SectionName,tt_IsActive,@rUserId
		);

	UPDATE @tblSection set tt_SectionId = Section_ID from KPMS_T0020_Section_Master where tt_SectionName = Section_Name and Cmp_Id = @rCmpId
	UPDATE @tbltmp set t_SectionId = tt_SectionId from @tblSection where t_SectionName = tt_SectionName

	DECLARE @tblGoal TABLE
	(
		tid int identity(1,1),tt_GoalName varchar(300),tt_GoalStatusId INT,tt_SectionId INT,tt_GoalId INT
	)
	INSERT INTO @tblGoal
	select distinct t_GoalName,t_GoalStatus,t_SectionId,0 from @tbltmp

	MERGE KPMS_T0020_Goal_Master AS TARGET
	USING @tblGoal AS SOURCE ON Goal_Name = tt_GoalName and Cmp_Id = @rCmpId and Section_ID = tt_SectionId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			Cmp_Id,Goal_Name,IsActive,Section_ID,User_Id
		)
		VALUES
		(
			@rCmpId,tt_GoalName,tt_GoalStatusId,tt_SectionId,@rUserId
		);

	UPDATE @tblGoal set tt_GoalId = Goal_ID from KPMS_T0020_Goal_Master where tt_GoalName = Goal_Name and Cmp_Id = @rCmpId and tt_SectionId = Section_ID
	UPDATE @tbltmp set t_GoalId = tt_GoalId from @tblGoal where t_GoalName = tt_GoalName and tt_SectionId = t_SectionId

	DECLARE @tblSubGoal TABLE
	(
		tid int identity(1,1),tt_GoalName varchar(300),tt_GoalStatusId INT,tt_SectionId INT,tt_GoalId INT
	)
	INSERT INTO @tblSubGoal
	select distinct t_SubGoalName,t_GoalStatus,t_GoalId,0 from @tbltmp

	MERGE KPMS_T0020_SubGoal_Master AS TARGET
	USING @tblSubGoal AS SOURCE ON SubGoal_Name = tt_GoalName and Cmp_Id = @rCmpId and Goal_Id = tt_SectionId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			Cmp_Id,SubGoal_Name,IsActive,Goal_Id,User_Id
		)
		VALUES
		(
			@rCmpId,tt_GoalName,tt_GoalStatusId,tt_SectionId,@rUserId
		);

	UPDATE @tblSubGoal set tt_GoalId = SubGoal_ID from KPMS_T0020_SubGoal_Master where tt_GoalName = SubGoal_Name and Cmp_Id = @rCmpId and tt_SectionId = Goal_Id
	UPDATE @tbltmp set t_SubGoalId = tt_GoalId from @tblSubGoal where t_SubGoalName = tt_GoalName and tt_SectionId = t_GoalId
	
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
	USING @tblSection AS SOURCE ON GSS_Goal_Setting_Id = @lGoalSettingId and Cmp_Id = @rCmpId and GSS_SectionId = tt_SectionId
	WHEN MATCHED THEN
		UPDATE SET GSS_WeightageTypeId = tt_weightageId,GSS_WeightageValue = tt_weightageVal,GSS_StatusId = tt_IsActive,GSS_MonthId = tt_MonthId
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			GSS_Goal_Setting_Id,GSS_SectionId,GSS_WeightageTypeId,GSS_WeightageValue,GSS_StatusId,GSS_MonthId,Cmp_Id
		)
		VALUES
		(
			@lGoalSettingId,tt_SectionId,tt_weightageId,tt_weightageVal,tt_IsActive,tt_MonthId,@rCmpId
		);

	update @tblSection set tt_GoalSettingSectionId = GSS_Id from KPMS_T0110_Goal_Setting_Section where GSS_SectionId = tt_SectionId and Cmp_Id = @rCmpId and GSS_Goal_Setting_Id = @lGoalSettingId
	update @tbltmp set t_GoalSettingSectionId = tt_GoalSettingSectionId from @tblSection where t_SectionId = tt_SectionId

	MERGE KPMS_T0110_Goal_Setting_Goal AS TARGET
	USING @tbltmp AS SOURCE ON GSG_GoalSetting_Id = @lGoalSettingId and Cmp_Id = @rCmpId and GSG_GoalSettingSection_Id = t_GoalSettingSectionId and GSG_Goal_Id = t_GoalId
	WHEN MATCHED THEN
		UPDATE SET GSG_WeightageType_Id = t_GoalWeightageTypeId,GSG_WeightageValue = t_GoalWeightageValue,GSG_StatusId = t_GoalStatus,GSG_IsDependency = t_GoalDependency,
		GSG_Depend_Goal_Id = t_GoalDependId,GSG_Depend_Type_Id = t_GoalTypeId,GSG_DependValue = t_GoalValue
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
		(
			GSG_GoalSetting_Id,GSG_GoalSettingSection_Id,GSG_Goal_Id,GSG_Sub_Goal_Id,GSG_FrequecyId,GSG_WeightageType_Id,GSG_WeightageValue,GSG_StatusId,GSG_IsDependency,
			GSG_Depend_Goal_Id,GSG_Depend_Type_Id,GSG_DependValue,Cmp_Id
		)
		VALUES
		(
			@lGoalSettingId,t_SectionId,t_GoalId,t_SubGoalId,t_GoalFrequecyId,t_GoalWeightageTypeId,t_GoalWeightageValue,t_GoalStatus,t_GoalDependency,
			t_GoalDependId,t_GoalTypeId,t_GoalValue,@rCmpId
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
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rSilverMin,GSB_Max = @rSilverMax where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Silver'
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rGoldMin,GSB_Max = @rGoldMax where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Gold'
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rPlatinumMin,GSB_Max = @rPlatinumMax where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Platinum'
		update KPMS_T0110_GoalSettingScore set GSB_Min = @rRoyalPlatinumMin,GSB_Max = @rRoyalPlatinumMax where GSB_GoalSettingId = @lGoalSettingId and GSB_Title = 'Royal Platinum'
	end

	select * from @tbltmp
end