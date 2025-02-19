


-- =============================================
-- Author:		Sneha
-- ALTER date: 05-Sept-2011
-- Description:	Employee Exit Interview
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Exit_Interview]
@INTERVIEW_ID AS NUMERIC(18,0) = 0,
@EMP_ID AS NUMERIC(18,0) = 0,
@EXIT_ID AS NUMERIC(18,0) = 0,
@QUESTION_ID AS NUMERIC(18,0) = 0,
@CMP_ID AS NUMERIC(18,0) = 0,
@LOGIN_ID AS NUMERIC(18,0) = 0,
@POST_DATE AS DATETIME = NULL,
@STATUS AS CHAR(1) = 'P',
@IS_VIEW AS NUMERIC(1) = 0,
@TRANTYPE AS VARCHAR(1),
-----------QUESTION MASTER--------------
@QUESTION AS VARCHAR(150) = '',
@DESCRIPTION AS VARCHAR(100) = '',
@IS_ACTIVE AS TINYINT = 0

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	-- MODIFIED BY GADRIWALA MUSLIM 30082016 - FLOW CHANGED
	
	--If @cmp_id > 0
	--	Begin
	--		If @question_Id = 0
	--			Begin
	--				If Upper(@trantype) ='I' 
	--					Begin
	--						If exists (Select Question_id from T0200_Exit_Interview WHERE Question_id=@question_id And exit_id = @exit_id) 
	--							Begin					
	--								RAISERROR('This Question has been already assigned',16,2)
	--								RETURN 
	--							End
	--						Else
	--							Begin
	--								exec P0200_Question_Master @question_Id,@cmp_id,@Question,@Description,@Is_Active,@trantype
	--								select @question_Id = Max(question_id) from T0200_Question_Master where Cmp_Id = @cmp_id
	--								select @Interview_Id = isnull(max(Interview_Id),0) + 1 from dbo.T0200_Exit_Interview 
	--									Insert Into T0200_Exit_Interview(
	--									Interview_Id,
	--									emp_id,
	--									exit_id,
	--									Question_Id,
	--									cmp_id,
	--									login_id,
	--									Posted_date,
	--									int_status,
	--									Is_view
	--								)
	--								Values(
	--									@Interview_Id,
	--									@emp_id,
	--									@exit_id,
	--									@question_Id,
	--									@cmp_id,
	--									@login_id,
	--									@post_date,
	--									@status,
	--									@is_view
	--								)
									
	--							End
	--					End
	--			End
	--		Else
	--			Begin
	--				If exists (Select Question_id from T0200_Exit_Interview WHERE Question_id=@question_id And exit_id = @exit_id) 
	--					Begin					
	--						RAISERROR('This Question has been already assigned',16,2)
	--						RETURN 
	--					End
	--				Else
	--					Begin
	--						select @Interview_Id = isnull(max(Interview_Id),0) + 1 from dbo.T0200_Exit_Interview 
							
	--						Insert Into T0200_Exit_Interview(
	--							Interview_Id,
	--							emp_id,
	--							exit_id,
	--							Question_Id,
	--							cmp_id,
	--							login_id,
	--							Posted_date,
	--							int_status,
	--							Is_view
	--						)
	--						Values(
	--							@Interview_Id,
	--							@emp_id,
	--							@exit_id,
	--							@question_Id,
	--							@cmp_id,
	--							@login_id,
	--							@post_date,
	--							@status,
	--							@is_view
	--						)
	--					End
	--				End
			
	--	End
	 IF @QUESTION_ID > 0 
		BEGIN
			IF UPPER(@TRANTYPE) = 'I'
			BEGIN
				IF NOT EXISTS( SELECT 1 FROM T0200_EXIT_INTERVIEW WITH (NOLOCK) WHERE  EMP_ID= @EMP_ID AND CMP_ID = @CMP_ID AND QUESTION_ID= @QUESTION_ID)
					BEGIN
						SELECT @INTERVIEW_ID = ISNULL(MAX(INTERVIEW_ID),0) + 1 FROM DBO.T0200_EXIT_INTERVIEW WITH (NOLOCK)
							
							INSERT INTO T0200_EXIT_INTERVIEW(
								INTERVIEW_ID,
								EMP_ID,
								EXIT_ID,
								QUESTION_ID,
								CMP_ID,
								LOGIN_ID,
								POSTED_DATE,
								INT_STATUS,
								IS_VIEW
							)
							VALUES(
								@INTERVIEW_ID,
								@EMP_ID,
								@EXIT_ID,
								@QUESTION_ID,
								@CMP_ID,
								@LOGIN_ID,
								@POST_DATE,
								@STATUS,
								@IS_VIEW
							)
					END
				ELSE
					BEGIN
						-- ADDED BY GADRIWALA MUSLIM  30082016 - ACTIVE-INACTIVE ASSIGNED QUESTION
							UPDATE T0200_EXIT_INTERVIEW SET IS_ACTIVE = @IS_ACTIVE
							WHERE  EMP_ID= @EMP_ID AND CMP_ID = @CMP_ID 
							AND QUESTION_ID= @QUESTION_ID  
					END	
			
			END
		ELSE IF  UPPER(@TRANTYPE) = 'U'
			BEGIN		
					-- ADDED BY GADRIWALA MUSLIM  30082016 - ACTIVE-INACTIVE ASSIGNED QUESTION
					UPDATE T0200_EXIT_INTERVIEW SET IS_ACTIVE = @IS_ACTIVE
					WHERE  EMP_ID= @EMP_ID AND CMP_ID = @CMP_ID 
					AND QUESTION_ID= @QUESTION_ID  
			END
		END
	



