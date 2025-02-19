CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Section_Master]	
(
@Section_ID	Int,
@rStatus int
,@Cmp_ID int
)
as
begin
DECLARE @lid varchar(max)= ''
	select @lid = @lid + GSG_GoalSettingSection_Id from KPMS_T0110_Goal_Setting_Goal as gsg inner join KPMS_T0020_Section_Master as sm on Section_ID = GSG_GoalSettingSection_Id where GSG_GoalSettingSection_Id = @Section_ID and gsg.Cmp_Id = @Cmp_ID
	
	if @rStatus = 2	
		if(@lid!='')
			begin
					select -106
					return
			end
		else
			begin
					update KPMS_T0020_Section_Master set IsActive = 2 where Section_ID = @Section_ID and Cmp_Id = @Cmp_ID
			end
	else
	begin
					update KPMS_T0020_Section_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Section_ID = @Section_ID and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end