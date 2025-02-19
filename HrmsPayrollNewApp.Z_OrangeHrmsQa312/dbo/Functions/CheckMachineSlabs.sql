


CREATE FUNCTION [DBO].[CheckMachineSlabs]
(
	@Machine_ID	as varchar(100),
	@Effective_date	as Datetime
	
)
RETURNS VARCHAR(2000)
AS
BEGIN
	Declare @MachineNames varchar(2000)
	
	SELECT @MachineNames =  COALESCE(@MachineNames + ',', '') +  MACHINE_NAME
	FROM V0040_MACHINE_MASTER WHERE MACHINE_ID IN (select Data from dbo.Split(@machine_id,',')) AND EFFECTIVE_DATE = @Effective_date

RETURN @MachineNames
END
	

