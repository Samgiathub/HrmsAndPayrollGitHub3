-- [KPMS_P0100_EMP_PAGE_GRID_ASSIGNED]
-- EXEC KPMS_P0100_PAGE_MODULE_ASSIGN
-- DROP PROCEDURE [KPMS_P0100_PAGE_MODULE_ASSIGN]
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[KPMS_P0100_PAGE_MODULE_ASSIGN]
@rRoleId INT,
@rModule_Id INT,
@rCmpId int,
@rPermissionStr VARCHAR(MAX),
@rType INT,
@IsActive INT
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	IF @rType = 1
		BEGIN		
			DECLARE @lXML XML
			SET @lXML = CAST(@rPermissionStr AS xml)
			
			DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_MenuId INT,t_PageId INT,t_IsView bit,t_IsCreate bit,t_IsModify bit,t_IsDelete bit)
			INSERT INTO @tbltmp
			SELECT 	T.c.value('@MenuId','INT') AS MenuId,
			T.c.value('@PageId','INT') AS PageId,
			T.c.value('@IsView','BIT') AS IsView,
			T.c.value('@IsCreate','BIT') AS IsCreate,
			T.c.value('@IsModify','BIT') AS IsModify,
			T.c.value('@IsDelete','BIT') AS IsDelete
			FROM @lXML.nodes('/Permissions/Permission') AS T(c)
			
			MERGE KPMS_T0125_Page_Rights AS TARGET
			USING @tbltmp AS SOURCE ON Module_Id = @rModule_Id and Page_Id = t_PageId and Emp_Role_Id = @rRoleId  and Cmp_id = @rCmpId			
			WHEN MATCHED THEN
				UPDATE SET Is_Save = t_IsCreate,Is_Edit = t_IsModify,Is_Delete = t_IsDelete,Is_View = t_IsView,Modify_Date = getdate()				
			WHEN NOT MATCHED BY TARGET THEN
				INSERT
				(
					Emp_Role_Id,Module_Id,Cmp_Id, Is_Save,Is_Edit,Is_Delete,Is_View,Page_Id
				)
				VALUES
				(
					@rRoleId,@rModule_Id,@rCmpId,t_IsCreate,t_IsModify,t_IsDelete,t_IsView,t_PageId
				);
		END			
	SELECT 1 AS res
END