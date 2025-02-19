-- select dbo.fnc_GetSameTimeTaskAudit('14:06:00',1)
-- drop function dbo.fnc_GetSameTimeTaskAudit
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[fnc_GetSameTimeTaskAudit](@TaskTime TIME,@TaskId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SELECT @lResult = @lResult + '<li>' + CASE WHEN Task_Field <> 'Commented' AND Task_Field <> 'Notes Added' AND Task_Field <> 'Assignee' THEN
	ISNULL(Task_Field,'') + ' Changed From ' + ISNULL(Task_OldValue,'') + ' To ' + ISNULL(Task_NewValue,'')	
	WHEN Task_Field = 'Assignee' THEN ISNULL(Task_Field,'') + ISNULL(Task_OldValue,'') + ISNULL(Task_NewValue,'') ELSE ISNULL(Task_NewValue,'') END + '</li>'
	FROM T0110_Task_Audit WITH (NOLOCK) WHERE CONVERT(VARCHAR(8),Task_UpdatedDate,108) = @TaskTime AND Task_Id = @TaskId AND Task_NewValue <> ''

	RETURN @lResult
END