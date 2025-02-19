

CREATE PROCEDURE [dbo].[Mobile_HRMS_TRAVEL_Other_APPLICATION_DETAIL]
	 @Travel_App_Other_Detail_Id	Numeric(18,0) 
	,@Cmp_ID						Numeric(18,0)
	,@Travel_App_ID					Numeric(18,0)
	,@Tran_Type						Char(1) 
	,@Travel_Other_Details			xml = ''
AS
BEGIN


	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
	
	
	---- XML Records 
	DECLARE @Travel_Mode numeric(18,0)
	DECLARE @From_Place varchar(50)
	DECLARE @To_Place varchar(50)
	DECLARE @Mode_Name varchar(50)
	DECLARE @Mode_No varchar(50)
	DECLARE @City varchar(155)
	DECLARE @Check_Out_Date varchar(30)
	DECLARE @No_Pessenger numeric(18,0)
	DECLARE @Booking_Date varchar(30)
	DECLARE @Pick_Up_Address varchar(MAX)
	DECLARE @Pick_Up_Time varchar(15)
	DECLARE @Drop_Address varchar(MAX)
	
	DECLARE @Bill_No varchar(50)
	DECLARE @Other_Description VARCHAR(250) --mode description

	
	
	DECLARE @MODE_TRAN_ID AS NUMERIC(18,0)
	SET @MODE_TRAN_ID = 0

	DECLARE  @For_date VARCHAR(35)
	DECLARE  @For_time VARCHAR(35)
	DECLARE @TDescription varchar(MAX) --other description
	DECLARE  @Amount NUMERIC(18,0) 
	DECLARE  @Self_Pay int
	DECLARE  @modify_Date VARCHAR(55)
	DECLARE  @To_Date VARCHAR(15)
	DECLARE  @Curr_ID NUMERIC(18,0) 
	DECLARE	 @SGST  NUMERIC(18,0)
	DECLARE	 @CGST  NUMERIC(18,0)
	DECLARE	 @IGST  NUMERIC(18,0)
	DECLARE	 @GST_No VARCHAR(155)
	DECLARE	 @GST_Company_Name VARCHAR(120)
	
	If UPPER(@Tran_Type) = 'I' OR UPPER(@Tran_Type) = 'M'OR UPPER(@Tran_Type) = 'U'
	 BEGIN
	  IF(@Travel_Other_Details.exist('/NewDataSet/TravelOtherDetails') = 1) -- For Web XML
		BEGIN
			SELECT 
			(ROW_NUMBER() OVER(ORDER BY Table1.value('(Travel_App_Other_Detail_Id/text())[1]','NUMERIC(18,0)'))) AS Rownum,
				Table1.value('(Travel_App_Other_Detail_Id/text())[1]' ,'numeric(18,0)') AS Travel_App_Other_Detail_Id,
				Table1.value('(For_date/text())[1]','varchar(55)') AS For_date,
				Table1.value('(For_time/text())[1]','varchar(55)') AS For_time,
				Table1.value('(Description/text())[1]','varchar(255)') AS [Description],
				Table1.value('(Amount/text())[1]','numeric(18,0)') AS Amount,
				Table1.value('(Self_Pay/text())[1]','int') AS Self_Pay,
				Table1.value('(modify_Date/text())[1]','varchar(50)') AS modify_Date,
				Table1.value('(To_Date/text())[1]','varchar(55)') AS To_Date,
				Table1.value('(Curr_ID/text())[1]','numeric(18,0)') AS Curr_ID,
				Table1.value('(SGST/text())[1]','numeric(18,0)') AS SGST,
				Table1.value('(CGST/text())[1]','numeric(18,0)') AS CGST,
				Table1.value('(IGST/text())[1]','numeric(18,0)') AS IGST,
				Table1.value('(GST_No/text())[1]','varchar(55)') AS GST_No,
				Table1.value('(GST_Company_Name/text())[1]','varchar(55)') AS GST_Company_Name,
				Table1.value('(Travel_Mode_Id/text())[1]','numeric(18,0)') AS Travel_Mode,
				Table1.value('(From_Place/text())[1]','varchar(155)') AS From_Place,
				Table1.value('(To_Place/text())[1]','varchar(155)') AS To_Place,
				Table1.value('(Mode_Name/text())[1]','varchar(155)') AS Mode_Name,
				Table1.value('(Mode_No/text())[1]','varchar(155)') AS Mode_No,
				Table1.value('(City/text())[1]','varchar(155)') AS City,
				Table1.value('(Check_Out_Date/text())[1]','varchar(155)') AS Check_Out_Date,
				Table1.value('(No_Passenger/text())[1]','numeric(18,0)') AS No_Passenger,
				Table1.value('(Booking_Date/text())[1]','varchar(55)') AS Booking_Date,
				Table1.value('(Pick_Up_Address/text())[1]','varchar(255)') AS Pick_Up_Address,
				Table1.value('(Pick_Up_Time/text())[1]','varchar(155)') AS Pick_Up_Time,
				Table1.value('(Drop_Address/text())[1]','varchar(255)') AS Drop_Address,
				Table1.value('(Bill_No/text())[1]','varchar(255)') AS Bill_No,
				Table1.value('(Other_Description/text())[1]','varchar(255)') AS Other_Description
				
				INTO #ItemTemp FROM @Travel_Other_Details.nodes('/NewDataSet/TravelOtherDetails') as Temp(Table1)

				 DECLARE @COUNT int = 1
		
				 SELECT @COUNT = count(Travel_App_Other_Detail_Id) FROM #ItemTemp  
				
				 WHILE(@COUNT > 0)
				 BEGIN
					
						   SELECT top(1)
						   @Travel_App_Other_Detail_Id = ISnull(Travel_App_Other_Detail_Id,0),
						   @TRAVEL_MODE = Travel_Mode
						  ,@FOR_DATE = cast(For_date as datetime)+ cast(For_time as datetime)
						  ,@For_time = For_time,
						   @TDescription = [DESCRIPTION],
						   @AMOUNT = Amount,
						   @SELF_PAY = Self_Pay,
						   @modify_Date = modify_Date
						  ,@To_Date = To_Date,@Curr_ID = Curr_ID,@SGST = SGST,
						   @CGST = CGST,
						   @IGST = IGST
						  ,@GST_No = GST_No,@GST_COMPANY_NAME = GST_Company_Name,
						   @FROM_PLACE = FROM_PLACE,
						   @TO_PLACE = TO_PLACE
						  ,@MODE_NAME = MODE_NAME,@MODE_NO = MODE_NO
						  ,@CITY = City,@CHECK_OUT_DATE = CHECK_OUT_DATE,@NO_PESSENGER = No_Passenger,
						   @BOOKING_DATE = BOOKING_DATE,
						   @PICK_UP_ADDRESS = PICK_UP_ADDRESS
						  ,@PICK_UP_TIME = PICK_UP_TIME,
						   @DROP_ADDRESS = DROP_ADDRESS,
						   @BILL_NO = BILL_NO,
						   @OTHER_DESCRIPTION = Other_Description
						   
						   FROM #ItemTemp
						   WHERE Rownum = @COUNT
						   			
				 	SELECT @Travel_App_Other_Detail_Id = ISNULL(MAX(Travel_App_Other_Detail_Id),0) + 1 FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK)

					 IF NOT EXISTS(SELECT Travel_App_Other_Detail_Id FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
						AND Travel_App_ID=@Travel_App_ID AND Travel_Mode_Id = @Travel_Mode and [DESCRIPTION] = @TDescription and Amount = @Amount
						AND Self_Pay = @Self_Pay and SGST =@SGST and CGST = @CGST and IGST = @IGST and GST_No = @GST_No and GST_Company_Name = @GST_Company_Name
						AND For_date = @For_date)
		 				BEGIN
						
						IF (@to_date='1900-01-01 00:00:00')
								BEGIN
									 SET @To_Date=null
								END
			 
							IF (@Curr_ID=0)
							 BEGIN
			  					SET @Curr_ID=null;
							END
									 
							INSERT INTO T0110_Travel_Application_Other_Detail
									(Travel_App_Other_Detail_Id, Cmp_ID, Travel_App_ID, Travel_Mode_Id,For_date, [Description],Amount,Self_Pay,
									modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name)
							Values (@Travel_App_Other_Detail_Id, @Cmp_ID, @Travel_App_ID, @TRAVEL_MODE,@For_date, @TDescription,@Amount,
									@Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name)
							
		 				END
					
						SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
						FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WITH (NOLOCK)


						INSERT INTO T0110_TRAVEL_APPLICATION_MODE_DETAIL
						(
							TRAN_ID,
							CMP_ID,
							TRAVEL_APP_OTHER_DETAIL_ID,
							TRAVEL_APP_ID,
							TRAVEL_MODE,
							FROM_PLACE,
							TO_PLACE,
							MODE_NAME,
							MODE_NO,
							CITY,
							CHECK_OUT_DATE,
							NO_PASSENGER,
							BOOKING_DATE,
							PICK_UP_ADDRESS,
							PICK_UP_TIME,
							DROP_ADDRESS,
							BILL_NO,
							[Description]
						)
						VALUES
						(
							@MODE_TRAN_ID,
							@CMP_ID,
							@TRAVEL_APP_OTHER_DETAIL_ID,
							@TRAVEL_APP_ID,
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
							@Other_Description
						)

						SET @COUNT = @COUNT - 1 
				 END
			END
	END	
		
	--Else If UPPER(@Tran_Type)='U'
	--	begin
		
		
	--		SELECT @TRAVEL_APP_OTHER_DETAIL_ID = ISNULL(MAX(TRAVEL_APP_OTHER_DETAIL_ID),0) + 1 
	--		FROM T0110_TRAVEL_APPLICATION_OTHER_DETAIL WITH (NOLOCK)
		
	--		IF NOT EXISTS(SELECT TRAVEL_APP_OTHER_DETAIL_ID FROM T0110_TRAVEL_APPLICATION_OTHER_DETAIL WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@TRAVEL_APP_ID AND FOR_DATE=@FOR_DATE AND AMOUNT=@AMOUNT AND TRAVEL_MODE_ID=@TRAVEL_MODE_ID)
	--			BEGIN
	--				INSERT INTO T0110_TRAVEL_APPLICATION_OTHER_DETAIL
	--					(TRAVEL_APP_OTHER_DETAIL_ID, CMP_ID, TRAVEL_APP_ID, TRAVEL_MODE_ID,FOR_DATE, DESCRIPTION,AMOUNT,SELF_PAY,MODIFY_DATE,TO_DATE,CURR_ID,SGST,CGST,IGST,GST_NO,GST_COMPANY_NAME )
	--				VALUES (@TRAVEL_APP_OTHER_DETAIL_ID, @CMP_ID, @TRAVEL_APP_ID, @TRAVEL_MODE_ID,@FOR_DATE, @DESCRIPTION,@AMOUNT, @SELF_PAY,GETDATE(),@TO_DATE,@CURR_ID,@SGST,@CGST,@IGST,@GST_NO,@GST_COMPANY_NAME)
	--			END
			
			
	--		IF OBJECT_ID('TEMPDB..#ITEMTEMP') IS NOT NULL
	--			BEGIN
				
	--					---- CURSOR FOR TRAVEL MODE DETAILS ENTRY
	--					DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR		
	--					SELECT	TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,No_Passenger,
	--							CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,
	--							PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION] 
	--					FROM	#ITEMTEMP
						
	--					OPEN ITEM_CURSOR
	--					FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
	--														@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
	--					WHILE @@fetch_status = 0
	--						BEGIN
								
	--							SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
	--							FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WITH (NOLOCK)

								
	--							INSERT INTO T0110_TRAVEL_APPLICATION_MODE_DETAIL
	--							(
	--								TRAN_ID,
	--								CMP_ID,
	--								TRAVEL_APP_OTHER_DETAIL_ID,
	--								TRAVEL_APP_ID,
	--								TRAVEL_MODE,
	--								FROM_PLACE,
	--								TO_PLACE,
	--								MODE_NAME,
	--								MODE_NO,
	--								--TRAVEL_DATE,
	--								--DEP_TIME,
	--								CITY,
	--								CHECK_OUT_DATE,
	--								NO_PASSENGER,
	--								BOOKING_DATE,
	--								PICK_UP_ADDRESS,
	--								PICK_UP_TIME,
	--								DROP_ADDRESS,
	--								BILL_NO,
	--								[DESCRIPTION]
	--							)
	--							VALUES
	--							(
	--								@MODE_TRAN_ID,
	--								@CMP_ID,
	--								@TRAVEL_APP_OTHER_DETAIL_ID,
	--								@TRAVEL_APP_ID,
	--								@TRAVEL_MODE,
	--								@FROM_PLACE,
	--								@TO_PLACE,
	--								@MODE_NAME,
	--								@MODE_NO,
	--								--@TRAVEL_DATE,
	--								--@DEP_TIME,
	--								@CITY,
	--								@CHECK_OUT_DATE,
	--								@NO_PESSENGER,
	--								@BOOKING_DATE,
	--								@PICK_UP_ADDRESS,
	--								@PICK_UP_TIME,
	--								@DROP_ADDRESS,
	--								@BILL_NO,
	--								@TDescription
								
	--							)
								
	--							FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
	--																@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
	--						END
	--					CLOSE ITEM_CURSOR
	--					DEALLOCATE ITEM_CURSOR	
	--		END
			
			
	--	END

END

