




CREATE PROCEDURE [dbo].[P0130_LEAVE_APPROVAL_DETAIL_IMPORT]
	 @ROW_ID numeric output
	,@LEAVE_APPROVAL_ID numeric
	,@CMP_ID numeric
	,@LEAVE_ID numeric
	,@FROM_DATE datetime
	,@TO_DATE datetime
	,@LEAVE_PERIOD numeric(18,1)
	,@LEAVE_ASSIGN_AS varchar(15)
	,@LEAVE_REASON varchar(100)
	,@LOGIN_ID numeric(18,0)
	,@SYSTEM_DATE datetime
	,@TRAN_TYPE varchar(1)
 AS
	
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON 
		SET @TO_DATE = DATEADD(day, @LEAVE_PERIOD-1, @From_Date)
		
	IF @TRAN_TYPE ='I' 
			BEGIN
				
				SELECT @Row_ID = ISNULL(MAX(Row_ID),0) +1   FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)									
				INSERT INTO T0130_LEAVE_APPROVAL_DETAIL
				                      (Leave_Approval_ID, Cmp_ID, Leave_ID, From_Date, To_Date, Leave_Period, Leave_Assign_As, Leave_Reason, Row_ID, Login_ID, System_Date)
				VALUES     (@Leave_Approval_ID,@Cmp_ID,@Leave_ID,@From_Date,@To_Date,@Leave_Period,@Leave_Assign_As,@Leave_Reason,@Row_ID,@Login_ID,@System_Date)	
							
			END 
	
	RETURN




