-- EXEC P0040_TASK_ACTIVITY_MASTER
-- DROP PROCEDURE P0040_TASK_ACTIVITY_MASTER
CREATE PROCEDURE P0040_TASK_ACTIVITY_MASTER
@rMainId INT,
@rStatus INT,
@rType INT,
@risEdit INT = NULL,
@risSave INT = NULL,
@risDelete INT = NULL,
@rCode VARCHAR(50),
@rTitle VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @rType = 1
		BEGIN
			IF @rMainId = 0
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Task_Activity_Master WHERE am_Code = @rCode and am_Status < 2)
						BEGIN
							SELECT -101 res
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Activity_Master WHERE am_Title = @rTitle and am_Status < 2)
						BEGIN
							SELECT -102 res
							RETURN
						END

					IF @risSave = 0
						BEGIN
							SELECT -103 res
							RETURN
						END

					INSERT INTO T0040_Task_Activity_Master(am_Code,am_Title)
					SELECT @rCode,@rTitle

					SELECT 1 AS res
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Task_Activity_Master WHERE am_Code = @rCode and am_Status < 2 and Activity_Id <> @rMainId)
						BEGIN
							SELECT -101
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Activity_Master WHERE am_Title = @rTitle and am_Status < 2 and Activity_Id <> @rMainId)
						BEGIN
							SELECT -102
							RETURN
						END

					IF @risEdit = 0
						BEGIN
							SELECT -104 res
							RETURN
						END

					UPDATE T0040_Task_Activity_Master SET am_Code = @rCode,am_Title = @rTitle,am_UpdatedDate = GETDATE() WHERE Activity_Id = @rMainId

					SELECT @rMainId AS res
				END
		END
	ELSE IF @rType = 2
		BEGIN
			IF @rStatus = 2
			BEGIN
				IF @risDelete = 0
					BEGIN
						SELECT -105 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0110_Task_Detail WHERE Activity_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Task_Activity_Master SET am_Status = @rStatus WHERE Activity_Id = @rMainId

				SELECT 1 res
			END
			ELSE
			BEGIN
				IF @risEdit = 0
					BEGIN
						SELECT -104 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0110_Task_Detail WHERE Activity_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END
				
				UPDATE T0040_Task_Activity_Master SET am_Status = CASE WHEN @rStatus = 1 THEN 0 ELSE 1 END WHERE Activity_Id = @rMainId

				SELECT 1 res
			END
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT ISNULL(Activity_Id,0) AS am_Id,ISNULL(am_Code,'') AS Code,ISNULL(am_Title,'') AS Title
			FROM T0040_Task_Activity_Master WITH(NOLOCK) WHERE Activity_Id = @rMainId
		END
END