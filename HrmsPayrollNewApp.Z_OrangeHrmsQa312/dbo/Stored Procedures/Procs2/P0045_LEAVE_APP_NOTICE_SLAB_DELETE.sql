

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0045_LEAVE_APP_NOTICE_SLAB_DELETE]
	@Cmp_Id numeric(18,0),
	@Leave_ID numeric(18,0),
	@For_Date datetime
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    If @Leave_ID > 0 and @For_Date is not null
		BEGIN
			DELETE FROM T0045_LEAVE_APP_NOTICE_SLAB WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID AND FOR_DATE=@FOR_DATE
		END
END

