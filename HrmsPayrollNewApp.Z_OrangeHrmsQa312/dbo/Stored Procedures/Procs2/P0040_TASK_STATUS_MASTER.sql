-- EXEC P0040_TASK_STATUS_MASTER
-- DROP PROCEDURE P0040_TASK_STATUS_MASTER
CREATE PROCEDURE [dbo].[P0040_TASK_STATUS_MASTER]
@rMainId int,
@rStatus int,
@rType int,
@risEdit INT = NULL,
@risSave INT = NULL,
@risDelete INT = NULL,
@rIsDefault INT = NULL,
@rIsFinal INT = NULL,
@rPercentage int,
@rCode varchar(50),
@rTitle varchar(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @rType = 1
		BEGIN
			IF @rMainId = 0
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Status_Master WHERE s_Code = @rCode and s_Status < 2)
						BEGIN
							SELECT -101 res
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Status_Master WHERE s_Title = @rTitle and s_Status < 2)
						BEGIN
							SELECT -102 res
							RETURN
						END

					IF @risSave = 0
						BEGIN
							SELECT -103 res
							RETURN
						END

					INSERT INTO T0040_Status_Master(s_Code,s_Title,s_Percentage,s_IsDefault,s_IsFinal)
					SELECT @rCode,@rTitle,@rPercentage,@rIsDefault,@rIsFinal

					SELECT @rMainId = SCOPE_IDENTITY()
				if(@rIsDefault)=1
				BEGIN
					UPDATE T0040_Status_Master SET s_IsDefault = 0,s_IsFinal = 0 WHERE Status_Id <> @rMainId
				END	
					SELECT 1 AS res
				
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Status_Master WHERE s_Code = @rCode and s_Status < 2 and Status_Id <> @rMainId)
						BEGIN
							SELECT -101
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Status_Master WHERE s_Title = @rTitle and s_Status < 2 and Status_Id <> @rMainId)
						BEGIN
							SELECT -102
							RETURN
						END

					IF @risEdit = 0
						BEGIN
							SELECT -104 res
							RETURN
						END

					UPDATE T0040_Status_Master SET s_IsDefault = 0 WHERE Status_Id <> @rMainId

					UPDATE T0040_Status_Master SET s_Code = @rCode,s_Title = @rTitle,s_UpdatedDate = GETDATE(),s_Percentage = @rPercentage,s_IsDefault = @rIsDefault,s_IsFinal = @rIsFinal WHERE Status_Id = @rMainId

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

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Status_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Status_Master SET s_Status = @rStatus WHERE Status_Id = @rMainId
				SELECT 1 res
			END
			ELSE
			BEGIN
				IF @risEdit = 0
					BEGIN
						SELECT -104 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Status_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Status_Master SET s_Status = CASE WHEN @rStatus = 1 THEN 0 ELSE 1 END WHERE Status_Id = @rMainId
				SELECT 1 res
			END
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT ISNULL(Status_Id,0) AS s_Id,ISNULL(s_Code,'') AS Code,ISNULL(s_Title,'') AS Title,ISNULL(s_Percentage,0) AS rPercentage,
			ISNULL(s_IsDefault,0) as IsDefault,ISNULL(s_IsFinal,0) as IsFinal
			FROM T0040_Status_Master WITH(NOLOCK) WHERE Status_Id = @rMainId
		END
END