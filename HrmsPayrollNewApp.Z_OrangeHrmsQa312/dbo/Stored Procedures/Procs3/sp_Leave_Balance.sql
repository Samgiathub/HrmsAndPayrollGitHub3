



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[sp_Leave_Balance] 
	@Cmp_ID numeric,
	@Emp_ID numeric,
	@Leave_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @For_Date as dateTime
	
	Select @For_Date=Max(For_Date) from T0140_Leave_Transaction WITH (NOLOCK) where  Cmp_ID =@Cmp_ID and Leave_ID=@Leave_ID and Emp_ID =@Emp_ID
	
	
Select Leave_closing,LM.Leave_Negative_Allow from T0140_Leave_Transaction  LT WITH (NOLOCK) inner join T0040_Leave_Master LM WITH (NOLOCK)

  on LT.Leave_ID =LM.Leave_ID

where LM.LEave_ID=@Leave_ID and emp_id=@emp_ID and LT.cmp_id=@Cmp_ID and for_date=@for_date
	
	RETURN




