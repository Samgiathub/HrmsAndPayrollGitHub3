


-- =============================================
-- Author:		Patel Nilesh
-- Create date: 01-08-2017 
-- Description:	Monthly Miss Punch reminder 
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Weekly_Miss_Punch_Reminder]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Exec SP_Employee_Missing_Punch_reminder @cmp_id_Pass,@CC_Email,2
END

