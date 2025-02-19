
CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Weightage_Master]	
(
@Weightage_ID	Int,
@rStatus int
)
as
begin
	if @rStatus = 2
	begin
		--delete from KPMS_T0020_Weightage_Master Where  Weightage_ID= @Weightage_ID
		update KPMS_T0020_Weightage_Master set IsActive = 2 where Weightage_ID = @Weightage_ID
	end
	else
	begin
		update KPMS_T0020_Weightage_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Weightage_ID = @Weightage_ID
	end
	select 1 as res
end
