CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_GoalAlt_Master]	
(
@GoalAlt_ID Int,  
@rStatus int
,@Cmp_ID int

)
as
begin	
					
	if @rStatus = 2		
	--declare @i int
	--select @i = Goal_Allot_ID from KPMS_T0020_Goal_Allotment_Master_Test where Cmp_ID = @Cmp_ID
	--if(@i!= '')
	--	begin
	--		select -105
	--		return
	--	end
	--else
	--		begin
					delete from KPMS_T0020_Goal_Allotment_Master_Test where Goal_Allot_ID = @GoalAlt_ID  and Cmp_Id = @Cmp_ID
					delete from KPMS_T0100_Level_Assign where Goal_Allotment_Id = @GoalAlt_ID and Cmp_Id = @Cmp_ID
					delete from tbl_LevelAssignValues where la_AllotmentId = @GoalAlt_ID and Cmp_Id = @Cmp_ID
				
			--end	
	select 1 as res
end

