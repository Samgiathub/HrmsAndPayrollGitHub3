


-- =============================================
-- Author:		Patel Nilesh
-- Create date: 01-08-2017 
-- Description:	Monthly Miss Punch reminder 
-- =============================================
CREATE PROCEDURE Monthly_Miss_Punch_Reminder
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
	SET NOCOUNT ON;
	Exec SP_Employee_Missing_Punch_reminder @cmp_id_Pass,@CC_Email,1
END

