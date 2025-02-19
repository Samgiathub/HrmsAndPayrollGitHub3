
-- =============================================
-- Author:		Nilesh Patel
-- Create date: 08-05-2017 
-- Description:	Check Balance of Uniform at time of assign to employee
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Check_Uniform_Count]
	@Cmp_ID Numeric(18,0),
	@Uni_ID Numeric(18,0),
	@Assign_Uni Numeric(18,0),
	@For_Date Datetime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
    Declare @Uni_Count Numeric(18,0)
    Set @Uni_Count = 0

	Select @Uni_Count = Stock_Balance From T0140_Uniform_Stock_Transaction WITH (NOLOCK)
	Where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID 
	and for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction WITH (NOLOCK)
	where for_date <= @For_date and	Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	--and For_Date <= @For_Date   
	--select @Uni_Count,@For_Date,@Uni_ID  
    Select CASE WHEN @Assign_Uni > @Uni_Count then 0 else 1 END as negative
END
