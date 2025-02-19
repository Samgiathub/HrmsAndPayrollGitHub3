-- EXEC P0100_TASK_ASSIGN_COUNTS 0,0
-- DROP PROCEDURE P0100_TASK_ASSIGN_COUNTS
CREATE PROCEDURE P0100_TASK_ASSIGN_COUNTS
@rEmpId INT,
@rPrivilegeId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @lRoleId INT,@lFinalStatusId int
	
	DECLARE @lTypeResult VARCHAR(MAX) = '',@lCatResult VARCHAR(MAX) = '',@lProResult VARCHAR(MAX) = '',@lPriResult VARCHAR(MAX) = ''
	DECLARE @lUserResult VARCHAR(MAX) = '',@lNewsDetails VARCHAR(MAX) = ''

	SELECT @lRoleId = Role_Id FROM T0100_Emp_Role_Assign WHERE Emp_Id = @rEmpId
	SELECT @lFinalStatusId = Status_Id from T0040_Status_Master where (s_IsFinal = 1 OR s_Percentage = 100)
	
	CREATE TABLE #TASK_TEMP
	(
		tid INT IDENTITY(1,1),t_Id INT,t_Row INT
	)
	IF @lRoleId = 1 OR @rPrivilegeId = 0
		BEGIN			
			INSERT INTO #TASK_TEMP
			SELECT Task_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Id DESC) AS rn
			FROM T0100_Task_Assign AS TAD WITH(NOLOCK)			
		END
	ELSE
		BEGIN
			INSERT INTO #TASK_TEMP
			SELECT Task_Id,ROW_NUMBER() OVER (PARTITION BY TAD.Task_Id ORDER BY Task_Id DESC) AS rn
			FROM T0100_Task_Assign AS TAD WITH(NOLOCK)			
			WHERE (TAD.Assigned_Emp_Id = @rEmpId OR TAD.Created_Emp_Id = @rEmpId)
		END
	
	SELECT TOP 10 @lNewsDetails = @lNewsDetails + '<p><a href="javascript:;">' + TAD.Task_Log_Comments + ' ' + CONVERT(VARCHAR,TAD.Task_UpdatedDate) + '</a>
		<br><span class="summary">' + ISNULL(left(TAD.Task_Log_Comments,100),'') + ' ' + CONVERT(VARCHAR,TAD.Task_UpdatedDate) + '
		and ' + ISNULL(left(TAD.Task_Log_Notes,100),'') + '</span><br>
		<span class="author">Added by <a class="user active" href="javascript:;">' + CASE TAD.Task_Updated_Emp_Id WHEN 0 THEN 'Admin'
		ELSE ISNULL(EMP.Initial,'') + ' ' + ISNULL(EMP.Emp_First_Name,'') + ' ' + ISNULL(EMP.Emp_Last_Name,'') END + '</a>
		<a href="javascript:;">' + CONVERT(VARCHAR,TAD.Task_UpdatedDate) + '</a></span></p>'
	FROM T0110_Task_Detail TAD WITH(NOLOCK)
	LEFT JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON TAD.Assigned_Emp_Id = EMP.Emp_ID
	WHERE TAD.Task_UpdatedDate IS NOT NULL
	
	SELECT @lTypeResult = @lTypeResult + '<tr><td>' + ISNULL(ttm_Title,'') + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id > 1 AND Status_Id <> @lFinalStatusId AND TA1.Task_Type_Id = TA.Task_Type_Id),0)) + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id = @lFinalStatusId AND TA1.Task_Type_Id = TA.Task_Type_Id),0)) + '</td></tr>'	
	FROM T0100_Task_Assign TA WITH(NOLOCK)
	INNER JOIN T0040_Tasks_Type_Master TTM WITH(NOLOCK) ON ta.Task_Type_Id = ttm.Task_Type_Id,#TASK_TEMP
	WHERE TA.Task_Id = t_Id
	GROUP BY ttm_Title,TA.Task_Type_Id

	SELECT @lCatResult = @lCatResult + '<tr><td>' + ISNULL(tc_Title,'') + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id > 1 AND Status_Id <> @lFinalStatusId AND TA1.Task_Cat_Id = TA.Task_Cat_Id),0)) + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id = @lFinalStatusId AND TA1.Task_Cat_Id = TA.Task_Cat_Id),0)) + '</td></tr>'
	FROM T0100_Task_Assign TA WITH(NOLOCK)
	INNER JOIN T0040_Task_Category_Master TTM WITH(NOLOCK) on ta.Task_Cat_Id = ttm.Task_Cat_Id,#TASK_TEMP
	WHERE TA.Task_Id = t_Id
	GROUP BY tc_Title,TA.Task_Cat_Id

	SELECT @lProResult = @lProResult + '<tr><td>' + ISNULL(pr_Title,'') + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id > 1 AND Status_Id <> @lFinalStatusId AND TA1.Project_Id = TA.Project_Id),0)) + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id = @lFinalStatusId AND TA1.Project_Id = TA.Project_Id),0)) + '</td></tr>'
	FROM T0100_Task_Assign TA WITH(NOLOCK)
	INNER JOIN T0040_Task_Project_Master TTM WITH(NOLOCK) on ta.Project_Id = ttm.Project_Id,#TASK_TEMP
	WHERE TA.Task_Id = t_Id
	GROUP BY pr_Title,TA.Project_Id

	SELECT @lPriResult = @lPriResult + '<tr><td>' + ISNULL(pm_Title,'') + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id > 1 AND Status_Id <> @lFinalStatusId AND TA1.Priority_Id = TA.Priority_Id),0)) + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0100_Task_Assign TA1 where Status_Id = @lFinalStatusId AND TA1.Priority_Id = TA.Priority_Id),0)) + '</td></tr>'
	FROM T0100_Task_Assign TA WITH(NOLOCK)
	INNER JOIN T0040_Priority_Master TTM WITH(NOLOCK) on ta.Priority_Id = ttm.Priority_Id,#TASK_TEMP
	WHERE TA.Task_Id = t_Id
	GROUP BY pm_Title,TA.Priority_Id

	SELECT @lUserResult = @lUserResult + '<tr><td>' + ISNULL(Emp_First_Name,'') + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0110_Task_Detail TA1 where Status_Id > 1 AND Status_Id <> @lFinalStatusId AND TA.Assigned_Emp_Id = TA1.Assigned_Emp_Id AND TA1.Task_IsActive = 1),0)) + '</td>
		<td>' + CONVERT(VARCHAR,ISNULL((select count(1) from T0110_Task_Detail TA1 where Status_Id = @lFinalStatusId AND TA.Assigned_Emp_Id = TA1.Assigned_Emp_Id AND TA1.Task_IsActive = 1),0)) + '</td></tr>'
	FROM T0110_Task_Detail TA WITH(NOLOCK)	
	INNER JOIN T0080_EMP_MASTER TTM WITH(NOLOCK) on TA.Assigned_Emp_Id = TTM.Emp_ID,#TASK_TEMP
	WHERE TA.Task_Id = t_Id AND TA.Task_IsActive = 1
	GROUP BY Assigned_Emp_Id,Emp_First_Name
	
	SELECT @lTypeResult AS TypeResult,@lCatResult AS CatResult,@lProResult AS ProResult,
	@lPriResult AS PriResult,@lNewsDetails AS NewsDetails,@lUserResult AS UserResult
END