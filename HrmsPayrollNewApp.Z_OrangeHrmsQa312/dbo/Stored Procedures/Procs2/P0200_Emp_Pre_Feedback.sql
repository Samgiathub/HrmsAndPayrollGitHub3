



-- =============================================
-- Author:		Sneha
-- ALTER date: 29 Mar 2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Emp_Pre_Feedback]
@exit_feedback_id as numeric(18,0) ,
@emp_id as numeric(18,0),
@exit_id as numeric(18,0),
@cmp_id as numeric(18,0),
@question_id as numeric(18,0),
@answer_rate as numeric(18,0),
@comments as varchar(100),
@feed_status as char(1),
@Is_Draft as tinyint = 0  --Added by Jaina 21-08-2018

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
		If @cmp_id <> 0
			Begin
					select @exit_feedback_id = isnull(max(exit_feedback_id),0) + 1 from dbo.T0200_Exit_Feedback WITH (NOLOCK)
					
					insert into T0200_Exit_Feedback(
						exit_feedback_id,
						emp_id,
						cmp_id,
						question_id,
						Answer_rate,
						Comments,
						feed_status,
						Is_Draft
					)
					values
					(
						@exit_feedback_id,
						@emp_id,
						@cmp_id,
						@question_id,
						@answer_rate,
						@comments,
						@feed_status,
						@Is_Draft
					)
				end
			End		




