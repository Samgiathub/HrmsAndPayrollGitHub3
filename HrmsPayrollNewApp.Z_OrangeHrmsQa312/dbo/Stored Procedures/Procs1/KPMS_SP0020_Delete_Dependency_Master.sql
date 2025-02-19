
CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Dependency_Master]	
(
@Dependency_ID	Int,
@rStatus int
,@Cmp_ID int
)
as
begin
	if @rStatus = 2
	begin
		--delete from KPMS_T0020_Dependency_Master Where  Dependency_ID= @Dependency_ID
		update KPMS_T0020_Dependency_Master set IsActive = 2 where Dependency_ID = @Dependency_ID and Cmp_Id = @Cmp_ID
	end
	else
	begin
		update KPMS_T0020_Dependency_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Dependency_ID = @Dependency_ID and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end
