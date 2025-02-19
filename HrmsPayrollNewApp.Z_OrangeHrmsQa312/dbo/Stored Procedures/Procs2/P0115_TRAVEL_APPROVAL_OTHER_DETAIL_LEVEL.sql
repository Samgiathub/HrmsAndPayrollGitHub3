

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL]
	 @Travel_Apr_Other_Detail_Id	Numeric(18,0)
	,@Cmp_ID					Numeric(18,0)
	,@Tran_ID					Numeric(18,0)
	,@Travel_Mode_Id			numeric(18,0)
	,@For_date					Datetime
	,@Description				NVarchar(250)
	,@Amount					Numeric(18,2)
	,@Self_Pay					tinyint
	,@Tran_Type					Char(1)
	,@Curr_ID					numeric(18,0)=0
	,@To_Date					datetime 
	,@SGST						numeric(18,2) = 0 --Added by Jaina 27-09-2017
	,@CGST						numeric(18,2) = 0 --Added by Jaina 27-09-2017
	,@IGST						numeric(18,2) = 0 --Added by Jaina 27-09-2017
	,@GST_No					nvarchar(15) ='' --Added by Jaina 4-12-2017
	,@GST_Company_Name			nvarchar(250) = '' --Added by Jaina 4-12-2017
	,@Travel_Detail				xml = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

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
	
	IF (@Travel_Detail.exist('/NewDataSet/Table1') = 1) -- For Web XML
	BEGIN
	
		SELECT Table1.value('(Travel_Mode/text())[1]','numeric(18,0)') AS Travel_Mode,
		Table1.value('(From_Place/text())[1]','varchar(50)') AS From_Place,
		Table1.value('(To_Place/text())[1]','varchar(50)') AS To_Place,
		Table1.value('(Mode_Name/text())[1]','varchar(50)') AS Mode_Name,
		Table1.value('(Mode_No/text())[1]','varchar(50)') AS Mode_No,
		Table1.value('(City/text())[1]','varchar(50)') AS City,
		Table1.value('(Check_Out_Date/text())[1]','varchar(20)') AS Check_Out_Date,
		Table1.value('(No_Passenger/text())[1]','numeric(18,0)') AS No_Pessenger,
		Table1.value('(Booking_Date/text())[1]','varchar(20)') AS Booking_Date,
		Table1.value('(Pick_Up_Address/text())[1]','varchar(255)') AS Pick_Up_Address,
		Table1.value('(Pick_Up_Time/text())[1]','varchar(15)') AS Pick_Up_Time,
		Table1.value('(Drop_Address/text())[1]','varchar(255)') AS Drop_Address,
		Table1.value('(Bill_No/text())[1]','varchar(255)') AS Bill_No,
		Table1.value('(Description/text())[1]','varchar(255)') AS [Description]
		
		INTO #ItemTemp FROM @Travel_Detail.nodes('/NewDataSet/Table1') as Temp(Table1)
		select * from #ItemTemp
	
	
	
	SELECT @Cmp_ID = Cmp_ID FROM T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) WHERE Tran_ID = @Tran_ID 
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			Select @Travel_Apr_Other_Detail_Id = ISNULL(MAX(Travel_Apr_Other_Detail_Id),0) + 1 From T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL WITH (NOLOCK)
			
			Insert Into T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL
					(Travel_Apr_Other_Detail_Id, Cmp_ID, Tran_ID, Travel_Mode_Id,For_date, Description,Amount,Self_Pay,modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name )
			Values (@Travel_Apr_Other_Detail_Id, @Cmp_ID, @Tran_ID, @Travel_Mode_Id,@For_date, @Description,@Amount, @Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name)
			
			
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
					FROM T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL WITH (NOLOCK)
					
					
					INSERT INTO T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL
					(
						TRAN_ID,
						CMP_ID,
						TRAVEL_APPROVAL_OTHER_DETAIL_ID,
						OTHER_TRAN_ID,
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
						[DESCRIPTION],
						SYSTEM_DATE
					)
					VALUES
					(
						@MODE_TRAN_ID,
						@CMP_ID,
						@TRAVEL_APR_OTHER_DETAIL_ID,
						@TRAN_ID,
						@TRAVEL_MODE,
						@FROM_PLACE,
						@TO_PLACE,
						@MODE_NAME,
						@MODE_NO,
						@CITY,
						@CHECK_OUT_DATE,
						@NO_PESSENGER,
						@BOOKING_DATE,
						@PICK_UP_ADDRESS,
						@PICK_UP_TIME,
						@DROP_ADDRESS,
						@BILL_NO,
						@TDescription,
						GETDATE()
					
					)
					
					FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
														@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
				END
			CLOSE ITEM_CURSOR
			DEALLOCATE ITEM_CURSOR
		End
		
END

END
