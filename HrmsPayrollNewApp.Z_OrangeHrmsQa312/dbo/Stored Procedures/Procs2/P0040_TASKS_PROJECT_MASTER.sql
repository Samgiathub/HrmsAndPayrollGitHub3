-- EXEC P0040_TASKS_PROJECT_MASTER
-- DROP PROCEDURE P0040_TASKS_PROJECT_MASTER
CREATE PROCEDURE P0040_TASKS_PROJECT_MASTER
@rMainId int,
@rStatus int,
@rType int,
@risEdit INT = NULL,
@risSave INT = NULL,
@risDelete INT = NULL,
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
					IF EXISTS(SELECT 1 FROM T0040_Task_Project_Master WHERE pr_Code = @rCode and pr_Status < 2)
						BEGIN
							SELECT -101 res
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Project_Master WHERE pr_Title = @rTitle and pr_Status < 2)
						BEGIN
							SELECT -102 res
							RETURN
						end

					IF @risSave = 0
						BEGIN
							SELECT -103 res
							RETURN
						END

					INSERT INTO T0040_Task_Project_Master(pr_Code,pr_Title)
					SELECT @rCode,@rTitle

					SELECT 1 AS res
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Task_Project_Master WHERE pr_Code = @rCode and pr_Status < 2 and Project_Id <> @rMainId)
						BEGIN
							SELECT -101
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Project_Master WHERE pr_Title = @rTitle and pr_Status < 2 and Project_Id <> @rMainId)
						BEGIN
							SELECT -102
							RETURN
						END

					IF @risEdit = 0
						BEGIN
							SELECT -104 res
							RETURN
						END

					UPDATE T0040_Task_Project_Master SET pr_Code = @rCode,pr_Title = @rTitle,pr_UpdatedDate = GETDATE() WHERE Project_Id = @rMainId

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

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Project_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Task_Project_Master SET pr_Status = @rStatus WHERE Project_Id = @rMainId
				SELECT 1 res
			END
			ELSE
			BEGIN
				IF @risEdit = 0
					BEGIN
						SELECT -104 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0100_Task_Assign WHERE Project_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				update T0040_Task_Project_Master SET pr_Status = CASE WHEN @rStatus = 1 THEN 0 ELSE 1 END WHERE Project_Id = @rMainId
				SELECT 1 res
			END
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT ISNULL(Project_Id,0) AS pr_Id,ISNULL(pr_Code,'') AS Code,ISNULL(pr_Title,'') AS Title
			FROM T0040_Task_Project_Master WITH(NOLOCK) WHERE Project_Id = @rMainId
		END
END