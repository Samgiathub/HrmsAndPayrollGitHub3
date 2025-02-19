CREATE PROCEDURE [dbo].[Mobile_HRMS_P0130_TRAVEL_Approval_OTHER_DETAIL]
	 @Travel_Apr_Other_Detail_Id	Numeric(18,0)
	,@Cmp_ID					Numeric(18,0)
	,@Tran_Type					Char(1) 
	,@Tran_ID                   Numeric(18,0)
	,@Travel_Approval_ID		Numeric(18,0)
	,@Travel_Other_Details	    xml = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
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
	DECLARE @Other_Description VARCHAR(250) 
	
	DECLARE @MODE_TRAN_ID AS NUMERIC(18,0)
	SET @MODE_TRAN_ID = 0

	DECLARE  @For_date VARCHAR(35)
	DECLARE  @For_time VARCHAR(35)
	DECLARE  @TDescription varchar(MAX) 
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
	
	  IF(@Travel_Other_Details.exist('/NewDataSet/TravelOtherDetails') = 1) 
	BEGIN 
		SELECT
			(ROW_NUMBER() OVER(ORDER BY Table1.value('(Travel_App_Other_Detail_Id/text())[1]','NUMERIC(18,0)'))) AS Rownum,
					Table1.value('(Travel_App_Other_Detail_Id/text())[1]' ,'numeric(18,0)') AS Travel_Apr_Other_Detail_Id,
					Table1.value('(For_date/text())[1]','varchar(55)') AS For_date,
					Table1.value('(For_time/text())[1]','varchar(55)') AS For_time,
					Table1.value('(Description/text())[1]','varchar(255)') AS [Description],
					Table1.value('(Amount/text())[1]','numeric(18,0)') AS Amount,
					Table1.value('(Self_Pay/text())[1]','int') AS Self_Pay,
					--Table1.value('(modify_Date/text())[1]','varchar(50)') AS modify_Date,
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
				 SELECT @COUNT = count(Travel_Apr_Other_Detail_Id) FROM #ItemTemp  


				 WHILE(@COUNT > 0)
				 BEGIN
						   SELECT top(1)
						   @Travel_Apr_Other_Detail_Id = ISnull(Travel_Apr_Other_Detail_Id,0),
						   @TRAVEL_MODE = Travel_Mode
						  ,@FOR_DATE = cast(For_date as datetime)+ cast(For_time as datetime)
						  ,@For_time = For_time,
						   @TDescription = [DESCRIPTION],
						   @AMOUNT = Amount,
						   @SELF_PAY = Self_Pay
						   --,@modify_Date = modify_Date
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
						

					 --IF NOT EXISTS(SELECT Travel_Apr_Other_Detail_Id FROM T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
					 --   AND Travel_Mode_Id = @Travel_Mode and DESCRIPTION = @TDescription and Amount = @Amount  and Travel_Mode_ID = @Travel_Mode and Tran_ID = @Tran_ID
						--AND Self_Pay = @Self_Pay and SGST =@SGST and CGST = @CGST and IGST = @IGST and GST_No = @GST_No and GST_Company_Name = @GST_Company_Name
						--AND For_date = @For_date)
		 			--	BEGIN

						--IF (@to_date='1900-01-01 00:00:00')
						--		BEGIN
						--			 SET @To_Date=null
						--		END
			 
						--	IF (@Curr_ID=0)
						--	 BEGIN
			  	--				SET @Curr_ID=null;
						--	END
									 
						--	INSERT INTO T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL
						--			(Tran_ID,Travel_Mode_ID,Travel_Apr_Other_Detail_Id, Cmp_ID,For_date,Description,Amount,Self_Pay,
						--			modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name)
						--	Values (@Tran_ID,@Travel_Mode,@Travel_Apr_Other_Detail_Id, @Cmp_ID,@For_date, @TDescription,@Amount,
						--			@Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name)
							
		 			--	END
					

					Select @Travel_Apr_Other_Detail_Id = ISNULL(MAX(Travel_Apr_Other_Detail_Id),0) + 1 From t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK)
					If Not Exists(select 1 from t0130_TRAVEL_Approval_OTHER_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and For_date=@For_date and Description= @Other_Description and Amount=@Amount)
					BEGIN
						IF (@to_date='1900-01-01 00:00:00')
								BEGIN
									 SET @To_Date=null
								END
			 
							IF (@Curr_ID=0)
							 BEGIN
			  					SET @Curr_ID=null;
							END

						Insert Into t0130_TRAVEL_Approval_OTHER_DETAIL
							  (Travel_Apr_Other_Detail_Id, Cmp_ID, Travel_Approval_ID, Travel_Mode_Id,For_date, Description,Amount,Self_Pay,modify_Date,To_Date,Curr_ID,SGST,CGST,IGST,GST_No,GST_Company_Name)
						Values(@Travel_Apr_Other_Detail_Id, @Cmp_ID, @Travel_Approval_ID, @Travel_Mode,@For_date, @TDescription,@Amount, @Self_Pay,GETDATE(),@To_Date,@Curr_ID,@SGST,@CGST,@IGST,@GST_No,@GST_Company_Name)
					END

						SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL 


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

						SET @COUNT = @COUNT - 1 
					
				 END
	END	
	
	
END


