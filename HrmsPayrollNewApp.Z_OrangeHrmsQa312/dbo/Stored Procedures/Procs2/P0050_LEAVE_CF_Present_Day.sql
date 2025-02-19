

-- =============================================
-- Author	  :	<Nilesh Patel>
-- ALTER date:  <31-Mar-2015>
-- Description:	<Insert Present Day type wise >
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_Present_Day]
	 @Cmp_ID					numeric(18,0)
	,@Effective_Date			datetime
	,@Type_ID					numeric(18,0)
	,@Leave_ID					numeric(18,0)
	,@Present_Day				numeric(18,2)
	,@Leave_Again_Present		numeric(18,3)
	,@Present_Day_Max_Limit     numeric(18,2)
	,@Above_MaxLimit_P_Days     numeric(18,2)
	,@Above_MaxLimit_Leave_Days     numeric(18,2)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	DECLARE @Tran_ID Numeric(18,0)
	
		if Not exists(SELECT Tran_ID From T0050_LEAVE_CF_Present_Day WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_ID and Type_ID = @Type_ID AND Effective_Date = @Effective_Date)
			BEGIN
				Select @Tran_ID = ISNULL(max(Tran_ID),0)+1 from T0050_LEAVE_CF_Present_Day WITH (NOLOCK)

				Insert Into T0050_LEAVE_CF_Present_Day
				Values(@Tran_ID,@Cmp_ID,@Effective_Date,@Type_ID,@Leave_ID,@Present_Day,@Leave_Again_Present,@Present_Day_Max_Limit,@Above_MaxLimit_P_Days,@Above_MaxLimit_Leave_Days)
			END 
		Else
			Begin
				Update T0050_LEAVE_CF_Present_Day
				Set Effective_Date =  @Effective_Date,
					Present_Day =  @Present_Day,
					Leave_Again_Present_Day = @Leave_Again_Present,
					Present_Day_Max_Limit = @Present_Day_Max_Limit,
					Above_MaxLimit_P_Days = @Above_MaxLimit_P_Days,
					Above_MaxLimit_Leave_Days = @Above_MaxLimit_Leave_Days
				where Cmp_ID = @Cmp_ID  and Leave_ID = @Leave_ID and Type_ID = @Type_ID and Effective_Date = @Effective_Date
			End
END



