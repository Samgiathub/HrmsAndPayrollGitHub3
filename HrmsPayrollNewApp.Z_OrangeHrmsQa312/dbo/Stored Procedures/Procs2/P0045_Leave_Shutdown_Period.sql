

-- =============================================
-- Author:		<Jaina>
-- Create date: <03-05-2017>
-- Description:	<Leave Shutdown Period>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0045_Leave_Shutdown_Period]
	@Leave_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@From_Date datetime,
	@To_Date datetime,
	@Notice_Period numeric(18,2)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		 
	if exists(SELECT 1 FROM T0045_Leave_Shutdown_Period WITH (NOLOCK) where Leave_Id=@Leave_Id and cmp_id =@Cmp_Id  and ((@From_date between From_Date AND To_Date)
		 OR (@To_date between From_Date and To_Date)))
	BEGIN
		RAISERROR('Please Check Shutdown Period',16,2)
		RETURN
	END
	
	INSERT INTO T0045_LEAVE_SHUTDOWN_PERIOD (LEAVE_ID,CMP_ID,FROM_DATE,TO_DATE,NOTICE_PERIOD)
	VALUES (@LEAVE_ID,@CMP_ID,@FROM_DATE,@TO_DATE,@NOTICE_PERIOD)
    
END

