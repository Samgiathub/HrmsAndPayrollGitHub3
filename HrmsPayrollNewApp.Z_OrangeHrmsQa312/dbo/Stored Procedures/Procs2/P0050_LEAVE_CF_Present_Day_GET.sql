


-- =============================================
-- Author	  :	<Nilesh Patel>
-- ALTER date: <31-Mar-2015>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_Present_Day_GET]
	 @Leave_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	--,@Type_ID		numeric(18, 0)	
	,@Effective_Date Datetime
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
		
	Select 
	LCP.Tran_ID,
	LCP.Type_ID,
	TM.Type_Name,
	LCP.Cmp_ID,
	LCP.Effective_Date,
	LCP.Leave_ID,
	LCP.Present_Day,
	LCP.Leave_Again_Present_Day,
	LCP.Present_Day_Max_Limit,
	LCP.Above_MaxLimit_P_Days,
	LCP.Above_MaxLimit_Leave_Days
	From T0050_LEAVE_CF_Present_Day LCP WITH (NOLOCK) Inner JOIN T0040_TYPE_MASTER  TM WITH (NOLOCK) ON LCP.Type_ID = TM.Type_ID
	where LCP.Cmp_ID = @Cmp_ID and LCP.Leave_ID = @Leave_ID 
	--and Type_ID = @Type_ID 
	and Effective_Date = @Effective_Date
END



