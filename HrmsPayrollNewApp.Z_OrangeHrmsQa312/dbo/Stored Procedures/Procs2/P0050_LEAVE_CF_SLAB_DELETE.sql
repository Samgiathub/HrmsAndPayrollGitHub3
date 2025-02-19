



-- =============================================
-- Author	  :	<Alpesh>
-- ALTER date: <24-Apr-2012>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_SLAB_DELETE]
	 @Leave_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	,@Effective_Date datetime
		
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	If @Leave_ID > 0 and @Effective_Date is not null
		Begin
			Delete from T0050_LEAVE_CF_SLAB where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID and Effective_Date=@Effective_Date
		End
END



