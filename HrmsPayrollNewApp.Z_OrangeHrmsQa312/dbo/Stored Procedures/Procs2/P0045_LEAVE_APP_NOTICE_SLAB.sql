

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0045_LEAVE_APP_NOTICE_SLAB]
	@Cmp_Id numeric(18,0),
	@Leave_Id numeric(18,0),
	@For_Date datetime,
	@Leave_Period numeric(18,2),
	@Notice_Days numeric(18,2)
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
				
	INSERT INTO T0045_LEAVE_APP_NOTICE_SLAB (CMP_ID,LEAVE_ID,FOR_DATE,LEAVE_PERIOD,NOTICE_DAYS)
	VALUES (@CMP_ID,@LEAVE_ID,@FOR_DATE,@LEAVE_PERIOD,@NOTICE_DAYS)
		
	
	
END

