-- EXEC P0040_TASK_PRIORITY_MASTER
-- DROP PROCEDURE P0040_TASK_PRIORITY_MASTER
CREATE PROCEDURE P0040_TASK_PRIORITY_MASTER
@rMainId INT,
@rStatus INT,
@rType INT,
@risEdit INT = NULL,
@risSave INT = NULL,
@risDelete INT = NULL,
@rCode VARCHAR(50),
@rTitle VARCHAR(200),
@rColor VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @rType = 1
		BEGIN
			IF @rMainId = 0
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Priority_Master WHERE pm_Code = @rCode and pm_Status < 2)
						BEGIN
							SELECT -101 res
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Priority_Master WHERE pm_Title = @rTitle and pm_Status < 2)
						BEGIN
							SELECT -102 res
							RETURN
						end

					IF @risSave = 0
						BEGIN
							SELECT -103 res
							RETURN
						END

					INSERT INTO T0040_Priority_Master(pm_Code,pm_Title,pm_Color)
					SELECT @rCode,@rTitle,@rColor

					SELECT 1 AS res
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Priority_Master WHERE pm_Code = @rCode and pm_Status < 2 and Priority_Id <> @rMainId)
						BEGIN
							SELECT -101
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Priority_Master WHERE pm_Title = @rTitle and pm_Status < 2 and Priority_Id <> @rMainId)
						BEGIN
							SELECT -102
							RETURN
						END

					IF @risEdit = 0
						BEGIN
							SELECT -104 res
							RETURN
						END

					UPDATE T0040_Priority_Master SET pm_Code = @rCode,pm_Title = @rTitle,
					pm_UpdatedDate = GETDATE(),pm_Color = @rColor
					WHERE Priority_Id = @rMainId

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

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Priority_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Priority_Master SET pm_Status = @rStatus WHERE Priority_Id = @rMainId
				SELECT 1 res
			END
			ELSE
			BEGIN
				IF @risEdit = 0
					BEGIN
						SELECT -104 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Priority_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				update T0040_Priority_Master SET pm_Status = CASE WHEN @rStatus = 1 THEN 0 ELSE 1 END WHERE Priority_Id = @rMainId
				SELECT 1 res
			END
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT ISNULL(Priority_Id,0) AS pm_Id,ISNULL(pm_Code,'') AS Code,ISNULL(pm_Title,'') AS Title,ISNULL(pm_Color,'') AS Color
			FROM T0040_Priority_Master WITH(NOLOCK) WHERE Priority_Id = @rMainId
		END
END