



-- =============================================
-- Author:		Sneha
-- ALTER date: 04/10/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Emp_exitdup]
	 @emp_id as numeric(18,0),
	 @cmp_id as numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
Declare @exp as numeric(18,0)
    -- Insert statements for procedure here
	if exists(select emp_id from T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id)
		begin
			select  @exp=Max(exit_id) from T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id 
			If exists (select status from T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id = @emp_id and exit_id = @exp and status='R')
				Begin
					Select status from T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id = @emp_id and exit_id = @exp and status='R'
				End
			Else
				Begin
					RAISERROR ('This employee has already applied for exit', 16, 2) 
					Select @@Error
					--Return -1
				End
		end
	
END




