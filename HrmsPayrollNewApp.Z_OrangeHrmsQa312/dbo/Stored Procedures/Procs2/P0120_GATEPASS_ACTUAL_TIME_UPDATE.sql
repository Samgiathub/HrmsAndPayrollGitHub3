

-- =============================================
-- Author:		<Author,,Ankit >
-- Create date: <Create Date,,28052016>
-- Description:	<Description,,Update Gate Pass Employee Actual time >
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0120_GATEPASS_ACTUAL_TIME_UPDATE]
	@Cmp_ID			Numeric,
	@GATE_APR_ID	Numeric,
	@GATE_APP_ID	Numeric,
	@Tran_Flag		varchar(10),
	@Log_Status		numeric Output,
	@User_ID		Numeric
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	SET @Log_Status = 0
	
	DECLARE @IO_Tran_ID	NUMERIC     
	DECLARE @Emp_Id		NUMERIC
	DECLARE @IO_DATETIME	DATETIME
	DECLARE @For_Date		DATETIME
	DECLARE @Shift_st_Time	VARCHAR(10)
	DECLARE @Shift_End_Time	VARCHAR(10)
	DECLARE @Reason_ID	NUMERIC
	
	SET @Reason_ID =0
	SET @For_Date = CAST(CONVERT(VARCHAR(20), GETDATE(),101) AS DATETIME)
	SET @IO_DATETIME = GETDATE()
	
	SELECT @Emp_Id = Emp_ID,@Reason_ID = Reason_ID From T0120_GATE_PASS_APPROVAL WITH (NOLOCK) WHERE Apr_ID = @GATE_APR_ID

	IF @Tran_Flag = 'OUT'
		BEGIN
			UPDATE T0120_GATE_PASS_APPROVAL SET Actual_Out_Time = @IO_DATETIME,Security_OutTime_UserID = @User_ID WHERE Apr_ID = @Gate_APR_ID AND App_ID = @GATE_APP_ID
			
			--SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation (@Cmp_ID, @emp_Id, @For_Date);
			
			SELECT @Shift_st_Time = Shift_St_Time, @Shift_End_Time = Shift_End_Time FROM T0040_SHIFT_MASTER  WITH (NOLOCK) WHERE Shift_ID =  dbo.fn_get_Shift_From_Monthly_Rotation (@Cmp_ID, @emp_Id, @For_Date);
			
			
			SELECT @IO_Tran_ID = ISNULL(MAX(Tran_ID),0)+ 1 FROM T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK)  
			
			--INSERT INTO T0150_EMP_Gate_Pass_INOUT_RECORD    
			--		(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours, Reason_id, Ip_Address,App_ID,Shift_St_Time,Shift_End_Time)
			--VALUES	(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,NULL,@IO_DATETIME,'',@Reason_ID,'',@GATE_APP_ID,@Shift_st_Time,@Shift_End_Time)
			
			
			--added by jimit 28112016 insert out time only once
			IF NOT EXISTS(SELECT 1 FROM T0150_EMP_Gate_Pass_INOUT_RECORD WITH (NOLOCK) WHERE App_ID=@GATE_APP_ID AND Emp_ID=@emp_ID)
				BEGIN
					INSERT INTO T0150_EMP_Gate_Pass_INOUT_RECORD    
							(Tran_Id, Emp_ID, Cmp_ID, For_Date, In_Time, Out_Time, Hours, Reason_id, Ip_Address,App_ID,Shift_St_Time,Shift_End_Time)
					VALUES	(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,NULL,@IO_DATETIME,'',@Reason_ID,'',@GATE_APP_ID,@Shift_st_Time,@Shift_End_Time)
				END
			ELSE
				BEGIN
					UPDATE T0150_EMP_Gate_Pass_INOUT_RECORD     
					SET  Out_Time = @IO_DATETIME 
					WHERE Emp_ID=@emp_ID AND App_ID = @GATE_APP_ID 
				END 
		  --ended
		  		
		END
		
	IF @Tran_Flag = 'IN'
		BEGIN
			UPDATE T0120_GATE_PASS_APPROVAL 
			SET Actual_In_Time = GETDATE(),Security_InTime_UserID = @User_ID,
				Actual_Duration = RIGHT('0' + CAST( DATEDIFF(MINUTE ,Actual_Out_Time ,@IO_DATETIME)/60 AS VARCHAR(5)), 2) + ':'+ RIGHT('0' + CAST( DATEDIFF(MINUTE ,Actual_Out_Time ,@IO_DATETIME)%60 AS VARCHAR(2)), 2)
			WHERE Apr_ID = @Gate_APR_ID AND App_ID = @GATE_APP_ID
			
			UPDATE T0150_EMP_Gate_Pass_INOUT_RECORD     
			SET  In_Time = @IO_DATETIME ,Hours = dbo.F_Return_Hours (DATEDIFF(s,Out_Time,@IO_DATETIME)) ,Is_Approved = 1
			WHERE Emp_ID=@emp_ID AND App_ID = @GATE_APP_ID AND NOT OUT_Time IS NULL AND In_Time IS NULL 
			
		END	
    
    --Exec SP_EMP_INOUT_GATE_PASS_INSERT @EMP_ID,@CMP_ID,@IO_DATETIME,'',0,0,@GATE_APP_ID
    
END


