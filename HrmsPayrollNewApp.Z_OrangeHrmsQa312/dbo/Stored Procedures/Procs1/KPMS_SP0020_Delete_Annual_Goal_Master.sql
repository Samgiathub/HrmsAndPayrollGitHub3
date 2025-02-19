CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Annual_Goal_Master]	
(
@GS_Id Int,
@rStatus int
,@Cmp_ID int
)
as
begin	
			DECLARE @lid varchar(max)= ''
			select @lid = @lid + Goal_Allot_ID from KPMS_T0020_Goal_Allotment_Master_Test where Goal_Setting_ID = @GS_Id and Cmp_Id = @Cmp_ID
		
	if @rStatus = 2	
		if(@lid!='')
			begin
					select -106
					return
			end
		else
			begin
						delete from KPMS_T0100_Goal_Setting where GS_Id =@GS_Id and Cmp_Id = @Cmp_ID
						delete from KPMS_T0110_Goal_Setting_Section where GSS_Goal_Setting_Id = @GS_Id and Cmp_Id = @Cmp_ID
						delete from KPMS_T0110_Goal_Setting_Goal where GSG_GoalSetting_Id = @GS_Id and Cmp_Id = @Cmp_ID
						delete from KPMS_T0110_GoalSettingScore where GSB_GoalSettingId = @GS_Id and Cmp_Id = @Cmp_ID
			end	
	select 1 as res
end

