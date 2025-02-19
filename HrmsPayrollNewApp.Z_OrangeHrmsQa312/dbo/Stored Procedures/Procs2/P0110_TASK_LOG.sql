-- EXEC P0110_TASK_LOG
-- DROP PROCEDURE P0110_TASK_LOG
CREATE PROCEDURE [dbo].[P0110_TASK_LOG]
@rTaskId INT,
@rTaskDetailId INT,
@rActivityId INT,
@rComment VARCHAR(MAX),
@rDueDate VARCHAR(50),
@rDuration VARCHAR(50),
@rCreatedEmpId INT
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	SELECT @rDueDate = CASE @rDueDate WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rDueDate, 105), 23) END

	DECLARE @Tasks TABLE(tid INT IDENTITY(1,1),t_TaskDetailId INT)
	INSERT INTO @Tasks
	SELECT Task_Detail_Id FROM T0110_Task_Detail WHERE Task_Id = @rTaskId and Task_IsActive = 1

	UPDATE T0110_Task_Detail SET Task_IsActive = 0 WHERE Task_Id = @rTaskId

	IF @rCreatedEmpId = 0
		BEGIN
			INSERT INTO T0110_Task_Detail
			(
				Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
				Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_Updated_Emp_Id,Activity_Id,
				Task_Log_Hours,Task_Log_Comments,Task_UpdatedDate,Task_IsActive
			)
			SELECT Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,@rCreatedEmpId,Task_Title,
			Task_Description,Task_DueDate,Task_TargetDate,@rDuration,@rCreatedEmpId,@rActivityId,@rDuration,@rComment,GETDATE(),1
			FROM T0110_Task_Detail INNER JOIN @Tasks ON Task_Detail_Id = t_TaskDetailId WHERE Task_Id = @rTaskId
		END
	ElSE
		BEGIN
			INSERT INTO T0110_Task_Detail
			(
				Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,Created_Emp_Id,
				Task_Title,Task_Description,Task_DueDate,Task_TargetDate,Task_EstimatedTime,Task_Updated_Emp_Id,Activity_Id,
				Task_Log_Hours,Task_Log_Comments,Task_UpdatedDate,Task_IsActive
			)
			SELECT Task_Id,Task_ParentId,Task_Type_Id,Task_Cat_Id,Status_Id,Priority_Id,Project_Id,Assigned_Emp_Id,@rCreatedEmpId,Task_Title,
			Task_Description,Task_DueDate,Task_TargetDate,@rDuration,@rCreatedEmpId,@rActivityId,@rDuration,@rComment,GETDATE(),1
			FROM T0110_Task_Detail INNER JOIN @Tasks ON Task_Detail_Id = t_TaskDetailId WHERE Task_Id = @rTaskId AND Task_Detail_Id = @rTaskDetailId
		END
	
	IF @rComment <> ''
		BEGIN
			INSERT INTO T0110_Task_Audit
			(
				Task_Id,Task_Detail_Id,Task_Field,Task_OldValue,Task_NewValue,Updated_Emp_Id
			)
			SELECT @rTaskId,@rTaskDetailId,'Commented',@rComment,@rComment,@rCreatedEmpId
		END
END