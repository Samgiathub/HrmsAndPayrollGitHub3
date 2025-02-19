-- EXEC P0100_EMP_ROLE_ASSIGN
-- DROP PROCEDURE P0100_EMP_ROLE_ASSIGN
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[KPMS_P0100_EMP_ROLE_ASSIGN]
@rRoleId INT,
@rPermissionStr VARCHAR(MAX),
@rType INT,
@risEdit INT,
@risSave INT,
@risDelete INT,
@IsActive	bit,
@rStatus int
,@Cmp_ID int
--,@Emp_RoleId int
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
		IF Exists(select 1 From dbo.KPMS_T0100_Emp_Role_Assign WITH (NOLOCK) Where Role_Id = @rRoleId and Emp_Id = @rRoleId)
		Begin 
			select  -101
			return
		End 
		ELSE
		BEGIN

			DECLARE @lXML XML
			SET @lXML = CAST(@rPermissionStr AS xml)

			DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),MainId INT,empId INT)			
			INSERT INTO @tbltmp
			SELECT T.c.value('@MainId','INT') AS MainId,
			T.c.value('@EmployeeId','INT') AS EmployeeId
			FROM @lXML.nodes('/Permissions/Permission') AS T(c)
			MERGE KPMS_T0100_Emp_Role_Assign AS TARGET
			USING @tbltmp AS SOURCE ON MainId = Emp_Role_Id and Cmp_Id = @Cmp_ID
			WHEN MATCHED THEN
				UPDATE SET Role_Id = @rRoleId,IsActive =@IsActive
			WHEN NOT MATCHED BY TARGET THEN
				INSERT
				(
					Emp_Id,Role_Id,IsActive,Cmp_Id

				)
				VALUES
				(
					empId,@rRoleId,@IsActive,@Cmp_ID
				);
		END
		
		END	
	ELSE if @rType = 2
	begin
		if @rStatus = 2
		begin
			delete from KPMS_T0100_Emp_Role_Assign where Emp_Role_Id = @rRoleId and Cmp_Id = @Cmp_ID
		end
		else if @rStatus in (0,1)
		begin		
			update KPMS_T0100_Emp_Role_Assign set IsActive = case @rStatus when 1 then 0 else 1 end where Emp_Role_Id = @rRoleId and Cmp_Id = @Cmp_ID
		end
	end		
	SELECT 1 AS res
END