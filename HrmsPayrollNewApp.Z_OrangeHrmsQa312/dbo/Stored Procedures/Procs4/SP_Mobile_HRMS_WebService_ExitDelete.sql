-- =============================================
-- Author:		satish
-- ALTER date: 29 Jan 2021
-- Description:	<Description,>     
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_ExitDelete]
	@Cmp_ID as numeric(18,0),
	@Exit_ID as numeric(18,0),
	@Status as char,
	@Result VARCHAR(100) OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

   
If @Cmp_ID <> 0
BEGIN	

			If @status = 'H' --H - Pending
				Begin
					If Exists(Select 1 From T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)  --Added By Jaina 14-06-2016
						Begin
							SET @Result = 'You can not delete Application, Already Approved by Scheme level manager.#False#' --Added By Pooja 310822 as per assign ankur sir.
							SELECT @Result
						End
					Else
					BEGIN
					If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
						Begin
						select 777
							
							If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
								Begin
									
									If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@status and cmp_id=@cmp_id and exit_id=@exit_id)
										Begin
											Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
											Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
											Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status =@status
											
											--ADDED BY JAINA 04-06-2016
											DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
											
											 print 4

											SET @Result = 'Record Deleted Successfully#True#'
											SELECT @Result
										End
									
								End
							else
								begin  --Added 15-12-2018
									Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status = @status
									
									 print 3

									SET @Result = 'Record Deleted Successfully#True#'
								    SELECT @Result
								end
						End
					Else
						Begin
							
							Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status = @status
						
							--ADDED BY JAINA 04-06-2016
							DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID

							 print 2

							SET @Result = 'Record Deleted Successfully#True#'
							SELECT @Result
						END
					END
				End

			If @status = 'P' --P - In Process
			Begin
			print 'ssss'
						If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@cmp_id and exit_id=@exit_id)
							Begin
							      print 123
									SET @Result = 'Cannot Delete as Reference Exists#False#'
									SELECT @Result
							End
						Else
							Begin
							print 123.1
								If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@status and cmp_id=@cmp_id and exit_id=@exit_id)
								Begin
									print 123.11
										Select @status=status from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id = @cmp_id and exit_id=@exit_id
										if @status = 'P'
											Begin
											    print 1
												
												Delete From T0200_Exit_Feedback Where cmp_id=@cmp_id and exit_id=@exit_id
												Delete From T0200_Exit_Interview Where cmp_id=@cmp_id and exit_id=@exit_id
												Delete From T0200_Emp_ExitApplication Where cmp_id=@cmp_id and exit_id = @exit_id and status =@status
												
												--ADDED BY JAINA 04-06-2016
												DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @CMP_ID AND EXIT_ID = @EXIT_ID
												  
												SET @Result = 'Record Deleted Successfully#True#'
											    SELECT @Result

									End
									  Else
									    Begin
											print 123111
													SET @Result = 'Cannot Delete as Reference Exists#False#'
													SELECT @Result
											End
										End
							End
			End

		    If @status = 'R'   --R - Reject
			Begin
			 		SET @Result = 'Cannot Delete as Reference Exists#False#'
			 		SELECT @Result
		 	End

		    If @status = 'A'  -- A - Approve
			Begin
					SET @Result = 'Cannot Delete as Reference Exists#False#'
					SELECT @Result
			End
	 
END
			 
			--If @Status = 'H' --H - Pending
			--	Begin
			--		If Exists(Select 1 From T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK) Where cmp_id=@Cmp_ID and exit_id=@Exit_ID)  --Added By Jaina 14-06-2016
			--			Begin
			--				SET @Result = 'Cannot Delete as Reference Exists#False#'
			--				SELECT @Result
			--			End
			--		Else
			--		BEGIN
			--		If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id=@Cmp_ID and exit_id=@Exit_ID)
			--			Begin
							
			--				If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@Cmp_ID and exit_id=@Exit_ID)
			--					Begin
									
			--						If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@Status and cmp_id=@Cmp_ID and exit_id=@Exit_ID)
			--							Begin
			--								Delete From T0200_Exit_Feedback Where cmp_id=@Cmp_ID and exit_id=@Exit_ID
			--								Delete From T0200_Exit_Interview Where cmp_id=@Cmp_ID and exit_id=@Exit_ID
			--								Delete From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and exit_id = @Exit_ID and status =@Status
											
			--								--ADDED BY JAINA 04-06-2016
			--								DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @Cmp_ID AND EXIT_ID = @Exit_ID
											
			--								SET @Result = 'Record Deleted Successfully#True#'
			--								SELECT @Result
			--							End
									
			--					End
			--				else
			--					begin  --Added 15-12-2018
			--						Delete From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and exit_id = @Exit_ID and status = @Status
									
			--						SET @Result = 'Record Deleted Successfully#True#'
			--						SELECT @Result
			--					end
			--			End
			--		Else
			--			Begin
							
			--				Delete From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and exit_id = @Exit_ID and status = @Status
						
			--				--ADDED BY JAINA 04-06-2016
			--				DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @Cmp_ID AND EXIT_ID = @Exit_ID

			--				SET @Result = 'Record Deleted Successfully#True#'
			--				SELECT @Result
			--			END
			--		END
			--	End
			--	If @Status = 'P' --P - In Process
			--		Begin
			--			If Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id=@Cmp_ID and exit_id=@Exit_ID)
			--				Begin
			--					SET @Result = 'Cannot Delete as Reference Exists#False#'
			--					SELECT @Result
			--				End
			--			Else
			--				Begin
			--					If Exists(Select 1 From T0200_Emp_ExitApplication WITH (NOLOCK) Where status=@Status and cmp_id=@Cmp_ID and exit_id=@Exit_ID)
			--						Begin
			--							Select @Status=status from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id = @Cmp_ID and exit_id=@Exit_ID
			--							if @Status = 'P'
			--								Begin
			--									Delete From T0200_Exit_Feedback Where cmp_id=@Cmp_ID and exit_id=@Exit_ID
			--									Delete From T0200_Exit_Interview Where cmp_id=@Cmp_ID and exit_id=@Exit_ID
			--									Delete From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and exit_id = @Exit_ID and status =@Status
												
			--									--ADDED BY JAINA 04-06-2016
			--									DELETE FROM T0300_EMP_EXIT_APPROVAL_LEVEL WHERE CMP_ID = @Cmp_ID AND EXIT_ID = @Exit_ID

			--									SET @Result = 'Record Deleted Successfully#True#'
			--									SELECT @Result
			--								End
			--							Else
			--								Begin
			--									SET @Result = 'Cannot Delete as Reference Exists#False#'
			--									SELECT @Result
			--								End
			--							End
			--				End
			--		End
			--	Else If @Status = 'R'   --R - Reject
			--		Begin
			--			SET @Result = 'Cannot Delete as Reference Exists#False#'
			--			SELECT @Result
			--		End
			--	Else If @Status = 'A'  -- A - Approve
			--		Begin
			--			SET @Result = 'Cannot Delete as Reference Exists#False#'
			--			SELECT @Result
			--		End
END


