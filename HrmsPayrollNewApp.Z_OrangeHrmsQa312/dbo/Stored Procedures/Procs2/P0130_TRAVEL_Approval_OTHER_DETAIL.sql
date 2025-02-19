
CREATE PROCEDURE [dbo].[P0130_TRAVEL_Approval_OTHER_DETAIL]
	 @Travel_Apr_Other_Detail_Id	Numeric(18,0)
	,@Cmp_ID					Numeric(18,0)
	,@Travel_Approval_ID				Numeric(18,0)
	,@Travel_Mode_Id			numeric(18,0)
	,@For_date					Datetime
	,@Description				NVarchar(250)
	,@Amount					Numeric(18,2)
	,@Self_Pay					tinyint
	,@Tran_Type					Char(1) 
	,@To_Date					datetime
	,@Curr_ID					numeric(18,0)=0
	,@SGST						numeric(18,2) = 0 
	,@CGST						numeric(18,2) = 0 
	,@IGST						numeric(18,2) = 0 
	,@GST_No					Nvarchar(15) = '' 
	,@GST_Company_Name			Nvarchar(250) = ''
	,@Travel_Detail				xml = ''
	,@Mode_Id					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if (@to_date='1900-01-01 00:00:00')
	Begin
		set @To_Date=null
	End
	
	
	
	---- XML Records 
	DECLARE @Travel_Mode numeric(18,0)
	DECLARE @From_Place varchar(50)
	DECLARE @To_Place varchar(50)
	DECLARE @Mode_Name varchar(50)
	DECLARE @Mode_No varchar(50)
	--DECLARE @Travel_Date varchar(15)
	--DECLARE @Dep_Time varchar(15)
	DECLARE @City varchar(50)
	DECLARE @Check_Out_Date varchar(20)
	DECLARE @No_Pessenger numeric(18,0)
	DECLARE @Booking_Date varchar(20)
	DECLARE @Pick_Up_Address varchar(MAX)
	DECLARE @Pick_Up_Time varchar(15)
	DECLARE @Drop_Address varchar(MAX)
	
	DECLARE @Bill_No varchar(50)
	DECLARE @TDescription varchar(MAX)
	
	DECLARE @MODE_TRAN_ID AS NUMERIC(18,0)
	SET @MODE_TRAN_ID = 0
	--select  @Travel_Detail
	IF (@Travel_Detail.exist('/NewDataSet/Table1') = 1) -- For Web XML
	BEGIN
		SELECT Table1.value('(Travel_Mode/text())[1]','numeric(18,0)') AS Travel_Mode,
		Table1.value('(From_Place/text())[1]','varchar(50)') AS From_Place,
		Table1.value('(To_Place/text())[1]','varchar(50)') AS To_Place,
		Table1.value('(Mode_Name/text())[1]','varchar(50)') AS Mode_Name,
		Table1.value('(Mode_No/text())[1]','varchar(50)') AS Mode_No,
		--Table1.value('(Travel_Date/text())[1]','varchar(15)') AS Travel_Date,
		
		--Table1.value('(Dep_Time/text())[1]','varchar(50)') AS Dep_Time,
		Table1.value('(City/text())[1]','varchar(50)') AS City,
		Table1.value('(Check_Out_Date/text())[1]','varchar(20)') AS Check_Out_Date,
		Table1.value('(No_Passenger/text())[1]','varchar(20)') AS No_Pessenger,
		Table1.value('(Booking_Date/text())[1]','varchar(20)') AS Booking_Date,
		Table1.value('(Pick_Up_Address/text())[1]','varchar(255)') AS Pick_Up_Address,
		Table1.value('(Pick_Up_Time/text())[1]','varchar(15)') AS Pick_Up_Time,
		Table1.value('(Drop_Address/text())[1]','varchar(255)') AS Drop_Address,
		Table1.value('(Bill_No/text())[1]','varchar(255)') AS Bill_No,
		Table1.value('(Description/text())[1]','varchar(255)') AS [Description]
		
		INTO #ItemTemp FROM @Travel_Detail.nodes('/NewDataSet/Table1') as Temp(Table1)
	END	

	select * from #ItemTemp
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			Select @Travel_Apr_Other_Detail_Id = ISNULL(MAX(Travel_Apr_Other_Detail_Id),0) + 1 From t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK)
			--Select  @Travel_App_ID= ISNULL(MAX(Travel_Application_ID),0)  from T0100_TRAVEL_APPLICATION
			if Not Exists(select 1 from t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and For_date=@For_date and Description=@Description and Amount=@Amount)
			Begin
				Insert Into t0130_TRAVEL_Approval_OTHER_DETAIL
						(Travel_Apr_Other_Detail_Id, Cmp_ID, Travel_Approval_ID, Travel_Mode_Id,For_date, Description,Amount,Self_Pay,modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name,Mode_Id )
					Values (@Travel_Apr_Other_Detail_Id, @Cmp_ID, @Travel_Approval_ID, @Travel_Mode_Id,@For_date, @Description,@Amount, @Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name,@Mode_Id)
			End	
			
			
			IF (@Travel_Detail.exist('/NewDataSet/Table1') = 1) -- For Web XML --Condition added by Yogesh patel  on 27112023
			begin
			---- CURSOR FOR TRAVEL MODE DETAILS ENTRY
			DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR		
			SELECT	TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,NO_PESSENGER,
					CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,
					PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION] 
			FROM	#ITEMTEMP
			
			OPEN ITEM_CURSOR
			FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
												@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
			WHILE @@fetch_status = 0
				BEGIN
					
					SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
					FROM T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL WITH (NOLOCK)

					--select @No_Pessenger
					INSERT INTO T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL
					(
						TRAN_ID,
						CMP_ID,
						TRAVEL_APPROVAL_OTHER_DETAIL_ID,
						TRAVEL_APPROVAL_ID,
						TRAVEL_MODE,
						FROM_PLACE,
						TO_PLACE,
						MODE_NAME,
						MODE_NO,
						--TRAVEL_DATE,
						--DEP_TIME,
						CITY,
						CHECK_OUT_DATE,
						NO_PASSENGER,
						BOOKING_DATE,
						PICK_UP_ADDRESS,
						PICK_UP_TIME,
						DROP_ADDRESS,
						BILL_NO,
						[DESCRIPTION]
					)
					VALUES
					(
						@MODE_TRAN_ID,
						@CMP_ID,
						@TRAVEL_APR_OTHER_DETAIL_ID,
						@TRAVEL_APPROVAL_ID,
						@TRAVEL_MODE,
						@FROM_PLACE,
						@TO_PLACE,
						@MODE_NAME,
						@MODE_NO,
						--@TRAVEL_DATE,
						--@DEP_TIME,
						@CITY,
						@CHECK_OUT_DATE,
						@NO_PESSENGER,
						@BOOKING_DATE,
						@PICK_UP_ADDRESS,
						@PICK_UP_TIME,
						@DROP_ADDRESS,
						@BILL_NO,
						@TDescription
					
					)
					
					FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
														@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
				END
			CLOSE ITEM_CURSOR
			DEALLOCATE ITEM_CURSOR
			
			end	
		End
	Else If UPPER(@Tran_Type) = 'U'
		Begin
			
			Select @Travel_Apr_Other_Detail_Id = ISNULL(MAX(Travel_Apr_Other_Detail_Id),0) + 1 From t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK)
			
			if Not Exists(select 1 from t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and For_date=@For_date and Description=@Description and Amount=@Amount)
			Begin
				Insert Into t0130_TRAVEL_Approval_OTHER_DETAIL
					(Travel_Apr_Other_Detail_Id, Cmp_ID, Travel_Approval_ID, Travel_Mode_Id,For_date, Description,Amount,Self_Pay,modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name,Mode_Id)
				Values (@Travel_Apr_Other_Detail_Id, @Cmp_ID, @Travel_Approval_ID, @Travel_Mode_Id,@For_date, @Description,@Amount, @Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name,@Mode_Id)
			End	
			
			
			
			---- CURSOR FOR TRAVEL MODE DETAILS ENTRY
			DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR		
			SELECT	TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,NO_PESSENGER,
					CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,
					PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION] 
			FROM	#ITEMTEMP
			
			OPEN ITEM_CURSOR
			FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
												@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
			WHILE @@fetch_status = 0
				BEGIN
					
					SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
					FROM T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL WITH (NOLOCK)

					
					INSERT INTO T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL
					(
						TRAN_ID,
						CMP_ID,
						TRAVEL_APPROVAL_OTHER_DETAIL_ID,
						TRAVEL_APPROVAL_ID,
						TRAVEL_MODE,
						FROM_PLACE,
						TO_PLACE,
						MODE_NAME,
						MODE_NO,
						--TRAVEL_DATE,
						--DEP_TIME,
						CITY,
						CHECK_OUT_DATE,
						NO_PASSENGER,
						BOOKING_DATE,
						PICK_UP_ADDRESS,
						PICK_UP_TIME,
						DROP_ADDRESS,
						BILL_NO,
						[DESCRIPTION]
					)
					VALUES
					(
						@MODE_TRAN_ID,
						@CMP_ID,
						@TRAVEL_APR_OTHER_DETAIL_ID,
						@TRAVEL_APPROVAL_ID,
						@TRAVEL_MODE,
						@FROM_PLACE,
						@TO_PLACE,
						@MODE_NAME,
						@MODE_NO,
						--@TRAVEL_DATE,
						--@DEP_TIME,
						@CITY,
						@CHECK_OUT_DATE,
						@NO_PESSENGER,
						@BOOKING_DATE,
						@PICK_UP_ADDRESS,
						@PICK_UP_TIME,
						@DROP_ADDRESS,
						@BILL_NO,
						@TDescription
					
					)
					
					FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
														@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
				END
			CLOSE ITEM_CURSOR
			DEALLOCATE ITEM_CURSOR	
		End	
END


