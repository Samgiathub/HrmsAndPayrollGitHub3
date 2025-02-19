-- EXEC P0100_EMP_ROLE_ASSIGN
-- DROP PROCEDURE P0100_EMP_ROLE_ASSIGN
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_ROLE_ASSIGN]
@rRoleId INT,
@rPermissionStr VARCHAR(MAX),
@rType INT,
@risEdit INT,
@risSave INT,
@risDelete INT
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	IF @rType = 1
		BEGIN
			IF @risSave = 0
				BEGIN
					SELECT -103 res
					RETURN
				END

			DECLARE @lXML XML
			SET @lXML = CAST(@rPermissionStr AS xml)

			DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),MainId INT,empId INT)
			INSERT INTO @tbltmp
			SELECT T.c.value('@MainId','INT') AS MainId,
			T.c.value('@EmployeeId','INT') AS EmployeeId
			FROM @lXML.nodes('/Permissions/Permission') AS T(c)

			MERGE T0100_Emp_Role_Assign AS TARGET
			USING @tbltmp AS SOURCE ON MainId = Emp_Role_Id
			WHEN MATCHED THEN
				UPDATE SET Role_Id = @rRoleId
			WHEN NOT MATCHED BY TARGET THEN
				INSERT
				(
					Emp_Id,Role_Id
				)
				VALUES
				(
					empId,@rRoleId
				);
		END
	ELSE IF @rType = 2
		BEGIN
			IF @risDelete = 0
				BEGIN
					SELECT -105 res
					RETURN
				END

			DELETE FROM T0100_Emp_Role_Assign WHERE Emp_Role_Id = @rRoleId
		END
	SELECT 1 AS res
END