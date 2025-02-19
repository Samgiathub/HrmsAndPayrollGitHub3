-- EXEC P0040_ROLE_MASTER_DROPDOWN
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN
CREATE PROCEDURE [dbo].[KPMS_P0040_AccessRight_Role_DROPDOWN]
@rCmpId INT,
@rRoleId int
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @lRoleResult VARCHAR(MAX) = ''
	DECLARE @lModuleResult VARCHAR(MAX) = ''


	SELECT @lRoleResult = '<option value="0"> -- Select -- </option>'
	SELECT @lRoleResult = @lRoleResult + '<option value="' + CONVERT(VARCHAR,Role_Id) + '">' + Role_Name + '</option>'
	FROM KPMS_T0020_Role_Master WITH(NOLOCK) WHERE IsActive= 1 AND Cmp_ID = @rCmpId

	SELECT @lModuleResult = '<option value="0"> -- Select -- </option>'
	SELECT @lModuleResult = @lModuleResult + '<option value="' + CONVERT(VARCHAR,mr.Module_Id) + '">' + Module_Name + '</option>'
		 from KPMS_T0110_Module_Master as mm  Inner join
KPMS_T0115_Module_Rights as mr on mm.Module_Id=mr.Module_Id 
where mr.Emp_Role_Id=@rRoleId  and mr.IsActive= 1 AND mr.Cmp_ID = @rCmpId


	SELECT @rCmpId AS CmpId,@lRoleResult AS RoleResult,REPLACE(@lRoleResult,'-- Select --','-- ALL --') AS RoleResultALL,
	@lModuleResult AS ModuleResult,REPLACE(@lModuleResult,'-- Select --','-- ALL --') AS ModuleResultAll
	
END
--select mm.Module_Name from KPMS_T0110_Module_Master as mm  Inner join
--KPMS_T0115_Module_Rights as mr on mm.Module_Id=mr.Module_Id 
--where mr.Emp_Role_Id=@role_Id