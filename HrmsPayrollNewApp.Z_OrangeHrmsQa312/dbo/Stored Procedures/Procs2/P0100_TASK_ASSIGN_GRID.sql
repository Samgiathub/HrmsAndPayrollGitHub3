-- EXEC P0100_TASK_ASSIGN_GRID
-- DROP PROCEDURE P0100_TASK_ASSIGN_GRID
CREATE PROCEDURE [dbo].[P0100_TASK_ASSIGN_GRID]
@rEmpId INT,
@rPrivilegeId INT,
@rType INT,
@rTaskId INT,
@rTaskDetailId INT,
@rTaskTypeId INT = NULL,
@rCategoryId INT = NULL,
@rPriorityId INT = NULL,
@rStatusId INT = NULL,
@rProjectId INT = NULL,
@risEdit INT = NULL,
@rFromDate VARCHAR(50) = NULL,
@rToDate VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @rFromDate = CASE ISNULL(@rFromDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rFromDate, 105), 23) END
	SELECT @rToDate = CASE ISNULL(@rToDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rToDate, 105), 23) END

	DECLARE @lRoleId INT,@lResult VARCHAR(MAX) = '',@lTotalResults VARCHAR(MAX) = '',@lExportResult VARCHAR(MAX) = ''
	SELECT @lRoleId = Role_Id FROM T0100_Emp_Role_Assign WHERE Emp_Id = @rEmpId
	
	IF @rType = 1
		BEGIN
			CREATE TABLE #TASK_EMP
			(
				tid INT IDENTITY(1,1),t_EmpId INT,t_TaskId INT
			)
			INSERT INTO #TASK_EMP
			SELECT Emp_Id,Task_Id
			FROM T0110_Task_Watcher WITH(NOLOCK) WHERE Emp_Id NOT IN
			(
				SELECT Task_Id FROM T0100_Task_Assign WITH(NOLOCK)
			)

			CREATE TABLE #TEAM_EMP
			(
				tid INT IDENTITY(1,1),team_EmpId INT
			)
			INSERT INTO #TEAM_EMP
			SELECT EM.Emp_ID
			FROM dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)
			WHERE EM.Emp_Superior = @rEmpId

			INSERT INTO #TASK_EMP
			SELECT Assigned_Emp_Id,Task_Id
			FROM T0110_Task_Detail AS TAD WITH(NOLOCK)
			INNER JOIN #TEAM_EMP ON team_EmpId = TAD.Assigned_Emp_Id

			CREATE TABLE #TASK_TEMP
			(
				tid INT IDENTITY(1,1),t_Id INT,t_Row INT
			)
			
			IF @lRoleId = 1 OR @rPrivilegeId = 0
				BEGIN
					INSERT INTO #TASK_TEMP
					SELECT Task_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Id DESC) AS rn
					FROM T0100_Task_Assign AS TAD WITH(NOLOCK)
					WHERE (TAD.Status_Id = @rStatusId OR @rStatusId = 0)
					AND (TAD.Task_Cat_Id = @rCategoryId OR @rCategoryId = 0)
					AND (TAD.Task_Type_Id = @rTaskTypeId OR @rTaskTypeId = 0)
					AND (TAD.Project_Id = @rProjectId OR @rProjectId = 0)
					AND (TAD.Priority_Id = @rPriorityId OR @rPriorityId = 0)
					AND (CASE WHEN TAD.Task_DueDate IS NULL OR ISNULL(TAD.Task_DueDate,'') = '1900-01-01' THEN DATEDIFF(DAY,@rFromDate,TAD.Task_CreatedDate) ELSE DATEDIFF(DAY,@rFromDate,TAD.Task_DueDate) END >= 0 OR @rFromDate = '')
					AND (CASE WHEN TAD.Task_DueDate IS NULL OR ISNULL(TAD.Task_DueDate,'') = '1900-01-01' THEN DATEDIFF(DAY,TAD.Task_CreatedDate,@rToDate) ELSE DATEDIFF(DAY,TAD.Task_DueDate,@rToDate) END >= 0 OR @rToDate = '')
					ORDER BY TAD.Task_Id DESC					
				END
			ELSE
				BEGIN
					INSERT INTO #TASK_TEMP
					SELECT Task_Detail_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Detail_Id DESC) AS rn
					FROM T0110_Task_Detail AS TAD WITH(NOLOCK)
					INNER JOIN T0100_Task_Assign AS TA WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
					LEFT JOIN #TASK_EMP ON TAD.Task_Id = t_TaskId					
					WHERE (TAD.Assigned_Emp_Id = @rEmpId OR t_EmpId = @rEmpId OR TAD.Created_Emp_Id = @rEmpId)
					AND (TAD.Status_Id = @rStatusId OR @rStatusId = 0)
					AND (TAD.Task_Cat_Id = @rCategoryId OR @rCategoryId = 0)
					AND (TAD.Task_Type_Id = @rTaskTypeId OR @rTaskTypeId = 0)
					AND (TAD.Project_Id = @rProjectId OR @rProjectId = 0)
					AND (TAD.Priority_Id = @rPriorityId OR @rPriorityId = 0)
					AND (CASE WHEN TAD.Task_DueDate IS NULL OR ISNULL(TAD.Task_DueDate,'') = '1900-01-01' THEN DATEDIFF(DAY,@rFromDate,TA.Task_CreatedDate) ELSE DATEDIFF(DAY,@rFromDate,TAD.Task_DueDate) END >= 0 OR @rFromDate = '')
					AND (CASE WHEN TAD.Task_DueDate IS NULL OR ISNULL(TAD.Task_DueDate,'') = '1900-01-01' THEN DATEDIFF(DAY,TA.Task_CreatedDate,@rToDate) ELSE DATEDIFF(DAY,TAD.Task_DueDate,@rToDate) END >= 0 OR @rToDate = '')
					ORDER BY TAD.Task_Id DESC

					IF EXISTS((SELECT COUNT(1) FROM #TEAM_EMP))
						BEGIN
							INSERT INTO #TASK_TEMP
							SELECT Task_Detail_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Detail_Id DESC) AS rn
							FROM T0110_Task_Detail AS TAD WITH(NOLOCK)
							INNER JOIN T0100_Task_Assign AS TA WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
							LEFT JOIN #TASK_EMP ON TAD.Task_Id = t_TaskId
							WHERE (TAD.Status_Id = @rStatusId OR @rStatusId = 0)
							AND (TAD.Task_Cat_Id = @rCategoryId OR @rCategoryId = 0)
							AND (TAD.Task_Type_Id = @rTaskTypeId OR @rTaskTypeId = 0)
							AND (TAD.Project_Id = @rProjectId OR @rProjectId = 0)
							AND (TAD.Priority_Id = @rPriorityId OR @rPriorityId = 0)
							AND t_EmpId IN (SELECT EM.Emp_ID FROM dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) WHERE Emp_Superior = @rEmpId)
							AND (DATEDIFF(DAY,@rFromDate,TA.Task_DueDate) >= 0 OR @rFromDate = '')
							AND (DATEDIFF(DAY,TA.Task_DueDate,@rToDate) >= 0 OR @rToDate = '')
							ORDER BY TAD.Task_Id DESC
						END					
				END
			
			CREATE TABLE #TASK_TEMP1
			(
				tid INT IDENTITY(1,1),t_Id INT,t_Row INT
			)
			INSERT INTO #TASK_TEMP1
			SELECT distinct t_Id,0 FROM #TASK_TEMP
			
			update #TASK_TEMP1 set t_Row = 1
			
			IF @lRoleId = 1 OR @rPrivilegeId = 0
				BEGIN					
					SELECT @lResult = @lResult + '<tr><td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
					<a href="javascript:;" onclick="goTaskView(' + CONVERT(VARCHAR,TAD.Task_Id) + ',' + CONVERT(VARCHAR,0) + ');"
					style="color:#0051cc;">#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</a>
					' ELSE '<a href="javascript:;" style="color:#0051cc;">#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</a>' END + '</td>
						<td>' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') + '</td>
						<td>' + ISNULL(Task_Title,'') + '</td><td>' + ISNULL(PM.pr_Title,'') + '</td>
						<td>' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</td>
						<td>' + isnull(dbo.fnc_GetTaskAssignmentDetails(Task_Id),'') + '</td>
						<td>' + ISNULL(TTM.ttm_Title,'') + '</td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>' + ISNULL(PRM.pm_Title,'') + '</td>
						<td>' + ISNULL(SM.s_Title,'') + '</td><td>' + CASE WHEN @rEmpId = TAD.Created_Emp_Id OR @lRoleId = 1 OR @rPrivilegeId = 0 THEN + '
						<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,TAD.Task_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
						' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
					FROM T0100_Task_Assign AS TAD WITH(NOLOCK)
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,#TASK_TEMP1
					WHERE t_Id = TAD.Task_Id AND t_Row = 1 ORDER BY tid

					SELECT @lExportResult = @lExportResult + '<tr><td>#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</td>
						<td>' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') +
						CASE WHEN ISNULL(dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId),'') <> '' THEN + ' - ' + ISNULL(dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId),'') ELSE '' END + '</td>
						<td>' + ISNULL(Task_Title,'') + '</td><td>' + ISNULL(PM.pr_Title,'') + '</td>
						<td>' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</td>
						<td>' + isnull(dbo.fnc_GetTaskAssignmentDetails(Task_Id),'') + '</td>
						<td>' + ISNULL(TTM.ttm_Title,'') + '</td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>' + ISNULL(PRM.pm_Title,'') + '</td>
						<td>' + ISNULL(SM.s_Title,'') + '</td></tr>'
					FROM T0100_Task_Assign AS TAD WITH(NOLOCK)
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,#TASK_TEMP1
					WHERE t_Id = TAD.Task_Id AND t_Row = 1 ORDER BY tid
				END
			ELSE
				BEGIN
					SELECT @lResult = @lResult + '<tr><td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
					<a href="javascript:;" onclick="goTaskView(' + CONVERT(VARCHAR,TAD.Task_Id) + ',' + CONVERT(VARCHAR,Task_Detail_Id) + ');"
					style="color:#0051cc;">#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</a>
					' ELSE '<a href="javascript:;" style="color:#0051cc;">#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</a>' END + '</td>
						<td>' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') + '</td>
						<td>' + ISNULL(TAD.Task_Title,'') + '</td><td>' + ISNULL(PM.pr_Title,'') + '</td>
						<td>' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</td>
						<td>' + isnull(dbo.fnc_GetTaskAssignmentDetails(TAD.Task_Id),'') + '</td>
						<td>' + ISNULL(TTM.ttm_Title,'') + '</td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>' + ISNULL(PRM.pm_Title,'') + '</td>
						<td>' + ISNULL(SM.s_Title,'') + '</td><td>' + CASE WHEN @rEmpId = TA.Created_Emp_Id OR @lRoleId = 1 OR @rPrivilegeId = 0 THEN + '
						<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,TA.Task_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
						' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
					FROM T0110_Task_Detail AS TAD WITH(NOLOCK)
					INNER JOIN T0100_Task_Assign AS TA WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,#TASK_TEMP1
					WHERE t_Id = TAD.Task_Detail_Id AND t_Row = 1 ORDER BY tid

					SELECT @lExportResult = @lExportResult + '<tr><td>#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</td>
						<td>' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') +
						CASE WHEN ISNULL(dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId),'') <> '' THEN + ' - ' + ISNULL(dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId),'') ELSE '' END + + '</td>
						<td>' + ISNULL(TAD.Task_Title,'') + '</td><td>' + ISNULL(PM.pr_Title,'') + '</td>
						<td>' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</td>
						<td>' + isnull(dbo.fnc_GetTaskAssignmentDetails(TAD.Task_Id),'') + '</td>
						<td>' + ISNULL(TTM.ttm_Title,'') + '</td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>' + ISNULL(PRM.pm_Title,'') + '</td>
						<td>' + ISNULL(SM.s_Title,'') + '</td></tr>'
					FROM T0110_Task_Detail AS TAD WITH(NOLOCK)
					INNER JOIN T0100_Task_Assign AS TA WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,#TASK_TEMP
					WHERE t_Id = TAD.Task_Detail_Id AND t_Row = 1 ORDER BY tid
				END							

			SELECT @lTotalResults = @lTotalResults + '<span style="font-weight:bold; font-size:14px;">Total ' + CONVERT(VARCHAR,COUNT(1)) + ' records found.</span>'
			FROM #TASK_TEMP WHERE t_Row = 1

			SELECT @lResult as Result,@lTotalResults as TotalResults,@lExportResult as ExportResult
			DROP TABLE #TASK_TEMP
		END
	ELSE
		BEGIN
			DECLARE @lSubTasks VARCHAR(MAX) = '',@lHistory VARCHAR(MAX) = '',@lAttachments VARCHAR(MAX) = '',@lMultipleDetails VARCHAR(MAX) = ''
			DECLARE @lMultiUser VARCHAR(MAX) = '',@lTaskResult VARCHAR(MAX) = ''

			SELECT @lAttachments = @lAttachments + '<a href="../userfiles/TaskImages/' + ISNULL(Task_FileNameStr,'') + '" target="_blank">' + ISNULL(Task_FileNameStr,'') + '</a><br/>'
				FROM T0110_Task_Images WHERE Task_Id = @rTaskId

			;with ROWCTENEW(ROWNO,TaskDetailId) as  
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY Task_Id ORDER BY Task_Detail_Id DESC) AS rn,Task_Detail_Id
				FROM T0110_Task_Detail
				WHERE Task_ParentId = @rTaskId
			)

			SELECT @lSubTasks = @lSubTasks + '<tr><td width="10%"><a href="javascript:;"
				onclick="goTaskView(' + CONVERT(VARCHAR,TAD.Task_Id) + ',' + CONVERT(VARCHAR,Task_Detail_Id) + ');"
				style="color:#0051cc;">#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + '</a></td><td width="60%">' + ISNULL(TAD.Task_Title,'') + '</td>
				<td width="10%">' + ISNULL(SM.s_Title,'') + '</td>
				<td width="15%">' + isnull(dbo.fnc_GetTaskAssignmentDetails(TAD.Task_Id),'') + '</td>
				<td><table class="progress progress-' + CONVERT(VARCHAR,s_Percentage) + '" style="display: revert;"><tbody><tr>
				<td style="width: ' + CONVERT(VARCHAR,s_Percentage) + '%;" class="closed"></td>
				<td style="width: ' + CONVERT(VARCHAR,100 - s_Percentage) + '%;" class="todo"></td></tr></tbody></table></td></tr>'
			FROM T0110_Task_Detail AS TAD WITH(NOLOCK)	
			LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
			INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
			INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
			INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
			INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,ROWCTENEW
			WHERE TAD.Task_ParentId = @rTaskId AND TAD.Task_IsActive = 1 AND ROWNO = 1 AND TAD.Task_Detail_Id = TaskDetailId
			
			;with ROWCTE(ROWNO,TaskDetailId) as  
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY Assigned_Emp_Id ORDER BY Task_Detail_Id DESC) AS rn,Task_Detail_Id
				FROM T0110_Task_Detail
				WHERE Task_Id = @rTaskId and Task_IsActive = 1
			)

			SELECT @lMultipleDetails = @lMultipleDetails + '<tr><td>' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'') + '</td><td>' + ISNULL(SM.s_Title,'') + '</td>
				<td><table class="progress progress-' + CONVERT(VARCHAR,s_Percentage) + '" style="display: revert;"><tbody><tr>
				<td style="width: ' + CONVERT(VARCHAR,s_Percentage) + '%;" class="closed"></td>
				<td style="width: ' + CONVERT(VARCHAR,100 - s_Percentage) + '%;" class="todo"></td></tr></tbody></table></td>
				<td>' + CONVERT(VARCHAR,(SELECT CONVERT(VARCHAR(8),DATEADD(ms, SUM(DATEDIFF(ms, '00:00:00.000', ISNULL(Task_Log_Hours,''))), '00:00:00.000'),108)
				FROM T0110_Task_Detail TATAD WHERE TATAD.Assigned_Emp_Id = TAD.Assigned_Emp_Id AND TATAD.Task_Id = @rTaskId
				)) + '</td></tr>'				
			FROM T0110_Task_Detail TAD WITH(NOLOCK)
			LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
			LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
			INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
			INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
			INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
			INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id,ROWCTE
			WHERE TAD.Task_Id = @rTaskId AND TaskDetailId = TAD.Task_Detail_Id AND ROWNO = 1 AND Task_IsActive = 1

			SELECT @lMultiUser = STUFF((SELECT distinct ',' + CONVERT(VARCHAR,ISNULL(EMP1.Emp_ID,'0'))
			FROM T0080_EMP_MASTER AS EMP1
			inner join T0110_Task_Detail TATAD on emp1.Emp_ID = TATAD.Assigned_Emp_Id
			where TATAD.Task_Id = @rTaskId AND Task_IsActive = 1 FOR XML PATH ('')), 1, 1, '')

			SELECT @lHistory = @lHistory + '<div class="journal has-notes"><div id="note-5"><div class="contextual">
				<span class="journal-actions" style="display:none;">
				<a title="Quote" class="icon-only fa fa-comment" data-remote="true" rel="nofollow" href="javascript:;">Quote</a>
				<a title="Edit" class="icon-only fa fa-edit" data-remote="true" href="javascript:;">Edit</a>
				<a title="Delete" class="icon-only fa fa-trash" data-remote="true" rel="nofollow" href="javascript:;">Delete</a></span>
				<a href="#note-5" style="display:none;" class="journal-link">#5</a></div>
				<h4><p class="gravatar" data-letters="' + CASE Updated_Emp_Id WHEN 0 THEN 'A' ELSE ISNULL(left(EMP.Emp_First_Name,1),'') END + '"></p>                            
				Updated by <a class="user active" href="javascript:;">' + CASE Updated_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</a>
				<a title="a" href="javascript:;">' + ISNULL(CONVERT(VARCHAR,Task_UpdatedDate),'') + '</a>
				<span id="journal-20679-private_notes" class=""></span></h4><div class="wiki">
				' + dbo.fnc_GetSameTimeTaskAudit(CONVERT(VARCHAR(8),Task_UpdatedDate,108),Task_Id) + '</div></div></div>'
			FROM T0110_Task_Audit WITH(NOLOCK)
			LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON Updated_Emp_Id = EMP.Emp_ID
			WHERE Task_Id = @rTaskId AND Task_NewValue <> '' GROUP BY Task_Id,Emp_First_Name,Emp_Last_Name,Updated_Emp_Id,Task_UpdatedDate --ORDER BY Task_Audit_Id DESC

			SELECT @lHistory = @lHistory + '<div class="journal has-notes"><div id="note-5"><div class="contextual">
				<span class="journal-actions" style="display:none;">
				<a title="Quote" class="icon-only fa fa-comment" data-remote="true" rel="nofollow" href="javascript:;">Quote</a>
				<a title="Edit" class="icon-only fa fa-edit" data-remote="true" href="javascript:;">Edit</a>
				<a title="Delete" class="icon-only fa fa-trash" data-remote="true" rel="nofollow" href="javascript:;">Delete</a></span>
				<a href="#note-5" style="display:none;" class="journal-link">#5</a></div>
				<h4><p class="gravatar" data-letters="' + CASE Created_Emp_Id WHEN 0 THEN 'A' ELSE ISNULL(left(Emp_First_Name,1),'') END + '"></p>                            
				Updated by <a class="user active" href="javascript:;">' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin' ELSE ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') END + '</a>
				<a title="a" href="javascript:;">' + ISNULL(CONVERT(VARCHAR,Task_CreatedDate),'') + '</a>
				<span class=""></span></h4><div class="wiki"><p>' + ISNULL(Task_Title,'') + '<br/>' + ISNULL(TAD.Task_Description,'') + '</p></div></div></div>'			
			FROM
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Detail_Id DESC) AS Rno,TAD.Created_Emp_Id,
				TA.Task_CreatedDate,TAD.Task_Description,Emp_First_Name,Emp_Last_Name,TA.Task_Title
				FROM T0100_Task_Assign TA WITH(NOLOCK)
				INNER JOIN T0110_Task_Detail AS TAD WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
				LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Task_Updated_Emp_Id = EMP.Emp_ID
				WHERE TAD.Task_Id = @rTaskId
			) TAD WHERE Rno = 1
			
			IF @lRoleId = 1 OR @rPrivilegeId = 0
				BEGIN
					SELECT @lTaskResult = '<tr><td colspan="4"><span style="font-weight:bold; font-size:14px;">' + '#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + ' - ' + ISNULL(TAD.Task_Title,'') + '</span>
						<span style="font-weight:bold; font-size:14px;">' + CASE WHEN ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') <> ''
						THEN + ' (Sub Task Of ' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') + ' ' + dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId) + ') ' ELSE '' END + '</span></td></tr>
						<td colspan="4"><span style="font-weight:bold; font-size:14px;">' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin'
						ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + ' On ' +
						CASE TAD.Task_DueDate WHEN '1900-01-01' THEN CONVERT(VARCHAR,TAD.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END + '</span></td></tr>
						<td>Status : </td><td>' + ISNULL(SM.s_Title,'') + '</td><td>Start Date : </td><td>' +
						CASE TAD.Task_DueDate WHEN '1900-01-01' THEN CONVERT(VARCHAR,TAD.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END + '</td></tr>
						<td>Priority : </td><td>' + ISNULL(PRM.pm_Title,'') + '</td><td>Target Date : </td><td>' + CASE TAD.Task_TargetDate WHEN '1900-01-01' THEN '' ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_TargetDate,103),'') END + '</td></tr>
						<td>Category : </td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>Estimated Time : </td><td>' + CONVERT(VARCHAR,ISNULL(TAD.Task_EstimatedTime,'')) + '</td></tr>
						<td>Project : </td><td>' + ISNULL(PM.pr_Title,'') + '</td></tr>'					
					FROM T0100_Task_Assign TAD WITH(NOLOCK)					
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
					WHERE TAD.Task_Id = @rTaskId

					SELECT '<table>' + @lTaskResult + '</table>' AS TaskResult,MultipleDetails = @lMultipleDetails,@lRoleId AS RoleId,@rPrivilegeId AS PriviligeId,						
						SubTasks = @lSubTasks,History = @lHistory,Attachments = @lAttachments,@lMultiUser AS Multiuser,tDescription = TAD.Task_Description,
						ParentId = TAD.Task_ParentId,TaskTypeId = TAD.Task_Type_Id,CategoryId = TAD.Task_Cat_Id,PriorityId = TAD.Priority_Id,StatusId = TAD.Status_Id,
						ProjectId = TAD.Project_Id,EmployeeId = TAD.Assigned_Emp_Id,MultiDatas = @lMultiUser,
						DueDate = CASE TAD.Task_DueDate WHEN '1900-01-01' THEN CONVERT(VARCHAR,TAD.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END,
						TargetDate = CASE TAD.Task_TargetDate WHEN '1900-01-01' THEN '' ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_TargetDate,103),'') END,
						EstimatedTime1 = CONVERT(VARCHAR,ISNULL(TAD.Task_EstimatedTime,'')),TaskTitle = TAD.Task_Title,Code = '#TASK' + CONVERT(VARCHAR,TAD.Task_Id)
					FROM T0100_Task_Assign TAD WITH(NOLOCK) WHERE TAD.Task_Id = @rTaskId
				END
			ELSE
				BEGIN
					SELECT @lTaskResult = '<tr><td colspan="4"><span style="font-weight:bold; font-size:14px;">' + '#TASK' + CONVERT(VARCHAR,TAD.Task_Id) + ' - ' + ISNULL(TAD.Task_Title,'') + '</span>
						<span style="font-weight:bold; font-size:14px;">' + CASE WHEN ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') <> ''
						THEN + ' (Sub Task Of ' + ISNULL(dbo.fnc_GetParentTask(TAD.Task_Id,TAD.Task_ParentId),'') + ' ' + dbo.fnc_GetParentTaskName(TAD.Task_Id,TAD.Task_ParentId) + ') ' ELSE '' END + '</span></td></tr>
						<td colspan="4"><span style="font-weight:bold; font-size:14px;">' + CASE TAD.Created_Emp_Id WHEN 0 THEN 'Admin'
						ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + ' On ' +
						CASE TAD.Task_DueDate WHEN '1900-01-01' THEN CONVERT(VARCHAR,TA.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END + '</span></td></tr>
						<td>Status : </td><td>' + ISNULL(SM.s_Title,'') + '</td><td>Start Date : </td><td>' + CASE TAD.Task_DueDate WHEN '1900-01-01'
						THEN CONVERT(VARCHAR,TA.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END + '</td></tr>
						<td>Priority : </td><td>' + ISNULL(PRM.pm_Title,'') + '</td><td>Target Date : </td><td>' + CASE TAD.Task_TargetDate WHEN '1900-01-01' THEN '' ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_TargetDate,103),'') END + '</td></tr>
						<td>Category : </td><td>' + ISNULL(TCM.tc_Title,'') + '</td><td>Estimated Time : </td><td>' + CONVERT(VARCHAR,ISNULL(TAD.Task_EstimatedTime,'')) + '</td></tr>
						<td>Project : </td><td>' + ISNULL(PM.pr_Title,'') + '</td></tr>'					
					FROM T0100_Task_Assign TA WITH(NOLOCK)
					INNER JOIN T0110_Task_Detail AS TAD WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
					LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Created_Emp_Id = EMP.Emp_ID
					LEFT JOIN T0080_EMP_MASTER AS EMP1 WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP1.Emp_ID
					LEFT JOIN T0040_Task_Project_Master AS PM WITH(NOLOCK) ON TAD.Project_Id = PM.Project_Id
					INNER JOIN T0040_Priority_Master AS PRM WITH(NOLOCK) ON TAD.Priority_Id = PRM.Priority_Id
					INNER JOIN T0040_Tasks_Type_Master AS TTM WITH(NOLOCK) ON TAD.Task_Type_Id = TTM.Task_Type_ID
					INNER JOIN T0040_Task_Category_Master AS TCM WITH(NOLOCK) ON TAD.Task_Cat_Id = TCM.Task_Cat_Id
					INNER JOIN T0040_Status_Master AS SM WITH(NOLOCK) ON TAD.Status_Id = SM.Status_Id
					WHERE TAD.Task_Id = @rTaskId AND TAD.Task_Detail_Id = @rTaskDetailId AND (TAD.Assigned_Emp_Id = @rEmpId or TAD.Created_Emp_Id = @rEmpId)

					SELECT '<table>' + @lTaskResult + '</table>' AS TaskResult,MultipleDetails = @lMultipleDetails,@lRoleId AS RoleId,@rPrivilegeId AS PriviligeId,						
						SubTasks = @lSubTasks,History = @lHistory,Attachments = @lAttachments,@lMultiUser AS Multiuser,tDescription = TAD.Task_Description,
						ParentId = TAD.Task_ParentId,TaskTypeId = TAD.Task_Type_Id,CategoryId = TAD.Task_Cat_Id,PriorityId = TAD.Priority_Id,StatusId = TAD.Status_Id,
						ProjectId = TAD.Project_Id,EmployeeId = TAD.Assigned_Emp_Id,MultiDatas = @lMultiUser,
						DueDate = CASE TAD.Task_DueDate WHEN '1900-01-01' THEN CONVERT(VARCHAR,TA.Task_CreatedDate,103) ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_DueDate,103),'') END,
						TargetDate = CASE TAD.Task_TargetDate WHEN '1900-01-01' THEN '' ELSE ISNULL(CONVERT(VARCHAR,TAD.Task_TargetDate,103),'') END,
						EstimatedTime1 = CONVERT(VARCHAR,ISNULL(TAD.Task_EstimatedTime,'')),TaskTitle = TAD.Task_Title,Code = '#TASK' + CONVERT(VARCHAR,TAD.Task_Id)
					FROM T0100_Task_Assign TA WITH(NOLOCK)
					INNER JOIN T0110_Task_Detail AS TAD WITH(NOLOCK) ON TA.Task_Id = TAD.Task_Id
					WHERE TAD.Task_Id = @rTaskId AND TAD.Task_Detail_Id = @rTaskDetailId AND (TAD.Assigned_Emp_Id = @rEmpId or TAD.Created_Emp_Id = @rEmpId)
				END
		END
END