



-- =============================================
-- Author:		Sneha
-- ALTER date: 21/12/2012
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_SuperiorExitAlert]
	@cmp_id as numeric(18,0),
	@s_emp_id as numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	If @cmp_id <> 0
		Begin
			IF exists(select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id= @cmp_id and s_emp_id= @s_emp_id)
				begin
					If   exists (Select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id = @cmp_id and s_emp_id=@s_emp_id)
						begin

							select COUNT(exit_id)as exit_id from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id = @cmp_id and s_emp_id = @s_emp_id and status= 'H'
						End
				End
		End
END




