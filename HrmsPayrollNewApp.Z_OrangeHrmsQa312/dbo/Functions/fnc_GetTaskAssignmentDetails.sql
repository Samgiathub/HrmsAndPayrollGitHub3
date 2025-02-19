-- select dbo.fnc_GetTaskAssignmentDetails(1)
-- drop function dbo.fnc_GetTaskAssignmentDetails
CREATE FUNCTION [dbo].[fnc_GetTaskAssignmentDetails](@TaskId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SELECT @lResult = STUFF((SELECT distinct ', ' + ISNULL(EMP1.Initial,'') + ' ' + ISNULL(EMP1.Emp_First_Name,'') + ' ' + ISNULL(EMP1.Emp_Last_Name,'')
	FROM T0080_EMP_MASTER AS EMP1 WITH (nolock)
	inner join T0110_Task_Detail TATAD WITH (nolock) on emp1.Emp_ID = TATAD.Assigned_Emp_Id
	where TATAD.Task_Id = @TaskId AND Task_IsActive = 1 FOR XML PATH ('')), 1, 1, '')

	RETURN @lResult
END