


-- =============================================
-- Author:		Sneha
-- ALTER date: 27 feb 2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_NotifyEmp_Interview]
@Cmp_id as numeric(18,0),
@Emp_id as numeric(18,0)	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	Declare @exitid as numeric(18,0)
	
	
    IF @Cmp_id > 0
		Begin
		  --  If Exists(Select 1 From T0200_Emp_ExitApplication Where cmp_id = @Cmp_id and emp_id= @Emp_id And Is_Process= 'Y' and status='P')
				--Begin
					
				--	Select @exitid = MAX(exit_id) From T0200_Emp_ExitApplication Where cmp_id = @Cmp_id and emp_id= @Emp_id And status='P'
				--	If  Exists(Select 1 From T0200_Exit_Interview Where cmp_id = @Cmp_id and exit_id =@exitid)
				--		Begin 
						
				--			If Not Exists(Select 1 From T0200_Exit_Feedback Where cmp_id = @Cmp_id and emp_id =@Emp_id and exit_id =@exitid)
				--			Begin
				--				Select interview_date,interview_time from T0200_Emp_ExitApplication Where emp_id = @Emp_id and cmp_id = @Cmp_id and status='P'
				--			End
				--		End
				--End
				
				--Added by Jaina 21-08-2018													
				Select @exitid = MAX(exit_id) From T0200_Emp_ExitApplication WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id= @Emp_id 								
				
				If  Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id = @Cmp_id and exit_id =@exitid)
				Begin 						
						If Not Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id =@Emp_id and exit_id =@exitid)
							Begin
								Select interview_date,interview_time from T0200_Emp_ExitApplication WITH (NOLOCK) Where emp_id = @Emp_id and cmp_id = @Cmp_id 
							End
						else
							begin
								If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id =@Emp_id and exit_id =@exitid and is_draft = 1)
								Begin
									Select interview_date,interview_time from T0200_Emp_ExitApplication WITH (NOLOCK) Where emp_id = @Emp_id and cmp_id = @Cmp_id 
								End								
							end
				End
		End
    
END




