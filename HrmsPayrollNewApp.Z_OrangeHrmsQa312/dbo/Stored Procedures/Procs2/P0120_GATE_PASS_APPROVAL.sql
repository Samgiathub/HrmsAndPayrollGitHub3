

-- =============================================
-- Author:		Ankit
-- Create date: 09052016
-- Description:	Gate Pass Application Record
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0120_GATE_PASS_APPROVAL] 
	@Apr_ID		NUMERIC(18, 0) OUTPUT,
	@App_ID		NUMERIC(18, 0) ,
	@Cmp_ID		NUMERIC(18, 0) ,
	@Emp_ID		NUMERIC(18,2),
	@S_Emp_ID		NUMERIC(18, 0) ,
	@Apr_Date	DATETIME ,
	@For_Date	DATETIME ,
	@From_Time	DATETIME ,
	@To_Time	DATETIME ,
	@Duration	VARCHAR(10) ,
	@Reason_ID	NUMERIC(18, 0) ,
	@Approval_Remarks	VARCHAR(250) ,
	@Login_ID			NUMERIC(18, 0) ,
	@Tran_Type			CHAR(1) ,
	@Apr_Status			CHAR(1),
	@Rpt_Level			INT,
	@Is_Fwd_Leave_Rej	NUMERIC = 0,
	@Final_Approval		NUMERIC = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		
	DECLARE @Tran_ID	NUMERIC
	SET @Tran_ID = 0
	
    IF EXISTS( SELECT 1 FROM T0120_GATE_PASS_APPROVAL WITH (NOLOCK) WHERE Apr_ID = @Apr_ID AND Actual_Out_Time IS NOT NULL )
		BEGIN
			RAISERROR('@@ Security Punch is exists, you can''t modify @@',16,2)
			RETURN;
		END
	
	
	--IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID 
	--AND Cmp_ID=@Cmp_ID AND @For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
	IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID) --AND  @For_Date >=Month_St_Date AND @For_Date <= Month_End_Date)
		BEGIN
			
			DECLARE @cUTofF AS DATETIME	, @Month_End_Date As DATETIME
			SELECT @cUTofF = Cutoff_Date FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID --AND @For_Date >= Month_St_Date AND @For_Date <= Month_End_Date
			

			If @cUTofF is Null OR @cUTofF = ''
			begin
			SET @Month_End_Date = (select max(Month_End_Date) from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID AND Cmp_ID=@Cmp_ID AND @For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
			
			If @for_date <= @Month_End_Date
			bEGIN
				RAISERROR('@@This Months Salary Exists.So You Cant Add/Update This Record.@@',16,2)
				RETURN -1
			End
 			end

			
			IF  @For_Date<=@cUTofF 
			bEGIN
				RAISERROR('@@This Months Salary Exists.So You Cant Add/Update This Record.@@',16,2)
				RETURN -1
			End
		END
	
	
	IF @Tran_Type = 'I'
		BEGIN
		
			IF EXISTS( SELECT 1 FROM T0120_GATE_PASS_APPROVAL WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND From_Time = @From_Time AND To_Time = @To_Time AND Duration = @Duration )
				BEGIN
					RAISERROR('@@ GatePass For Same Time Already Approved @@',16,2)
					RETURN;
				END
			
			IF @Rpt_Level > 0
				BEGIN	
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM dbo.T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK)
					
					INSERT INTO dbo.T0115_GATE_PASS_LEVEL_APPROVAL
						   (Tran_ID,App_ID,Cmp_ID,Emp_ID,Apr_Date,For_Date,From_Time,To_Time,Duration,Reason_ID,Apr_Remarks,Apr_User_ID,System_Datetime,Apr_Status,S_Emp_ID,Rpt_Level)
					VALUES (@Tran_ID,@App_ID,@Cmp_ID,@Emp_ID,@Apr_Date,@For_Date,@From_Time,@To_Time,@Duration,@Reason_ID,@Approval_Remarks,@Login_ID,GETDATE(),@Apr_Status,@S_Emp_ID,@rpt_level)	
					
				END
				
			IF @Final_Approval = 1 OR (@Is_Fwd_Leave_Rej = 0 AND @Apr_Status = 'R' )
				BEGIN
				
					IF @Rpt_Level = 0 AND @App_ID = 0
						BEGIN
							EXEC P0100_GATE_PASS_APPLICATION @App_ID OUTPUT,@Cmp_ID,@Emp_ID,@Apr_Date,@For_Date,@From_Time,@To_Time,@Duration,@Reason_ID,'Gate-Pass Direct Approved by Admin',@Login_ID,'I'
						END
						
					SELECT @Apr_ID = ISNULL(MAX(Apr_ID),0) + 1 FROM dbo.T0120_GATE_PASS_APPROVAL WITH (NOLOCK)
					
					INSERT INTO dbo.T0120_GATE_PASS_APPROVAL
							(Apr_ID,App_ID,Cmp_ID,Emp_ID,Apr_Date,S_Emp_ID,For_Date,From_Time,To_Time,Duration,Reason_ID,Manager_Remarks,Apr_System_Datetime,Apr_Status,Apr_User_ID)
					VALUES (@Apr_ID,@App_ID,@Cmp_ID,@Emp_ID,@Apr_Date,@S_Emp_ID,@For_Date,@From_Time,@To_Time,@Duration,@Reason_ID,@Approval_Remarks,GETDATE(),@Apr_Status,@Login_ID)
					
					UPDATE T0100_GATE_PASS_APPLICATION SET App_Status = @Apr_Status WHERE App_ID = @App_ID AND Emp_ID = @Emp_ID
					
				END	
		END
	ELSE IF @Tran_Type = 'U'
		BEGIN
			UPDATE	dbo.T0120_GATE_PASS_APPROVAL
			SET		For_Date = @For_Date ,From_Time = @From_Time ,To_Time = @To_Time ,Duration = @Duration ,Reason_ID = @Reason_ID ,Manager_Remarks = @Approval_Remarks,Apr_Status =@Apr_Status,Apr_System_Datetime = GETDATE()
			WHERE	Apr_ID = @Apr_ID AND App_ID = @App_ID AND Emp_ID = @Emp_ID
		END
	ELSE IF @Tran_Type = 'D'
		BEGIN
		
			
			DECLARE @Se_emp_id AS NUMERIC(18,0)
			SET @Se_emp_id = 0
			SET @Tran_id = 0
			
			SELECT @Se_emp_id = S_Emp_ID,@Tran_id = Tran_ID,@Rpt_Level = Rpt_Level FROM T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK)
			WHERE  App_ID=@App_ID AND Rpt_Level IN (SELECT MAX(Rpt_Level) FROM T0115_GATE_PASS_LEVEL_APPROVAL WITH (NOLOCK) WHERE App_ID=@App_ID )
			
			IF @Se_emp_id = @S_Emp_ID --AND @Apr_ID = 0
				BEGIN
					--select @Tran_ID
					DELETE FROM T0115_GATE_PASS_LEVEL_APPROVAL WHERE Tran_id = @Tran_ID
				END
			
			IF @Apr_ID <> 0 
				BEGIN
					--Comment by Jaina 08-05-2017 ( In Final Approval, Roll back not wroking)
					--Added By Jimit 02012018
					If @S_Emp_ID = 0
						BEGIN
							 DELETE FROM T0115_GATE_PASS_LEVEL_APPROVAL WHERE App_ID = @App_ID 						
						END
					--Ended
					
					DELETE FROM dbo.T0120_GATE_PASS_APPROVAL WHERE Apr_ID = @Apr_ID AND App_ID = @App_ID
				END	
			
			UPDATE dbo.T0100_GATE_PASS_APPLICATION SET App_Status = 'P' WHERE App_ID = @App_ID
			
		END	
	
	
END

