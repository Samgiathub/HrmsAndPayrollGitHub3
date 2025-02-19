CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Goal_Master]	
(
@Goal_ID	Int,
@rStatus int
,@Cmp_ID int
)
as
begin	
			DECLARE @lid varchar(max)= ''
			select @lid = @lid + GSG_Goal_Id from KPMS_T0110_Goal_Setting_Goal as gsg inner join KPMS_T0020_Goal_Master as gm on Goal_ID = GSG_Goal_Id where Goal_ID = @Goal_ID and gsg.Cmp_Id = @Cmp_ID

	if @rStatus = 2	
		if(@lid!='')
			begin
					select -106
					return
			end
		else
			begin
						update KPMS_T0020_Goal_Master set IsActive = 2 where Goal_ID = @Goal_ID and Cmp_Id = @Cmp_ID
			end
			else
	begin
		update KPMS_T0020_Goal_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Goal_ID = @Goal_ID and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end

