



-- =============================================
-- Author:		Sneha
-- ALTER date: 30 mar 2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_DeleteExit]
	@cmp_id as numeric(18,0),
	@exit_id as numeric(18,0),
	@status as char
	--ronakb081024
	,@User_Id NUMERIC(18, 0) = 0
	,@IP_Address VARCHAR(30) = ''
AS
BEGIN
	
			SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	--ronakb081024
	DECLARE @OldValue AS VARCHAR(max)

	SET @OldValue = ''

	If @cmp_id <> 0
		Begin
			If @status = 'H' --H - Pending
				Begin
					If Exists(Select 1 From T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)  --Added By Jaina 14-06-2016
						Begin
							RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
							Select @@Error
						End
					Else
					BEGIN
					If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
						Begin
							
							If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
								Begin
									
									If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@status and cmp_id=@cmp_id and exit_id=@exit_id)
										Begin
											Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
											Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
											Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status =@status
											
											--ADDED BY JAINA 04-06-2016
											DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
										End
									
								End
							else
								begin  --Added 15-12-2018
									Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status = @status
								end
						End
					Else
						Begin
							
							Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status = @status
						
							--ADDED BY JAINA 04-06-2016
							DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
						END
					END
				End
				If @status = 'P' --P - In Process
					Begin
						If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
							Begin
								RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
								Select @@Error
							End
						Else
							Begin
								If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@status and cmp_id=@cmp_id and exit_id=@exit_id)
									Begin
										Select @status=status from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id = @cmp_id and exit_id=@exit_id
										if @status = 'P'
											Begin
												Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
												Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
												Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status =@status
												
												--ADDED BY JAINA 04-06-2016
												DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
											End
										Else
											Begin
												RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
												Select @@Error
											End
										End
							End
					End
				Else If @status = 'R'   --R - Reject
					Begin
						RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
						Select @@Error
					End
				Else If @status = 'A'  -- A - Approve
					Begin
						RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
						Select @@Error
					End
				--ronakb081024
				EXEC P9999_Audit_Trail @Cmp_ID
					,'D'
					,'ExitApplication'
					,@OldValue
					,@exit_id
					,@User_Id
					,@IP_Address
		End
END


