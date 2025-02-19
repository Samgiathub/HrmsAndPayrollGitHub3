
--[{"QueTypeWord":"RadioButtonList","QUEST_ID":62,"QUESTION":"Better career opportunity","Answer_rate":"0","Comments":""}]

--EXEC P0200_EMP_EXIT_APPLICATION_INSERT 120,11,11,1,
--[{"QUEST_ID":62,"QUESTION":"Better career opportunity","Answer_rate":"0","Comments":""}]

--EXEC P0200_EMP_EXIT_APPLICATION_INSERT 
--[{"QUEST_ID":62,"QUESTION":"Better career opportunity","Answer_rate":"0","Comments":""}]

CREATE PROCEDURE [dbo].[P0200_EMP_EXIT_APPLICATION_INSERT]
@CMP_ID AS NUMERIC(18,0),
@EMP_ID AS NUMERIC(18,0),
@EXIT_ID AS NUMERIC(18,0),
@QUEST_ID AS NUMERIC(18,0),
@Answer_rate AS VARCHAR(150),
@Comments AS VARCHAR(350)
AS
        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	DECLARE @EXIT_FEEDBACK_ID AS NUMERIC(18,0) 
		IF @CMP_ID > 0
			BEGIN
					SELECT @EXIT_FEEDBACK_ID = ISNULL(MAX(EXIT_FEEDBACK_ID),0) + 1 FROM DBO.T0200_EXIT_FEEDBACK WITH (NOLOCK)
					
					INSERT INTO T0200_EXIT_FEEDBACK(
						EXIT_FEEDBACK_ID,
						cmp_id,
						emp_id,
						exit_id,
						question_id,
						Answer_rate,
						Comments
					)
				
					VALUES
					(
						@EXIT_FEEDBACK_ID,
						@CMP_ID,
						@EMP_ID,
						@EXIT_ID,
						@QUEST_ID,
						@Answer_rate,
						@Comments
					)

					RETURN 
		END
END		




