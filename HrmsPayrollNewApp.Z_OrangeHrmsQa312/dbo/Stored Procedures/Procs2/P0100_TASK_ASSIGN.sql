-- EXEC P0100_TASK_ASSIGN
-- DROP PROCEDURE P0100_TASK_ASSIGN
CREATE PROCEDURE P0100_TASK_ASSIGN
@rTitle VARCHAR(5000),
@rDescription VARCHAR(MAX),
@rFileNames VARCHAR(MAX),
@rDueDate VARCHAR(50),
@rTargetDate VARCHAR(50),
@rDuration VARCHAR(50),
@rParentId INT,
@rTaskTypeId INT,
@rCategoryId INT,
@rPriorityId INT,
@rStatusId INT,
@rProjectId INT,
@rAssignedToId INT,
@rCreatedEmpId INT,
@rTaskId INT = NULL,
@rTaskDetailId INT = NULL,
@rActivityId INT = NULL,
@rLogDuration VARCHAR(50) = NULL,
@rComment VARCHAR(MAX) = NULL,
@rNotes VARCHAR(MAX) = NULL,
@rEmpIds VARCHAR(MAX) = NULL,
@rAssignToEmpIds VARCHAR(MAX) = NULL,
@rIsMulti INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE @rMainId INT,@lTaskDetailId INT,@rTotalCount INT,@rCloseCount INT,@rTaskOwnerId INT
	DECLARE @rIsFinal BIT
	SELECT @rDueDate = CASE ISNULL(@rDueDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rDueDate, 105), 23) END
	SELECT @rTargetDate = CASE ISNULL(@rTargetDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rTargetDate, 105), 23) END
	
	IF ISNULL(@rTargetDate,'1900-01-01') <> '1900-01-01' OR @rTargetDate = ''
	BEGIN
		IF @rTargetDate < @rDueDate
		BEGIN
			SELECT -105 AS RES
			RETURN
		END
	END

	SELECT @rIsFinal = ISNULL(s_IsFinal,0) from T0040_Status_Master WITH(NOLOCK) WHERE Status_Id = @rStatusId
	
	IF @rIsFinal = 1
	BEGIN		
		SELECT @rTaskOwnerId = Created_Emp_Id FROM T0100_Task_Assign WITH(NOLOCK) WHERE Task_Id = @rTaskId

		SELECT @rTotalCount = COUNT(1) FROM T0110_Task_Detail WITH(NOLOCK) WHERE Task_ParentId = @rTaskId AND Task_IsActive = 1
		SELECT @rCloseCount = COUNT(1) FROM T0110_Task_Detail WITH(NOLOCK) WHERE Task_ParentId = @rTaskId AND Task_IsActive = 1 AND Status_Id = @rStatusId

		IF @rTotalCount <> @rCloseCount
		BEGIN
			SELECT -106 AS RES
			RETURN
		END

		IF @rTaskOwnerId <> @rCreatedEmpId
		BEGIN
			SELECT -107 AS RES
			RETURN
		END
	END

	DECLARE @tblTasks TABLE
	(
		tid INT IDENTITY(1,1),AssignedTo VARCHAR(300),TaskOwner VARCHAR(300),TaskType VARCHAR(300),TaskCategory VARCHAR(300),TaskPriority VARCHAR(300),TaskStatus VARCHAR(300),
		TaskProject VARCHAR(300),EmpEmail VARCHAR(300),TaskCode VARCHAR(300)
	)

	IF ISNULL(@rTaskId,0) = 0
		BEGIN
			INSERT INTO T0100_Task_Assign
			(
				Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,Task_Title,
				Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_IsMulti
			)
			SELECT @rParentId,@rTaskTypeId,@rCategoryId,@rStatusId,@rPriorityId,@rProjectId,CASE @rAssignedToId WHEN -101 THEN @rCreatedEmpId ELSE @rAssignedToId END,
			@rCreatedEmpId,@rTitle,@rDescription,@rDueDate,@rTargetDate,@rDuration,@rIsMulti

			SELECT @rMainId = SCOPE_IDENTITY()

			INSERT INTO T0110_Task_Watcher
			(
				Task_Id,Emp_Id
			)
			SELECT @rMainId,Data from dbo.Split(@rEmpIds,',') WHERE Data <> ''
						
			INSERT INTO T0110_Task_Detail
			(
				Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
				Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_IsActive
			)
			SELECT @rMainId,@rParentId,@rTaskTypeId,@rCategoryId,@rStatusId,@rPriorityId,@rProjectId,Data,
			@rCreatedEmpId,@rTitle,@rDescription,@rDueDate,@rTargetDate,@rDuration,1 from dbo.Split(@rAssignToEmpIds,',') WHERE Data <> ''

			SELECT @lTaskDetailId = SCOPE_IDENTITY()

			INSERT INTO T0110_Task_Images
			(
				Task_Id,Task_FileName,Task_FileNameStr
			)
			SELECT @rMainId,val1,val2 FROM dbo.Split(@rFileNames,',') CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'&&') WHERE data <> ''

			INSERT INTO @tblTasks
			SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
			CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
			ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
			ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
			'#TASK' + CONVERT(VARCHAR,@rMainId)
			FROM T0100_Task_Assign TAD WITH(NOLOCK)
			INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
			LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
			LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
			INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
			INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
			INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
			INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
			INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
			WHERE TAD.Task_Id = @rMainId
		END
	ELSE
		BEGIN
			INSERT INTO T0110_Task_Images
			(
				Task_Id,Task_FileName,Task_FileNameStr
			)
			SELECT @rTaskId,val1,val2 FROM dbo.Split(@rFileNames,',') CROSS APPLY dbo.fnc_BifurcateString(ISNULL(data,''),'&&') WHERE data <> ''

			DECLARE @lParentId INT,@lTaskTypeId INT,@lTaskCatId INT,@lStatusId INT,@lPriorityId INT,@lProjectId INT,@lAssignEmpId INT,
			@lTitle VARCHAR(MAX),@lDescription VARCHAR(MAX),@lDueDate SMALLDATETIME,@lTargetDate SMALLDATETIME,@lEstimatedTime VARCHAR(50),
			@lActivityId INT,@lLogHours TIME(7),@lComments VARCHAR(MAX),@lNotes VARCHAR(MAX),@lCreatedId INT

			SELECT @lCreatedId = Created_Emp_Id FROM T0100_Task_Assign WHERE Task_Id = @rTaskId

			DECLARE @lAssignedEmps TABLE(tid INT IDENTITY(1,1),t_EmpId INT,t_EmpName VARCHAR(300))
			INSERT INTO @lAssignedEmps
			SELECT Assigned_Emp_Id,Emp_Full_Name FROM T0110_Task_Detail WITH(NOLOCK) INNER JOIN T0080_EMP_MASTER WITH(NOLOCK) ON Assigned_Emp_Id = Emp_ID WHERE Task_Id = @rTaskId AND Task_IsActive = 1

			DECLARE @lNewAssignedEmps TABLE(tid INT IDENTITY(1,1),n_EmpId INT,n_EmpName VARCHAR(300))
			INSERT INTO @lNewAssignedEmps
			SELECT Data,Emp_Full_Name FROM dbo.Split(@rAssignToEmpIds,',') INNER JOIN T0080_EMP_MASTER WITH(NOLOCK) ON Data = Emp_ID WHERE Data <> ''

			IF @rCreatedEmpId = 0
				BEGIN
					SELECT @lParentId = Task_ParentId,@lTaskTypeId = Task_Type_Id,@lTaskCatId = Task_Cat_Id,@lStatusId = Status_Id,
					@lPriorityId = Priority_Id,@lProjectId = Project_Id,@lAssignEmpId = Assigned_Emp_Id,@lTitle = Task_Title,
					@lDescription = Task_Description,@lDueDate = Task_DueDate,@lTargetDate = Task_TargetDate,
					@lEstimatedTime = Task_EstimatedTime,@lActivityId = Activity_Id,@lLogHours = Task_Log_Hours,
					@lComments = Task_Log_Comments,@lNotes = Task_Log_Notes
					FROM
					(
						SELECT Task_Detail_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Detail_Id DESC) AS rn,
						Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,
						Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Activity_Id,
						Task_Log_Hours,Task_Log_Comments,Task_Log_Notes
						FROM T0110_Task_Detail AS TAD WITH(NOLOCK) WHERE Task_Id = @rTaskId
					) t WHERE t.rn = 1
				END
			ELSE
				BEGIN
					SELECT @lParentId = Task_ParentId,@lTaskTypeId = Task_Type_Id,@lTaskCatId = Task_Cat_Id,@lStatusId = Status_Id,
					@lPriorityId = Priority_Id,@lProjectId = Project_Id,@lAssignEmpId = Assigned_Emp_Id,@lTitle = Task_Title,
					@lDescription = Task_Description,@lDueDate = Task_DueDate,@lTargetDate = Task_TargetDate,
					@lEstimatedTime = Task_EstimatedTime,@lActivityId = Activity_Id,@lLogHours = Task_Log_Hours,
					@lComments = Task_Log_Comments,@lNotes = Task_Log_Notes
					FROM
					(
						SELECT Task_Detail_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Detail_Id DESC) AS rn,
						Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,
						Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Activity_Id,
						Task_Log_Hours,Task_Log_Comments,Task_Log_Notes
						FROM T0110_Task_Detail AS TAD WITH(NOLOCK) WHERE Task_Id = @rTaskId AND Assigned_Emp_Id = @rCreatedEmpId
					) t WHERE t.rn = 1
				END

			IF @lCreatedId = @rCreatedEmpId
				BEGIN
					UPDATE T0100_Task_Assign SET Task_ParentId = @rParentId,Status_Id = @rStatusId,Project_Id = @rProjectId,Priority_Id = @rPriorityId,
					Task_Type_Id = @rTaskTypeId,Task_Cat_Id = @rCategoryId,Task_Title = @rTitle,Task_Description = @rDescription,Task_DueDate = @rDueDate,
					Task_TargetDate = @rTargetDate,Task_EstimatedTime = @rDuration WHERE Task_Id = @rTaskId

					UPDATE T0110_Task_Detail SET Task_IsActive = 0 WHERE Task_Id = @rTaskId
				END

			INSERT INTO T0110_Task_Detail
			(
				Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
				Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_Updated_Emp_Id,Activity_Id,
				Task_Log_Hours,Task_Log_Comments,Task_Log_Notes,Task_UpdatedDate,Task_IsActive
			)
			SELECT @rTaskId,@rParentId,@rTaskTypeId,@rCategoryId,@rStatusId,@rPriorityId,@rProjectId,Data,
			@rCreatedEmpId,@rTitle,@rDescription,@rDueDate,@rTargetDate,@rDuration,@rCreatedEmpId,@rActivityId,@rLogDuration,@rComment,@rNotes,GETDATE(),1
			from dbo.Split(@rAssignToEmpIds,',') WHERE Data <> ''

			UPDATE T0110_Task_Detail SET Task_IsActive = 0 WHERE Assigned_Emp_Id NOT IN (SELECT Data FROM dbo.Split(@rAssignToEmpIds,',') WHERE Data <> '') AND Task_Id	= @rTaskId
			
			--IF @rIsMulti = 0
			--	BEGIN
			--		INSERT INTO T0110_Task_Detail
			--		(
			--			Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
			--			Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_Updated_Emp_Id,Activity_Id,
			--			Task_Log_Hours,Task_Log_Comments,Task_Log_Notes,Task_UpdatedDate,Task_IsActive
			--		)
			--		SELECT @rTaskId,@rParentId,@rTaskTypeId,@rCategoryId,@rStatusId,@rPriorityId,@rProjectId,Data,
			--		@rCreatedEmpId,@rTitle,@rDescription,@rDueDate,@rTargetDate,@rDuration,@rCreatedEmpId,@rActivityId,@rLogDuration,@rComment,@rNotes,GETDATE(),1
			--		from dbo.Split(@rAssignToEmpIds,',') WHERE Data <> ''

			--		UPDATE T0110_Task_Detail SET Task_IsActive = 0 WHERE Assigned_Emp_Id NOT IN (SELECT Data FROM dbo.Split(@rAssignToEmpIds,',') WHERE Data <> '') AND Task_Id	= @rTaskId
			--	END
			--ELSE
			--	BEGIN					
			--		INSERT INTO T0110_Task_Detail
			--		(
			--			Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
			--			Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_Updated_Emp_Id,Activity_Id,
			--			Task_Log_Hours,Task_Log_Comments,Task_Log_Notes,Task_UpdatedDate,Task_IsActive
			--		)
			--		SELECT @rTaskId,@rParentId,@rTaskTypeId,@rCategoryId,@rStatusId,@rPriorityId,@rProjectId,Data,
			--		@rCreatedEmpId,@rTitle,@rDescription,@rDueDate,@rTargetDate,@rDuration,@rCreatedEmpId,@rActivityId,@rLogDuration,@rComment,@rNotes,GETDATE(),1
			--		from dbo.Split(@rAssignToEmpIds,',') WHERE Data <> ''
					
			--		UPDATE T0110_Task_Detail SET Task_IsActive = 0 WHERE Assigned_Emp_Id NOT IN (SELECT Data FROM dbo.Split(@rAssignToEmpIds,',') WHERE Data <> '') AND Task_Id	= @rTaskId
			--	END

			IF @lParentId <> @rParentId
				BEGIN
					DECLARE @lOTitle VARCHAR(MAX) = '',@lNTitle VARCHAR(MAX) = ''

					SELECT @lOTitle = Task_Title FROM T0100_Task_Assign WHERE Task_Id = @lParentId
					SELECT @lNTitle = Task_Title FROM T0100_Task_Assign WHERE Task_Id = @rParentId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Parent Task',@lOTitle,@lNTitle,@rCreatedEmpId				
				END
			IF @lTaskTypeId <> @rTaskTypeId
				BEGIN
					DECLARE @lOTaskType VARCHAR(300) = '',@lNTaskType VARCHAR(300) = ''

					SELECT @lOTaskType = ttm_Title FROM T0040_Tasks_Type_Master WHERE Task_Type_ID = @lTaskTypeId
					SELECT @lNTaskType = ttm_Title FROM T0040_Tasks_Type_Master WHERE Task_Type_ID = @rTaskTypeId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Task Type',@lOTaskType,@lNTaskType,@rCreatedEmpId
				END
			IF @lTaskCatId <> @rCategoryId
				BEGIN
					DECLARE @lOCategory VARCHAR(300) = '',@lNCategory VARCHAR(300) = ''

					SELECT @lOCategory = tc_Title FROM T0040_Task_Category_Master WHERE Task_Cat_Id = @lTaskCatId
					SELECT @lNCategory = tc_Title FROM T0040_Task_Category_Master WHERE Task_Cat_Id = @rCategoryId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Task Category',@lOCategory,@lNCategory,@rCreatedEmpId
				END
			IF @lStatusId <> @rStatusId
				BEGIN
					DECLARE @lOStatus VARCHAR(300) = '',@lNStatus VARCHAR(300) = ''
					DECLARE @lOStatusPercent INT,@lNStatusPercent INT

					SELECT @lOStatus = s_Title,@lOStatusPercent = s_Percentage FROM T0040_Status_Master WHERE Status_Id = @lStatusId
					SELECT @lNStatus = s_Title,@lNStatusPercent = s_Percentage FROM T0040_Status_Master WHERE Status_Id = @rStatusId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Task Status',@lOStatus,@lNStatus,@rCreatedEmpId

					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Task Status',@lOStatusPercent,@lNStatusPercent,@rCreatedEmpId

					INSERT INTO @tblTasks
					SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
					CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
					ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
					ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
					'#TASK' + CONVERT(VARCHAR,@rMainId)
					FROM T0100_Task_Assign TAD WITH(NOLOCK)
					INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
					INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
					WHERE TAD.Task_Id = @rTaskId and Task_IsActive = 1
				END
			IF @rIsMulti = 0
				BEGIN
					IF @lAssignEmpId <> @rAssignedToId
						BEGIN
							DECLARE @lOEMP VARCHAR(300) = '',@lNEMP VARCHAR(300) = ''

							SELECT @lOEMP = ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') FROM T0080_EMP_MASTER WHERE Emp_ID = @lAssignEmpId
							SELECT @lNEMP = ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') FROM T0080_EMP_MASTER WHERE Emp_ID = @rAssignedToId
							INSERT INTO T0110_Task_Audit
							(
								Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
							)
							SELECT @rTaskId,@rTaskDetailId,'Assigned To',@lOEMP,@lNEMP,@rCreatedEmpId

							INSERT INTO @tblTasks
							SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
							CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
							ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
							ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
							'#TASK' + CONVERT(VARCHAR,@rMainId)
							FROM T0100_Task_Assign TAD WITH(NOLOCK)
							INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
							LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
							LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
							INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
							INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
							INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
							INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
							INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
							WHERE TAD.Task_Id = @rTaskId and Task_IsActive = 1
						END
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM @lAssignedEmps WHERE t_EmpId NOT IN (SELECT n_EmpId FROM @lNewAssignedEmps))
						BEGIN
							IF((SELECT COUNT(1) FROM @lAssignedEmps) = (SELECT COUNT(1) FROM @lNewAssignedEmps))
								BEGIN
									DECLARE @lOEmpName VARCHAR(300) = '',@lNEmpName VARCHAR(300) = ''

									SELECT @lOEmpName = t_EmpName FROM @lAssignedEmps WHERE t_EmpId NOT IN (SELECT n_EmpId FROM @lNewAssignedEmps)
									SELECT @lNEmpName = n_EmpName FROM @lNewAssignedEmps WHERE n_EmpId NOT IN (SELECT t_EmpId FROM @lAssignedEmps)
									INSERT INTO T0110_Task_Audit
									(
										Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
									)
									SELECT @rTaskId,@rTaskDetailId,'Assigned To',@lOEMP,@lNEMP,@rCreatedEmpId

									INSERT INTO @tblTasks
									SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
									CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
									ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
									ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
									'#TASK' + CONVERT(VARCHAR,@rMainId)
									FROM T0100_Task_Assign TAD WITH(NOLOCK)
									INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
									LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
									LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
									INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
									INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
									INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
									INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
									INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
									WHERE TAD.Task_Id = @rMainId and Task_IsActive = 1
								END
							ELSE IF((SELECT COUNT(1) FROM @lAssignedEmps) > (SELECT COUNT(1) FROM @lNewAssignedEmps))
								BEGIN									
									INSERT INTO T0110_Task_Audit
									(
										Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
									)
									SELECT @rTaskId,@rTaskDetailId,'Assignee ',t_EmpName,' Removed',@rCreatedEmpId FROM @lAssignedEmps WHERE t_EmpId NOT IN (SELECT n_EmpId FROM @lNewAssignedEmps)

									INSERT INTO @tblTasks
									SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
									CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
									ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
									ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
									'#TASK' + CONVERT(VARCHAR,@rMainId)
									FROM T0100_Task_Assign TAD WITH(NOLOCK)
									INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
									LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
									LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
									INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
									INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
									INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
									INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
									INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
									WHERE TAD.Task_Id = @rMainId and Task_IsActive = 1
								END
							ELSE IF((SELECT COUNT(1) FROM @lAssignedEmps) < (SELECT COUNT(1) FROM @lNewAssignedEmps))
								BEGIN									
									INSERT INTO T0110_Task_Audit
									(
										Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
									)
									SELECT @rTaskId,@rTaskDetailId,'Assignee ',n_EmpName,' Added',@rCreatedEmpId FROM @lNewAssignedEmps WHERE n_EmpId NOT IN (SELECT t_EmpId FROM @lAssignedEmps)

									INSERT INTO @tblTasks
									SELECT CASE TATAD.Assigned_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') END,
									CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END,
									ISNULL(TTM.ttm_Title,''),ISNULL(TCM.tc_Title,''),ISNULL(PRM.pm_Title,''),
									ISNULL(SM.s_Title,''),ISNULL(PM.pr_Title,''),ISNULL(EMP1.Work_Email,''),
									'#TASK' + CONVERT(VARCHAR,@rMainId)
									FROM T0100_Task_Assign TAD WITH(NOLOCK)
									INNER JOIN T0110_Task_Detail TATAD WITH (NOLOCK) ON TAD.Task_Id = TATAD.Task_Id
									LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
									LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TATAD.Assigned_Emp_Id = EMP1.Emp_ID
									INNER JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
									INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
									INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
									INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
									INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
									WHERE TAD.Task_Id = @rMainId and Task_IsActive = 1
								END
						END
				END
			IF @lPriorityId <> @rPriorityId
				BEGIN
					DECLARE @lOPriority VARCHAR(300) = '',@lNPriority VARCHAR(300) = ''

					SELECT @lOPriority = pm_Title FROM T0040_Priority_Master WHERE Priority_Id = @lPriorityId
					SELECT @lNPriority = pm_Title FROM T0040_Priority_Master WHERE Priority_Id = @rPriorityId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Priority',@lOPriority,@lNPriority,@rCreatedEmpId
				END
			IF @lProjectId <> @rProjectId
				BEGIN
					DECLARE @lOProject VARCHAR(300) = '',@lNProject VARCHAR(300) = ''

					SELECT @lOProject = pr_Title FROM T0040_Task_Project_Master WHERE Project_Id = @lProjectId
					SELECT @lNProject = pr_Title FROM T0040_Task_Project_Master WHERE Project_Id = @rProjectId
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Project',@lOProject,@lNProject,@rCreatedEmpId
				END
			IF @lTitle <> @rTitle
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Title',@lTitle,@rTitle,@rCreatedEmpId
				END
			IF @lDescription <> @rDescription
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Description',@lDescription,@rDescription,@rCreatedEmpId
				END
			IF @lDueDate <> @rDueDate
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Due Date',@lDueDate,@rDueDate,@rCreatedEmpId
				END
			IF @lTargetDate <> @rTargetDate
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Target Date',@lTargetDate,@rTargetDate,@rCreatedEmpId
				END
			IF @lEstimatedTime <> @rDuration
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Estimated Duration',@lEstimatedTime,@rDuration,@rCreatedEmpId
				END
			IF @rComment <> ''
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Commented',@rComment,@rComment,@rCreatedEmpId
				END

			IF @rNotes <> ''
				BEGIN
					INSERT INTO T0110_Task_Audit
					(
						Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
					)
					SELECT @rTaskId,@rTaskDetailId,'Notes Added',@rNotes,@rNotes,@rCreatedEmpId
				END
		END

		SELECT 1 AS RES,* FROM @tblTasks
END