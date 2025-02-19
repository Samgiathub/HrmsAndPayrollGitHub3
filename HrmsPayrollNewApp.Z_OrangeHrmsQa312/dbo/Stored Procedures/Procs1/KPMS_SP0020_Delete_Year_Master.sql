
CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Year_Master]	
(
@Batch_Detail_Id	Int,
@rStatus int
,@Cmp_ID int
)
as
begin
	if @rStatus = 2
	begin
		update KPMS_T0020_BatchYear_Detail set IsActive = 2 where Batch_Detail_Id = @Batch_Detail_Id and Cmp_Id = @Cmp_ID
	end
	else
	begin
		update KPMS_T0020_BatchYear_Detail set IsActive = case @rStatus when 1 then 0 else 1 end where Batch_Detail_Id = @Batch_Detail_Id and Cmp_Id = @Cmp_ID
	end
	select 1 as res
end

