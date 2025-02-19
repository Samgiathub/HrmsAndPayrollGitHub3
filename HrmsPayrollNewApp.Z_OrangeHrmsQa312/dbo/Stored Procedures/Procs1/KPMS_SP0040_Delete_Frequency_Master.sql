CREATE PROCEDURE [dbo].[KPMS_SP0040_Delete_Frequency_Master]	
(
@Frequency_ID	Int,
@rStatus int
,@Cmp_ID int
)
as
begin
	if @rStatus = 2
	begin
		--delete from KPMS_T0040_Frequency_Master Where  Frequency_ID= @Frequency_ID
		update KPMS_T0040_Frequency_Master set IsActive = 2 where Frequency_ID = @Frequency_ID and Cmp_Id = @Cmp_ID
	end
	else
	begin
		update KPMS_T0040_Frequency_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Frequency_ID = @Frequency_ID and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end
