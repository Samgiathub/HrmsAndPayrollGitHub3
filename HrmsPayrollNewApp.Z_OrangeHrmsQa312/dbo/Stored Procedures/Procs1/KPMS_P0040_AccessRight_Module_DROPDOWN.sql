CREATE PROCEDURE [dbo].[KPMS_P0040_AccessRight_Module_DROPDOWN]
@rCmpId INT
AS
BEGIN
select mr.Emp_Role_Id,mm.Module_Name from KPMS_T0115_Module_Rights as mr  join
KPMS_T0110_Module_Master as mm on mm.Module_Id=mr.Module_Id join KPMS_T0020_Role_Master as rm
on rm.Cmp_ID = mm.Cmp_Id
where mr.Emp_Role_Id=rm.Role_ID
END


