



-- =============================================
-- Author:		Sneha
-- ALTER date: 02/04/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_GetInterviewNotice]
	@cmp_id as numeric(18,0),
	@emp_id as numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	Declare @exitid as numeric(18,0)
	
If @cmp_id <>0
	Begin
		Select @exitid =  MAX(exit_id) from T0200_Emp_ExitApplication WITH (NOLOCK) Where cmp_id = @cmp_id and emp_id=@emp_id
		
		Select exit_feedback_id from T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id = @cmp_id and emp_id=@emp_id and exit_id=@exitid 
	End
   
END



