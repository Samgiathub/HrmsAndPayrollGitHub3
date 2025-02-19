

-- =============================================
-- Author:		<Jaina Desai>
-- Create date: <26-05-2017>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Check_Leave_Mandatory]
	@Cmp_Id numeric(18,0),
	@Emp_Id numeric(18,0),
	@Leave_Id  numeric(18,0),
	@Leave_Balance numeric(18,2),
	@Leave_Period numeric(18,2)
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @CHECK_LEAVE AS NUMERIC(18,2)
	DECLARE @MIN_LEAVE AS NUMERIC(18,2)
	
	SELECT @CHECK_LEAVE = MIN_LEAVE_NOT_MANDATORY ,@MIN_LEAVE = LEAVE_MIN
	FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND LEAVE_ID=@LEAVE_ID	
	
	SELECT @MIN_LEAVE as Min_Leave,@CHECK_LEAVE,@LEAVE_PERIOD as Leave_Period,@LEAVE_BALANCE as LEave_Bal
	
	IF @CHECK_LEAVE = 1
		BEGIN
			IF @LEAVE_PERIOD >= @LEAVE_BALANCE
			BEGIN
				IF @LEAVE_PERIOD <= @MIN_LEAVE 
					print 'Allowed'
				else
					print 'Not allowed'
				
			END
		END
	ELSE
		BEGIN
			SELECT @MIN_LEAVE
		END
    
END

