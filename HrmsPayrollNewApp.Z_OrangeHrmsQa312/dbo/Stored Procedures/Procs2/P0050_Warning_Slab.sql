


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <14/04/2015>
-- Description:	<WArning Deduction Days Slab Wise>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Warning_Slab]
	@slab_id numeric(18,0) output,
	@Cmp_ID numeric(18,0),
	@warning_id numeric(18,0),
	@From_Hours numeric(18,0),
	@To_Hours numeric(18,0),
	@Deduct_Days numeric(18,2),
	@tran_type varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON;
	
	
	IF @tran_type = 'I' 
		begin
			 select @Slab_ID = isnull(max(Slab_Id),0) + 1 from T0050_warning_Slab  WITH (NOLOCK)
			 Insert into T0050_Warning_Slab(slab_id,cmp_id,warning_id,from_hours,To_Hours,Deduct_Days)
			 values(@slab_id,@Cmp_ID,@warning_id,@From_Hours,@To_Hours,@Deduct_Days)
				
		end
	else if @tran_type = 'D' 
		begin
				delete from T0050_Warning_Slab where warning_id = @warning_id and cmp_ID = @cmp_ID
				set @slab_id = 1000
		end

    
	
END

