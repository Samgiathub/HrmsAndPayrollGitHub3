CREATE PROCEDURE [dbo].[KPMS_SP0040_Delete_Level_Master]	
(
@Level_ID	Int,
@rStatus int,
@Cmp_ID int
)
as
begin

	DECLARE @lid varchar(max)= ''
	
	--select @lid = @lid + la_LevelId from tbl_LevelAssignValues WHERE la_LevelId = @Level_ID

select @lid = @lid + la_LevelId from tbl_LevelAssignValues inner join
	KPMS_T0020_Goal_Allotment_Master_Test on Goal_Allot_ID = la_AllotmentId where IsActive != 2 and la_LevelId = @Level_ID

	if @rStatus = 2
	
		if(@lid!='')
			begin
					select -106
					return
			end
		else
			begin
				update KPMS_T0040_Level_Master set IsActive = 2 where Level_ID = @Level_ID and Cmp_Id = @Cmp_ID
			end
	else
	begin
		update KPMS_T0040_Level_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Level_ID = @Level_ID and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end


