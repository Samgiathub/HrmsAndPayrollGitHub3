-- select dbo.fnc_GetParentTask(1,1)
-- drop function dbo.fnc_GetParentTask
CREATE FUNCTION [dbo].[fnc_GetParentTask](@TaskId INT,@ParentId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SELECT @lResult = '#TASK' + CONVERT(VARCHAR,Task_Id) FROM T0100_Task_Assign WITH(NOLOCK) WHERE Task_Id = @ParentId

	RETURN ISNULL(@lResult,'')
END