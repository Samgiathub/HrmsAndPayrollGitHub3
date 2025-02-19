
create PROCEDURE [dbo].[KPMS_SP0020_Delete_Band_Master]	
(
@Band_ID	Int,
@rStatus int
)
as
begin
	if @rStatus = 2
	begin
		--delete from KPMS_T0020_Band_Master Where  Band_ID= @Band_ID
		update KPMS_T0020_Band_Master set IsActive = 2 where Band_ID = @Band_ID
	end
	else
	begin
		update KPMS_T0020_Band_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Band_ID = @Band_ID
	end
	select 1 as res
end
