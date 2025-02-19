



-- =============================================
-- Author:		Sneha
-- ALTER date: 26 Mar 2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_PreQuestionExit]
@Interview_Id as numeric(18,0),
@emp_id as numeric(18,0),
@exit_id as numeric(18,0),
@question_Id as numeric(18,0),
@cmp_id as numeric(18,0),
@login_id as numeric(18,0),
@post_date as datetime,
@status as char(1),
@is_view as numeric(1)
--@trantype as varchar(1)


AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	If @cmp_id<>0
		Begin
			If @exit_id<>0
				Begin
					If @Interview_Id = 0
						Begin
							--CHECK DUPLICATION
						  IF Not EXISTS(SELECT QUESTION_ID FROM T0200_Exit_Interview WITH (NOLOCK) WHERE emp_id=@emp_id AND cmp_id = @cmp_id AND Question_Id=@question_Id and exit_id=@exit_id)
							Begin
								select @Interview_Id = isnull(max(Interview_Id),0) + 1 from dbo.T0200_Exit_Interview WITH (NOLOCK)
								
								Insert Into T0200_Exit_Interview(
									Interview_Id,
									emp_id,
									exit_id,
									Question_Id,
									cmp_id,
									login_id,
									Posted_date,
									int_status,
									Is_view
								)
								Values(
									@Interview_Id,
									@emp_id,
									@exit_id,
									@question_Id,
									@cmp_id,
									@login_id,
									@post_date,
									@status,
									@is_view
								)
							End
						End
				End
			Else If @exit_id = 0
				Begin
					Select @exit_id = MAX(exit_id)+1 From T0200_Emp_ExitApplication WITH (NOLOCK)
					select @Interview_Id = isnull(max(Interview_Id),0) + 1 from dbo.T0200_Exit_Interview WITH (NOLOCK)
					Insert Into T0200_Exit_Interview(
							Interview_Id,
							emp_id,
							
							Question_Id,
							cmp_id,
							login_id,
							Posted_date,
							int_status,
							Is_view
						)
						Values(
							@Interview_Id,
							@emp_id,
							
							@question_Id,
							@cmp_id,
							@login_id,
							@post_date,
							@status,
							@is_view
						)
				End
		End


