
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_TravelApprove]
	@Travel_Application_ID numeric(18,0),
	@SEmp_ID numeric(18,0),
	@Approval_Status char(1),
	@Approval_Comments varchar(250),
	@Final_Approve int,
	@Is_Fwd_Leave_Rej int,
	@Rpt_Level int,
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Result varchar(100) OUTPUT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Emp_ID numeric(18,0)
DECLARE @chk_Adv int
DECLARE @chk_Agenda int
DECLARE @Attached_Doc_File varchar(MAX)
DECLARE @Tran_ID numeric(18,0)
DECLARE @Travel_Approval_ID numeric(18,0)
DECLARE @ApprovalDate Datetime

DECLARE @Place_Of_Visit varchar(100)
DECLARE @Travel_Purpose varchar(200)
DECLARE @Instruct_Emp_ID NUMERIC(18,0)
DECLARE @Travel_Mode_ID	NUMERIC(18,0)
DECLARE @From_Date Datetime
DECLARE @Period NUMERIC(18,2)
DECLARE @To_Date Datetime
DECLARE @Remarks Nvarchar(500)
DECLARE @State_ID numeric(18,0)
DECLARE @City_ID numeric(18,0)

DECLARE @For_date Datetime
DECLARE @Description NVarchar(250)
DECLARE @Amount	Numeric(18,2)
DECLARE @Self_Pay int

DECLARE @Expence_Type Varchar(100)
DECLARE @EAmount	Numeric(18,2)
DECLARE @Adv_Detail_Desc Nvarchar(250)

SET @Tran_ID = 0
SET @Travel_Approval_ID = 0
SET @ApprovalDate = (SELECT CAST(GETDATE() as varchar(11)))


BEGIN TRY
	-- Travel Approval start ----
	DECLARE TravelApproval_CURSOR CURSOR  Fast_forward FOR
	SELECT Emp_ID,chk_Adv,chk_Agenda,Attached_Doc_File FROM T0100_TRAVEL_APPLICATION WITH (NOLOCK) WHERE Travel_Application_ID = @Travel_Application_ID
	OPEN TravelApproval_CURSOR
	FETCH NEXT FROM TravelApproval_CURSOR INTO @Emp_ID,@chk_Adv,@chk_Agenda,@Attached_Doc_File
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0115_TRAVEL_LEVEL_APPROVAL @Tran_ID OUTPUT,@Travel_Application_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@S_Emp_ID=@SEmp_ID,@Approval_Date=@ApprovalDate,@Approval_Status=@Approval_Status,@Approval_Comments=@Approval_Comments,@Login_ID=@Login_ID,@Rpt_Level=@Rpt_Level,@Total = 0.00,@Tran_Type='I',@chk_Adv=@chk_Adv,@chk_Agenda=0,@Tour_Agenda='',@IMP_Business_Appoint='',@KRA_Tour='',@Attached_Doc_File=@Attached_Doc_File
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					EXEC P0120_TRAVEL_APPROVAL @Travel_Approval_ID OUTPUT,@Travel_Application_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@S_Emp_ID=@SEmp_ID,@Approval_Date=@ApprovalDate,@Approval_Status=@Approval_Status,@Approval_Comments=@Approval_Comments,@Login_ID=@Login_ID,@Is_Import=0,@Total=0.00,@chk_Adv=@chk_Adv,@chk_Agenda=0,@Tour_Agenda='',@IMP_Business_Appoint='',@KRA_Tour='',@Attached_Doc_File=@Attached_Doc_File,@Tran_Type='I'
				END
			FETCH NEXT FROM TravelApproval_CURSOR INTO @Emp_ID,@chk_Adv,@chk_Agenda,@Attached_Doc_File
		END
	CLOSE TravelApproval_CURSOR
	DEALLOCATE TravelApproval_CURSOR
	-- Travel Approval END ----  
		--SELECT @Tran_ID = MAX(Tran_Id)  FROM T0115_TRAVEL_LEVEL_APPROVAL
		--SELECT @Travel_Approval_ID = MAX(Travel_Approval_ID) FROM T0120_TRAVEL_APPROVAL
	-- Travel Approval Detail start ----    
	DECLARE TravelApprovalDetail_CURSOR CURSOR  Fast_forward FOR
	SELECT  Place_Of_Visit,Travel_Purpose,Instruct_Emp_ID,Travel_Mode_ID,From_Date,Period,To_Date,Remarks,State_ID,City_ID FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK)  WHERE Travel_App_ID = @Travel_Application_ID
	OPEN TravelApprovalDetail_CURSOR
	FETCH NEXT FROM TravelApprovalDetail_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@Instruct_Emp_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Remarks,@State_ID,@City_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0115_TRAVEL_APPROVAL_DETAIL_LEVEL 0,@Travel_App_ID=@Travel_Application_ID,@Tran_ID=@Tran_ID,@Cmp_ID=@Cmp_ID,@Place_Of_Visit=@Place_Of_Visit,@Travel_Purpose=@Travel_Purpose,@Instruct_Emp_ID=@Instruct_Emp_ID,@Travel_Mode_ID=@Travel_Mode_ID,@From_Date=@From_Date,@Period=@Period,@To_Date=@To_Date,@Remarks=@Remarks,@Leave_Approval_ID=0,@Leave_ID=0,@State_ID=@State_ID,@City_ID=@City_ID,@Loc_ID =0,@Project_ID=0,@Tran_Type='I'
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					EXEC P0130_TRAVEL_APPROVAL_DETAIL 0,@Cmp_ID=@Cmp_ID,@Travel_Approval_ID=@Travel_Approval_ID,@Place_Of_Visit=@Place_Of_Visit,@Travel_Purpose=@Travel_Purpose,@Instruct_Emp_ID=@Instruct_Emp_ID,@Travel_Mode_ID=@Travel_Mode_ID,@From_Date=@From_Date,@Period=@Period,@To_Date=@To_Date,@Remarks=@Remarks,@Leave_Approval_ID=0,@Leave_ID=0,@State_ID=@State_ID,@City_ID=@City_ID,@Loc_ID=0,@Project_ID=0,@Tran_Type='I'
				END
			FETCH NEXT FROM TravelApprovalDetail_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@Instruct_Emp_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Remarks,@State_ID,@City_ID
		END
	CLOSE TravelApprovalDetail_CURSOR
	DEALLOCATE TravelApprovalDetail_CURSOR
	-- Travel Approval Detail END ----  
	-- Travel Approval OTHER Detail Start ----
	DECLARE TravelApprovalOtherDetail_CURSOR CURSOR  Fast_forward FOR
	SELECT Travel_Mode_Id,For_date,Description,Amount,Self_Pay  FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK) WHERE Travel_App_ID = @Travel_Application_ID
	OPEN TravelApprovalOtherDetail_CURSOR 
	FETCH NEXT FROM TravelApprovalOtherDetail_CURSOR  INTO @Travel_Mode_ID,@For_date,@Description,@Amount,@Self_Pay
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL 0,@Cmp_ID,@Tran_ID,@Travel_Mode_ID,@For_date,@Description,@Amount,@Self_Pay,'I',0,'1900-01-01 00:00:00'
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					EXEC P0130_TRAVEL_Approval_OTHER_DETAIL 0,@Cmp_ID,@Travel_Approval_ID,@Travel_Mode_ID,@For_date,@Description,@Amount,@Self_Pay,'I','1900-01-01 00:00:00',0
				END
			FETCH NEXT FROM TravelApprovalOtherDetail_CURSOR  INTO @Travel_Mode_ID,@For_date,@Description,@Amount,@Self_Pay
		END
	CLOSE TravelApprovalOtherDetail_CURSOR
	DEALLOCATE TravelApprovalOtherDetail_CURSOR
	 -- Travel Approval OTHER Detail END ----
	 -- Travel Approval Advance Detail Start ----
	DECLARE TravelApprovalAdvanceDetail_CURSOR CURSOR  Fast_forward FOR
	SELECT Expence_Type,Amount,Adv_Detail_Desc FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE Travel_App_ID = @Travel_Application_ID
	OPEN TravelApprovalAdvanceDetail_CURSOR 
	FETCH NEXT FROM TravelApprovalAdvanceDetail_CURSOR  INTO @Expence_Type,@EAmount,@Adv_Detail_Desc
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL 0,@Travel_App_ID=@Travel_Application_ID,@Tran_ID=@Tran_ID,@Cmp_ID=@Cmp_ID,@Expence_Type=@Expence_Type,@Amount=@EAmount,@Adv_Detail_Desc=@Adv_Detail_Desc,@Curr_ID=0,@Tran_Type='I'
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
				BEGIN
					EXEC P0130_TRAVEL_APPROVAL_ADVDETAIL 0,@Cmp_ID=@Cmp_ID,@Travel_Approval_ID=@Travel_Approval_ID,@Expence_Type=@Expence_Type,@Amount=@EAmount,@Adv_Detail_Desc=@Adv_Detail_Desc,@Curr_ID=0,@Tran_Type='I'
				END
			FETCH NEXT FROM TravelApprovalAdvanceDetail_CURSOR  INTO @Expence_Type,@Amount,@Adv_Detail_Desc
		END
	CLOSE TravelApprovalAdvanceDetail_CURSOR
	DEALLOCATE TravelApprovalAdvanceDetail_CURSOR
	
	IF @Travel_Application_ID <> 0
		BEGIN
			IF @Approval_Status = 'R'
				BEGIN
					SET @Result = 'Travel Application Rejected'
				END
			ELSE
				BEGIN
					SET @Result = 'Travel Application Approved'
				END
		END
END TRY
BEGIN CATCH
	SET @Result = ERROR_MESSAGE()
	 --ROLLBACK 
END CATCH

