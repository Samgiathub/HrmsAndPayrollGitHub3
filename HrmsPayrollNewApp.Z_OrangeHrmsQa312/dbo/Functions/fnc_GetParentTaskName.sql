-- select dbo.fnc_GetParentTaskName(1,1)
-- drop function dbo.fnc_GetParentTaskName
CREATE FUNCTION [dbo].[fnc_GetParentTaskName](@TaskId INT,@ParentId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SELECT @lResult = Task_Title FROM T0100_Task_Assign WITH(NOLOCK) WHERE Task_Id = @ParentId

	RETURN ISNULL(@lResult,'')
END