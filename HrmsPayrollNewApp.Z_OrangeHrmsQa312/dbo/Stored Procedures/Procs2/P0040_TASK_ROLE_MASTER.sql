-- EXEC P0040_TASK_ROLE_MASTER
-- DROP PROCEDURE P0040_TASK_ROLE_MASTER
CREATE PROCEDURE P0040_TASK_ROLE_MASTER
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
					IF EXISTS(SELECT 1 FROM T0040_Task_Role_Master WITH(NOLOCK) WHERE r_Code = @rCode and r_Status < 2)
						BEGIN
							SELECT -101 res
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Role_Master WITH(NOLOCK) WHERE r_Title = @rTitle and r_Status < 2)
						BEGIN
							SELECT -102 res
							RETURN
						end

					IF @risSave = 0
						BEGIN
							SELECT -103 res
							RETURN
						END

					INSERT INTO T0040_Task_Role_Master(r_Code,r_Title)
					SELECT @rCode,@rTitle

					SELECT 1 AS res
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM T0040_Task_Role_Master WITH(NOLOCK) WHERE r_Code = @rCode and r_Status < 2 and Role_Id <> @rMainId)
						BEGIN
							SELECT -101
							RETURN
						END

					IF EXISTS(SELECT 1 FROM T0040_Task_Role_Master WITH(NOLOCK) WHERE r_Title = @rTitle and r_Status < 2 and Role_Id <> @rMainId)
						BEGIN
							SELECT -102
							RETURN
						END

					IF @risEdit = 0
						BEGIN
							SELECT -104 res
							RETURN
						END

					UPDATE T0040_Task_Role_Master SET r_Code = @rCode,r_Title = @rTitle,r_UpdatedDate = GETDATE() WHERE Role_Id = @rMainId

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

				IF EXISTS (SELECT 1 FROM T0100_Emp_Role_Assign WHERE Role_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				UPDATE T0040_Task_Role_Master SET r_Status = @rStatus WHERE Role_Id = @rMainId AND Role_Id <> 1
				SELECT 1 AS RES
			END
			ELSE
			BEGIN
				IF @risEdit = 0
					BEGIN
						SELECT -104 res
						RETURN
					END

				IF EXISTS (SELECT 1 FROM T0100_Emp_Role_Assign WHERE Role_Id = @rMainId)
					BEGIN
						SELECT -106 res
						RETURN
					END

				update T0040_Task_Role_Master SET r_Status = CASE WHEN @rStatus = 1 THEN 0 ELSE 1 END WHERE Role_Id = @rMainId AND Role_Id <> 1
				SELECT 1 AS RES
			END
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT ISNULL(Role_Id,0) AS r_Id,ISNULL(r_Code,'') AS Code,ISNULL(r_Title,'') AS Title FROM T0040_Task_Role_Master WITH(NOLOCK) WHERE Role_Id = @rMainId
		END
END