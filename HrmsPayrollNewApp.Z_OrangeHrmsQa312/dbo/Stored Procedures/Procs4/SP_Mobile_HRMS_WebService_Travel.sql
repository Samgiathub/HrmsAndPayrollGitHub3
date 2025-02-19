
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel]
	@Travel_Application_ID NUMERIC(18,0),
	@Cmp_ID NUMERIC(18,0),
	@Emp_ID NUMERIC(18,0),
	@S_Emp_ID NUMERIC(18,0),
	@Chk_Advance TINYINT,
	@Chk_Agenda TINYINT,
	@Chk_International TINYINT,
	@Tour_Agenda VARCHAR(MAX),
	@IMP_Business_Appoint VARCHAR(MAX),
	@KRA_Tour VARCHAR(MAX),
	@Attached_Doc_File VARCHAR(MAX),
	@TravelDetail XML,
	--@OtherDetail XML,
	--@ExpenceDetail XML,
	@Approval_Status CHAR(1),
	@Approval_Comments VARCHAR(250),
	@Final_Approve INT,
	@Is_Fwd_Leave_Rej INT,
	@Rpt_Level INT,
	@Total NUMERIC(18,2),
	@Login_ID numeric(18,0),
	@IMEINO varchar(100),
	@From_Date datetime,
	@To_Date datetime,
	@Type Char(1),
	@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @IP_Address VARCHAR(100)
SET @IP_Address = 'Mobile('+@IMEINO+')'

DECLARE @Trans_Date DATETIME
SET @Trans_Date = CAST(GETDATE() AS VARCHAR(11)) 

DECLARE @Travel_App_Detail_ID NUMERIC(18,0)
DECLARE @Place_Of_Visit VARCHAR(50)
DECLARE @Travel_Purpose VARCHAR(255)
DECLARE @InstructBy_ID NUMERIC(18,0)
DECLARE @Travel_Mode_ID NUMERIC(18,0)
--DECLARE @From_Date DATETIME
DECLARE @Period	NUMERIC(18,2)
--DECLARE @To_Date Datetime
DECLARE @Remarks VARCHAR(500)
DECLARE @State_ID NUMERIC(18,0)
DECLARE @City_ID NUMERIC(18,0)
DECLARE @Loc_ID NUMERIC(18,0)
DECLARE @Project_ID NUMERIC(18,0)

DECLARE @Description VARCHAR(250)
DECLARE @Self_Pay TINYINT
DECLARE @Curr_ID NUMERIC(18,0)
DECLARE @Amount	NUMERIC(18,2)
DECLARE @SGST	NUMERIC(18,2)
DECLARE @CGST	NUMERIC(18,2)
DECLARE @IGST	NUMERIC(18,2)
DECLARE @GST_No VARCHAR(50)
DECLARE @GST_Company_Name VARCHAR(50)
DECLARE @Expence_Type VARCHAR(100)

DECLARE @Travel_Approval_ID NUMERIC(18,0)
DECLARE @Tran_ID NUMERIC(18,0)
DECLARE @Flag TINYINT
DECLARE @Design_ID NUMERIC(18,0)


IF @Type = 'B' --- For Bind Records
	BEGIN
		SELECT @Design_ID = Desig_Id FROM V0080_Employee_Master WHERE Emp_ID = @Emp_ID
		
		EXEC Get_TravelMode_Desg @Desg_ID = @Design_ID,@flag = 0
		
		SELECT * FROM
		(
			SELECT 1 AS 'Expense_Type_ID','Boarding' AS 'Expense_Type'
			UNION
			SELECT 2 AS 'Expense_Type_ID','Lodging' AS 'Expense_Type'
			UNION
			SELECT 3 AS 'Expense_Type_ID','Conveyance' AS 'Expense_Type'
			UNION
			SELECT 4 AS 'Expense_Type_ID','Other Miscellaneous' AS 'Expense_Type'
		) QRY
		
		--SELECT Setting_Name,Setting_Value FROM T0040_SETTING where Group_By = 'Travel Settings' AND Cmp_ID = @Cmp_ID
		SELECT Curr_ID,Curr_Name,Curr_Symbol FROM T0040_CURRENCY_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID
	END
ELSE IF @Type = 'I' OR @Type = 'M' --- For Travel Application for Draft AND Submit
	BEGIN
		BEGIN TRANSACTION TA
		BEGIN TRY
			EXEC P0100_TRAVEL_APPLICATION @Travel_Application_ID = @Travel_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,
			@Emp_ID = @Emp_ID,@S_Emp_ID = @S_Emp_ID,@Application_Date = @Trans_Date,@Application_Code = '',
			@Application_Status = @Type,@Login_ID = @Login_ID,@chk_Adv = @Chk_Advance,@chk_Agenda = @Chk_Agenda,
			@Tour_Agenda = @Tour_Agenda,@IMP_Business_Appoint = @IMP_Business_Appoint,@KRA_Tour = @KRA_Tour,
			@Attached_Doc_File = @Attached_Doc_File,@Tran_Type = @Type,@Chk_International = @Chk_International,
			@User_Id = @Login_ID,@IP_Address = @IP_Address
			
			---- Travel Application Details START ---
			IF (@TravelDetail.exist('/NewDataSet/TravelDetails') = 1)
				BEGIN 
					SELECT Table1.value('(PlaceName/text())[1]','varchar(100)') AS Place_Of_Visit,
					Table1.value('(Purpose/text())[1]','varchar(100)') AS Purpose,
					Table1.value('(InstructBy_ID/text())[1]','numeric(18,0)') AS InstructBy_ID,
					Table1.value('(Travel_Mode_ID/text())[1]','numeric(18,0)') AS Travel_Mode_ID,
					CONVERT(DATETIME, Table1.value('(Fromdate/text())[1]','varchar(11)'),103) AS FromDate,
					Table1.value('(Period/text())[1]','numeric(18,2)') AS Period,
					CONVERT(DATETIME, Table1.value('(Todate/text())[1]','varchar(11)'),103) AS ToDate,
					Table1.value('(Remarks/text())[1]','varchar(100)') AS Remarks,
					Table1.value('(State_ID/text())[1]','numeric(18,0)') AS State_ID,
					Table1.value('(City_ID/text())[1]','numeric(18,0)') AS City_ID,
					Table1.value('(LOC_ID/text())[1]','numeric(18,0)') AS LOC_ID,
					Table1.value('(Project_ID/text())[1]','numeric(18,0)') AS Project_ID
					INTO #TravelDetailTemp FROM @TravelDetail.nodes('/NewDataSet/TravelDetails') AS Temp(Table1)
					
					DECLARE TRAVELDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
					
					SELECT Place_Of_Visit,Purpose,InstructBy_ID,Travel_Mode_ID,FromDate,Period,ToDate,Remarks,State_ID,City_ID,LOC_ID,Project_ID 
					FROM #TravelDetailTemp
					
					OPEN TRAVELDETAIL_CURSOR
					FETCH NEXT FROM TRAVELDETAIL_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@InstructBy_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Remarks,@State_ID,@City_ID,@Loc_ID,@Project_ID 

					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0110_TRAVEL_APPLICATION_DETAIL @Travel_App_Detail_ID = @Travel_App_Detail_ID OUTPUT,
							@Cmp_ID	= @Cmp_ID,@Travel_App_ID = @Travel_Application_ID,@Place_Of_Visit = @Place_Of_Visit,
							@Travel_Purpose = @Travel_Purpose,@Instruct_Emp_ID = @S_Emp_ID,@Travel_Mode_ID = @Travel_Mode_ID,
							@From_Date = @From_Date,@Period = @Period,@To_Date = @To_Date,@Remarks = @Remarks,@State_ID = @State_ID,
							@City_ID = @City_ID,@Loc_ID = @Loc_ID,@Project_ID = @Project_ID,@Tran_Type = 'I',@User_Id = @Login_ID,
							@IP_Address = @IP_Address
							 
							FETCH NEXT FROM TRAVELDETAIL_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@InstructBy_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Remarks,@State_ID,@City_ID,@Loc_ID,@Project_ID 
						END
					CLOSE TRAVELDETAIL_CURSOR
					DEALLOCATE TRAVELDETAIL_CURSOR
				END
			
			---- Travel Application Details END ---
			
			---- Travel Application Other Details START ---
			
			IF (@TravelDetail.exist('/NewDataSet/OtherDetails') = 1)
				BEGIN 
					SELECT Table1.value('(Travel_Mode_ID/text())[1]','numeric(18,0)') AS Travel_Mode_ID,
					CONVERT(datetime, Table1.value('(FromDate/text())[1]','varchar(50)'),103) AS FromDate,
					Table1.value('(Description/text())[1]','varchar(MAX)') AS OtherDescription,
					ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0) AS Amount,
					Table1.value('(Self_Pay/text())[1]','int') AS Self_Pay,
					CONVERT(datetime, Table1.value('(ToDate/text())[1]','varchar(50)'),103) AS ToDate,
					Table1.value('(Currency_ID/text())[1]','numeric(18,0)') AS Currency_ID,
					Table1.value('(SGSTAmt/text())[1]','numeric(18,2)') AS SGSTAmt,
					Table1.value('(CGSTAmt/text())[1]','numeric(18,2)') AS CGSTAmt,
					Table1.value('(IGSTAmt/text())[1]','numeric(18,2)') AS IGSTAmt,
					Table1.value('(GSTNo/text())[1]','varchar(50)') AS GSTNo,
					Table1.value('(GST_CompanyName/text())[1]','varchar(50)') AS GST_CompanyName
					INTO #TravelOtherDetailTemp FROM @TravelDetail.nodes('/NewDataSet/OtherDetails') AS Temp(Table1)  
		    
					DECLARE TRAVELOTHERDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
					
					SELECT Travel_Mode_ID,FromDate,OtherDescription,Amount,Self_Pay,ToDate,Currency_ID,SGSTAmt,
					CGSTAmt,IGSTAmt,GSTNo,GST_CompanyName
					FROM #TravelOtherDetailTemp
					
					OPEN TRAVELOTHERDETAIL_CURSOR 
					FETCH NEXT FROM TRAVELOTHERDETAIL_CURSOR  INTO @Travel_Mode_ID,@From_Date,@Description,@Amount,@Self_Pay,@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name
					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0110_TRAVEL_APPLICATION_OTHER_DETAIL @Travel_App_Other_Detail_Id = 0,@Cmp_ID = @Cmp_ID,@Travel_App_ID = @Travel_Application_ID,
							@Travel_Mode_Id =  @Travel_Mode_ID,@For_date = @From_Date,@Description = @Description,@Amount = @Amount,@Self_Pay = @Self_Pay,@Tran_Type = 'I',
							@To_Date = @To_Date,@Curr_ID = @Curr_ID,@SGST = @SGST,@CGST = @CGST,@IGST = @IGST,@GST_No = @GST_No,@GST_Company_Name = @GST_Company_Name
							
							FETCH NEXT FROM TRAVELOTHERDETAIL_CURSOR  INTO @Travel_Mode_ID,@From_Date,@Description,@Amount,@Self_Pay,@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name
						END
					CLOSE TRAVELOTHERDETAIL_CURSOR 
					DEALLOCATE TRAVELOTHERDETAIL_CURSOR
				END
			---- Travel Application Other Details END ---
			
			---- Travel Application Advance Details START ---
			IF (@TravelDetail.exist('/NewDataSet/AdvanceDetails') = 1)
				BEGIN
					SELECT Table1.value('(ExpenceType/text())[1]','varchar(100)') AS ExpenceType,
					ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0.0) AS Amount,
					Table1.value('(Remarks/text())[1]','varchar(MAX)') AS Remarks,
					ISNULL(Table1.value('(Currency_ID/text())[1]','numeric(18,2)'),0) AS Currency_ID
					INTO #TravelAdvDetailTemp FROM @TravelDetail.nodes('/NewDataSet/AdvanceDetails') AS Temp(Table1)  
		    
					DECLARE TRAVELADVANCEDETAIL_CURSOR CURSOR FAST_FORWARD FOR
					SELECT ExpenceType,Amount,Remarks,Currency_ID FROM #TravelAdvDetailTemp
					OPEN TRAVELADVANCEDETAIL_CURSOR
					FETCH NEXT FROM TRAVELADVANCEDETAIL_CURSOR INTO @Expence_Type,@Amount,@Description,@Curr_ID
					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0110_TRAVEL_ADVANCE_DETAIL @Travel_Advance_Detail_ID = 0,@Cmp_ID = @Cmp_ID,@Travel_App_ID = @Travel_Application_ID,
							@Expence_Type = @Expence_Type,@Amount = @Amount,@Adv_Detail_Desc = @Description,@Curr_ID = @Curr_ID,@Tran_Type = 'I'
							
							FETCH NEXT FROM TRAVELADVANCEDETAIL_CURSOR INTO @Expence_Type,@Amount,@Description,@Curr_ID
						END
					CLOSE TRAVELADVANCEDETAIL_CURSOR
					DEALLOCATE TRAVELADVANCEDETAIL_CURSOR
				END
			
			---- Travel Application Advance Details END ---
			
			SET @Result = 'Travel Application Done Successfully#True#' + CAST(@Travel_Application_ID AS VARCHAR(11))
			
			SELECT @Result
			
			SELECT TA.Travel_Application_ID,TA.Application_Code,TA.Application_Date,
			(CASE WHEN TA.Application_Status = 'P' THEN 'Pending' ELSE CASE WHEN TA.Application_Status = 'D' THEN 'Draft' ELSE CASE WHEN TA.Application_Status = 'A' THEN 'Approved' ELSE 'Rejected' END END END) AS 'Application_Status', 
			(EM.Alpha_Emp_Code + ' - '+ TA.Emp_Full_Name) AS 'EmpName',TA.Application_Date_Show,TA.Emp_Visit
			FROM V0100_TRAVEL_APPLICATION TA
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID
			WHERE Travel_Application_ID = @Travel_Application_ID
			
			EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @EMP_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Travel Application',
			@Flag = 0,@Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0
			
			COMMIT TRANSACTION TA
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
			SELECT @Result
			ROLLBACK TRANSACTION TA 
		END CATCH
	END
ELSE IF @Type = 'A' --- For Travel Approval
	BEGIN
		
		BEGIN TRY
		
			EXEC P0115_TRAVEL_LEVEL_APPROVAL @Tran_ID = @Tran_ID OUTPUT,@Travel_Application_ID = @Travel_Application_ID,
			@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @S_Emp_ID,@Approval_Date = @Trans_Date,@Approval_Status = @Approval_Status,
			@Approval_Comments = @Approval_Comments,@Login_ID = @Login_ID,@Rpt_Level = @Rpt_Level,@Total = @Total,@Tran_Type = 'I',
			@chk_Adv = @Chk_Advance,@chk_Agenda = @Chk_Agenda,@Tour_Agenda = @Tour_Agenda,@IMP_Business_Appoint = @IMP_Business_Appoint,
			@KRA_Tour = @KRA_Tour,@Attached_Doc_File = @Attached_Doc_File
			
			SET @Flag = 2
			
			IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej = 0 AND @Approval_Status = 'R') 
				BEGIN
					
					EXEC P0120_TRAVEL_APPROVAL @Travel_Approval_ID = @Travel_Approval_ID OUTPUT,@Travel_Application_ID = @Travel_Application_ID,
					@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @S_Emp_ID, @Approval_Date = @Trans_Date,@Approval_Status = @Approval_Status,
					@Approval_Comments = @Approval_Comments,@Login_ID = @Login_ID,@Is_Import = 0,@Total = @Total,@chk_Adv = @Chk_Advance,
					@chk_Agenda = @Chk_Agenda,@Tour_Agenda = @Tour_Agenda,@IMP_Business_Appoint = @IMP_Business_Appoint,@KRA_Tour = @KRA_Tour,
					@Attached_Doc_File = @Attached_Doc_File,@Tran_Type='I',@User_Id = @Login_ID,@IP_Address = @IP_Address
					
					SET @Flag = 1
				END
			---- Travel Approval Details Start ---
			IF (@TravelDetail.exist('/NewDataSet/TravelDetails') = 1)
				BEGIN 
					SELECT Table1.value('(PlaceName/text())[1]','varchar(100)') AS Place_Of_Visit,
					Table1.value('(Purpose/text())[1]','varchar(100)') AS Purpose,
					Table1.value('(InstructBy_ID/text())[1]','numeric(18,0)') AS InstructBy_ID,
					Table1.value('(Travel_Mode_ID/text())[1]','numeric(18,0)') AS Travel_Mode_ID,
					CONVERT(DATETIME, Table1.value('(Fromdate/text())[1]','varchar(11)'),103) AS FromDate,
					Table1.value('(Period/text())[1]','numeric(18,2)') AS Period,
					CONVERT(DATETIME, Table1.value('(Todate/text())[1]','varchar(11)'),103) AS ToDate,
					Table1.value('(Leave_ID/text())[1]','numeric(18,0)') AS Leave_ID,
					CONVERT(DATETIME, Table1.value('(Halfdate/text())[1]','varchar(11)'),103) AS Halfdate,
					Table1.value('(LeaveType/text())[1]','varchar(100)') AS LeaveType,
					Table1.value('(Remarks/text())[1]','varchar(100)') AS Remarks,
					Table1.value('(NightDay/text())[1]','int') AS NightDay,
					Table1.value('(State_ID/text())[1]','numeric(18,0)') AS State_ID,
					Table1.value('(City_ID/text())[1]','numeric(18,0)') AS City_ID,
					Table1.value('(LOC_ID/text())[1]','numeric(18,0)') AS LOC_ID,
					Table1.value('(Project_ID/text())[1]','numeric(18,0)') AS Project_ID
					INTO #TravelDetailApproval FROM @TravelDetail.nodes('/NewDataSet/TravelDetails') AS Temp(Table1)
					
					DECLARE @Leave_ID NUMERIC(18,0)
					DECLARE @HalfLeavedate DATETIME
					DECLARE @LeaveType VARCHAR(50)
					DECLARE @NightDay int
					
					DECLARE TRAVELDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
					
					SELECT Place_Of_Visit,Purpose,InstructBy_ID,Travel_Mode_ID,FromDate,Period,ToDate,Leave_ID,Halfdate,
					LeaveType,Remarks,NightDay,State_ID,City_ID,LOC_ID,Project_ID 
					FROM #TravelDetailApproval
					
					OPEN TRAVELDETAIL_CURSOR
					FETCH NEXT FROM TRAVELDETAIL_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@InstructBy_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Leave_ID,@HalfLeavedate,@LeaveType,@Remarks,@NightDay,@State_ID,@City_ID,@Loc_ID,@Project_ID 

					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0115_TRAVEL_APPROVAL_DETAIL_LEVEL @Row_ID	= 0,@Travel_App_ID = @Travel_Application_ID,@Tran_ID = @Tran_ID,
							@Cmp_ID = @Cmp_ID,@Place_Of_Visit = @Place_Of_Visit,@Travel_Purpose = @Travel_Purpose,@Instruct_Emp_ID = @InstructBy_ID,
							@Travel_Mode_ID = @Travel_Mode_ID,@From_Date = @From_Date,@Period = @Period,@To_Date = @To_Date,@Remarks = @Remarks,
							@Leave_Approval_ID = 0,@Leave_ID = @Leave_ID,@State_ID = @State_ID,@City_ID = @City_ID,@Loc_ID = @Loc_ID,@Project_ID = @Project_ID,
							@Tran_Type = 'I',@Half_Leave_Date = @HalfLeavedate,@LeaveType = @LeaveType,@Night_Day = @NightDay
							
							IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej = 0 AND @Approval_Status = 'R') 
								BEGIN
									EXEC P0130_TRAVEL_APPROVAL_DETAIL @Travel_Approval_Detail_ID = 0,@Cmp_ID = @Cmp_ID,
									@Travel_Approval_ID = @Travel_Approval_ID,@Place_Of_Visit = @Place_Of_Visit,@Travel_Purpose = @Travel_Purpose,
									@Instruct_Emp_ID = @InstructBy_ID,@Travel_Mode_ID = @Travel_Mode_ID,@From_Date = @From_Date,@Period = @Period,
									@To_Date = @To_Date,@Remarks = @Remarks,@Leave_Approval_ID = 0,@Leave_ID = @Leave_ID,@State_ID = @State_ID,
									@City_ID = @City_ID,@Loc_ID = @Loc_ID,@Project_ID = @Project_ID,@Tran_Type = 'I',@User_Id = @Login_ID,
									@IP_Address  = @IP_Address,@Half_Leave_Date = @HalfLeavedate,@LeaveType = @LeaveType,@Night_Day = @NightDay
								END
							FETCH NEXT FROM TRAVELDETAIL_CURSOR INTO @Place_Of_Visit,@Travel_Purpose,@InstructBy_ID,@Travel_Mode_ID,@From_Date,@Period,@To_Date,@Leave_ID,@HalfLeavedate,@LeaveType,@Remarks,@NightDay,@State_ID,@City_ID,@Loc_ID,@Project_ID
						END
					CLOSE TRAVELDETAIL_CURSOR
					DEALLOCATE TRAVELDETAIL_CURSOR
				END
			
			---- Travel Approval Details END ---
			---- Travel Approval Other Details START ---
			
			IF (@TravelDetail.exist('/NewDataSet/OtherDetails') = 1)
				BEGIN 
					SELECT Table1.value('(Travel_Mode_ID/text())[1]','numeric(18,0)') AS Travel_Mode_ID,
					CONVERT(datetime, Table1.value('(FromDate/text())[1]','varchar(50)'),103) AS FromDate,
					Table1.value('(Description/text())[1]','varchar(MAX)') AS OtherDescription,
					ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0) AS Amount,
					Table1.value('(Self_Pay/text())[1]','int') AS Self_Pay,
					CONVERT(datetime, Table1.value('(ToDate/text())[1]','varchar(50)'),103) AS ToDate,
					Table1.value('(Currency_ID/text())[1]','numeric(18,0)') AS Currency_ID,
					Table1.value('(SGSTAmt/text())[1]','numeric(18,2)') AS SGSTAmt,
					Table1.value('(CGSTAmt/text())[1]','numeric(18,2)') AS CGSTAmt,
					Table1.value('(IGSTAmt/text())[1]','numeric(18,2)') AS IGSTAmt,
					Table1.value('(GSTNo/text())[1]','varchar(50)') AS GSTNo,
					Table1.value('(GST_CompanyName/text())[1]','varchar(50)') AS GST_CompanyName
					INTO #TravelOtherDetailApproval FROM @TravelDetail.nodes('/NewDataSet/OtherDetails') AS Temp(Table1)  
		    
					DECLARE TRAVELOTHERDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
					
					SELECT Travel_Mode_ID,FromDate,OtherDescription,Amount,Self_Pay,ToDate,Currency_ID,SGSTAmt,
					CGSTAmt,IGSTAmt,GSTNo,GST_CompanyName
					FROM #TravelOtherDetailApproval
					
					OPEN TRAVELOTHERDETAIL_CURSOR 
					FETCH NEXT FROM TRAVELOTHERDETAIL_CURSOR INTO @Travel_Mode_ID,@From_Date,@Description,@Amount,@Self_Pay,@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name
					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL @Travel_Apr_Other_Detail_Id = 0,@Cmp_ID = @Cmp_ID,
							@Tran_ID = 0,@Travel_Mode_Id = @Travel_Mode_ID,@For_date = @From_Date,@Description	= @Description,
							@Amount = @Amount,@Self_Pay = @Self_Pay,@Tran_Type = 'I',@Curr_ID = @Curr_ID,@To_Date = @To_Date,@SGST = @SGST,
							@CGST = @CGST,@IGST = @IGST,@GST_No = @GST_No,@GST_Company_Name = @GST_Company_Name
							
							IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
								BEGIN
									EXEC P0130_TRAVEL_Approval_OTHER_DETAIL @Travel_Apr_Other_Detail_Id = 0,@Cmp_ID = @Cmp_ID,
									@Travel_Approval_ID = @Travel_Approval_ID,@Travel_Mode_Id = @Travel_Mode_ID,@For_date = @From_Date,
									@Description = @Description,@Amount = @Amount,@Self_Pay = @Self_Pay,@Tran_Type = 'I',@To_Date = @To_Date,
									@Curr_ID = @Curr_ID,@SGST = @SGST,@CGST = @CGST,@IGST = @IGST,@GST_No = @GST_No,@GST_Company_Name = @GST_Company_Name
								END
							FETCH NEXT FROM TRAVELOTHERDETAIL_CURSOR  INTO @Travel_Mode_ID,@From_Date,@Description,@Amount,@Self_Pay,@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name
						END
					CLOSE TRAVELOTHERDETAIL_CURSOR 
					DEALLOCATE TRAVELOTHERDETAIL_CURSOR
				END
			---- Travel Approval Other Details END ---
			
			---- Travel Approval Advance Details START ---
			IF (@TravelDetail.exist('/NewDataSet/AdvanceDetails') = 1)
				BEGIN
					SELECT Table1.value('(ExpenceType/text())[1]','varchar(100)') AS ExpenceType,
					ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0) AS Amount,
					Table1.value('(Remarks/text())[1]','varchar(MAX)') AS Remarks,
					ISNULL(Table1.value('(Currency_ID/text())[1]','numeric(18,2)'),0) AS Currency_ID
					INTO #TravelAdvDetailApproval FROM @TravelDetail.nodes('/NewDataSet/AdvanceDetails') AS Temp(Table1)  
		    
					DECLARE TRAVELADVANCEDETAIL_CURSOR CURSOR FAST_FORWARD FOR
					SELECT ExpenceType,Amount,Remarks,Currency_ID FROM #TravelAdvDetailApproval
					OPEN TRAVELADVANCEDETAIL_CURSOR
					FETCH NEXT FROM TRAVELADVANCEDETAIL_CURSOR INTO @Expence_Type,@Amount,@Description,@Curr_ID
					WHILE @@FETCH_STATUS = 0
						BEGIN
							EXEC P0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL @Row_Adv_ID = 0,@Travel_App_ID = @Travel_Application_ID,
							@Tran_ID = 0,@Cmp_ID = @Cmp_ID,@Expence_Type = @Expence_Type,@Amount = @Amount,
							@Adv_Detail_Desc = @Description,@Curr_ID = @Curr_ID,@Tran_Type = 'I'
							
							IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R') 
								BEGIN
									EXEC P0130_TRAVEL_APPROVAL_ADVDETAIL @Travel_Approval_AdvDetail_ID = 0,@Cmp_ID = @Cmp_ID,
									@Travel_Approval_ID = @Travel_Approval_ID,@Expence_Type = @Expence_Type,@Amount = @Amount,
									@Adv_Detail_Desc = @Description,@Curr_ID = @Curr_ID,@Tran_Type = 'I'
								END
							FETCH NEXT FROM TRAVELADVANCEDETAIL_CURSOR INTO @Expence_Type,@Amount,@Description,@Curr_ID
						END
					CLOSE TRAVELADVANCEDETAIL_CURSOR
					DEALLOCATE TRAVELADVANCEDETAIL_CURSOR
				END
			
			---- Travel Approval Advance Details END ---
			IF @Travel_Application_ID <> 0
				BEGIN
					IF @Approval_Status = 'R'
						BEGIN
							SET @Result = 'Travel Application Rejected#True#'+CAST(@Travel_Approval_ID AS varchar(10))	
								--SELECT 'Leave Reject Done#True#'
							END
						ELSE
							BEGIN
								SET @Result = 'Travel Application Approved#True#'+CAST(@Travel_Approval_ID AS varchar(10))	
								--SELECT 'Leave Approval Done#True#'
							END
				END
			SELECT @Result
			
			EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @EMP_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Travel Application',
			@Flag = @Flag,@Leave_ID = 0,@Rpt_Level = @Rpt_Level,@Final_Approval = @Final_Approve
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
			SELECT @Result
			ROLLBACK 
		END CATCH
	END
ELSE IF @Type = 'S' --- For Travel Application Status
	BEGIN
		SELECT Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code, Emp_Full_Name, Supervisor, 
		Branch_Name,Desig_Name,Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,
		(CASE WHEN Application_Status = 'P' THEN 'Pending' ELSE CASE WHEN Application_Status = 'D' THEN 'Draft' ELSE CASE WHEN Application_Status = 'A' THEN 'Approved' ELSE 'Rejected' END END END) AS 'Application_Status'
		FROM V0100_TRAVEL_APPLICATION
		WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @EMP_ID AND Application_Date >= @From_Date AND Application_Date <= @To_Date
		ORDER BY Application_Code ASC
	END
ELSE IF @Type = 'P' --- For Travel Application Pending List
	BEGIN
		EXEC SP_Get_Travel_Application_Records @Cmp_ID = @Cmp_ID,@Emp_ID = @EMP_ID,@Rpt_level = 0,
		@Constrains = 'Application_Status IN (''P'',''D'')',@OrderBy='Order by Application_Date desc'
	END
ELSE IF @Type = 'E' --- For Travel Application Details
	BEGIN
		--SELECT *
		--FROM V0100_TRAVEL_APPLICATION VTA 
		--LEFT JOIN V0110_TRAVEL_APPLICATION_DETAIL TA ON VTA.Travel_Application_ID = TA.Travel_Application_ID
		--LEFT JOIN V0110_TRAVEL_ADVANCE_DETAIL TAD ON TA.Travel_Application_ID = TAD.Travel_App_ID
		--LEFT JOIN V0110_TRAVEL_APPLICATION_OTHER_DETAIL TAO ON TA.Travel_Application_ID = TAO.Travel_App_ID
		--WHERE VTA.Travel_Application_ID = @Travel_Application_ID
		
		SELECT * FROM T0100_TRAVEL_APPLICATION WITH (NOLOCK) WHERE Travel_Application_ID = @Travel_Application_ID
		SELECT * FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) WHERE Travel_App_ID = @Travel_Application_ID
		SELECT * FROM T0110_TRAVEL_APPLICATION_OTHER_DETAIL WITH (NOLOCK) WHERE Travel_App_ID  = @Travel_Application_ID
		SELECT * FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE Travel_App_ID = @Travel_Application_ID
		
		SELECT @Emp_ID = Emp_ID FROM T0100_TRAVEL_APPLICATION WITH (NOLOCK) WHERE Travel_Application_ID = @Travel_Application_ID
		
		DECLARE @GradeID numeric(18,0)
		
		SELECT @GradeID = ISNULL(Grd_ID,0) FROM V0080_Employee_Master WHERE Emp_ID = @Emp_ID
		
		SELECT Leave_ID,Leave_Name 
		FROM V0040_LEAVE_DETAILS 
		WHERE (1=(CASE ISNULL(leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(InActive_Effective_Date,GETDATE())>GETDATE() THEN 1 ELSE 0 END ) ELSE 1 END )) 
		AND Leave_Type = 'Company Purpose' AND Grd_ID = @GradeID 
		ORDER BY Leave_Name
	END
ELSE IF @Type = 'D' --- For Delete Travel Application 
	BEGIN
		BEGIN TRY
			EXEC P0100_TRAVEL_APPLICATION @Travel_Application_ID = @Travel_Application_ID,@Cmp_ID = @Cmp_ID,
			@Emp_ID = @Emp_ID,@S_Emp_ID = @S_Emp_ID,@Application_Date = @Trans_Date,@Application_Code = '',
			@Application_Status = 'P',@Login_ID = @Login_ID,@chk_Adv = @Chk_Advance,@chk_Agenda = @Chk_Agenda,
			@Tour_Agenda = @Tour_Agenda,@IMP_Business_Appoint = @IMP_Business_Appoint,@KRA_Tour = @KRA_Tour,
			@Attached_Doc_File = @Attached_Doc_File,@Tran_Type = 'D',@Chk_International = @Chk_International,
			@User_Id = @Login_ID,@IP_Address = @IP_Address
			
			SET @Result = 'Travel Application Delete Successfully#True#'
			SELECT @Result
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
			SELECT @Result
			ROLLBACK 
		END CATCH
	END

