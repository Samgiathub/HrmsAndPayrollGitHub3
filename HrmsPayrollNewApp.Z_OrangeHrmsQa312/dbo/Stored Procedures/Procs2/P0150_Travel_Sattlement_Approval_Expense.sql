---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_Travel_Sattlement_Approval_Expense]  
   @int_Exp_Id numeric(18,0) output
  ,@Int_Id numeric(18, 0) 
  ,@Travel_Settlement_Id numeric(18, 0) 
  ,@Travel_Approval_ID numeric(18, 0) 
  ,@cmp_id numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@for_Date datetime  
  ,@Amount Numeric(20)  
  ,@Approved_Amount numeric(18,2)
  ,@Comments varchar(max)  
  ,@expense_type_id varchar(100)
  ,@Missing varchar(1)  
  ,@From_Time varchar(25) = '' 
  ,@To_Time varchar(25) = ''
  ,@Duration float = 0 
  ,@Appr_From_Time varchar(25) = '' 
  ,@Appr_To_Time varchar(25) = ''
  ,@Appr_Duration float = 0
  ,@Grp_Emp varchar(max)=''
  ,@Grp_Emp_ID varchar(max)=''
  ,@Curr_ID numeric(18,0)=0
  ,@Curr_Amount float=0
  ,@Ex_rate numeric(18,2)=0
  ,@Exp_Km numeric(18,2)=0
  ,@Travel_Detail	xml = ''
  ,@SelfPay	tinyint=0
  ,@No_of_Days	numeric(18,2)
  ,@GuestName	varchar(max)  =''
  ,@tran_type  Varchar(1)   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
   declare @visit tinyint 
   SET @visit = 0
     if len(@Curr_Amount) > 4
		set @Curr_Amount =0

     
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
	
	IF (@Travel_Detail.exist('/NewDataSet/Table1') = 1) -- For Web XML
	BEGIN
		SELECT Table1.value('(Travel_Mode/text())[1]','numeric(18,0)') AS Travel_Mode,
		Table1.value('(From_Place/text())[1]','varchar(50)') AS From_Place,
		Table1.value('(To_Place/text())[1]','varchar(50)') AS To_Place,
		Table1.value('(Mode_Name/text())[1]','varchar(50)') AS Mode_Name,
		Table1.value('(Mode_No/text())[1]','varchar(50)') AS Mode_No,
		
		Table1.value('(City/text())[1]','varchar(50)') AS City,
		Table1.value('(Check_Out_Date/text())[1]','varchar(20)') AS Check_Out_Date,
		Table1.value('(No_Pessenger/text())[1]','varchar(50)') AS No_Pessenger,
		Table1.value('(Booking_Date/text())[1]','varchar(20)') AS Booking_Date,
		Table1.value('(Pick_Up_Address/text())[1]','varchar(255)') AS Pick_Up_Address,
		Table1.value('(Pick_Up_Time/text())[1]','varchar(15)') AS Pick_Up_Time,
		Table1.value('(Drop_Address/text())[1]','varchar(255)') AS Drop_Address,
		Table1.value('(Bill_No/text())[1]','varchar(255)') AS Bill_No,
		Table1.value('(Description/text())[1]','varchar(255)') AS [Description]
		
		INTO #ItemTemp FROM @Travel_Detail.nodes('/NewDataSet/Table1') as Temp(Table1)
	END	
	
	
  IF @TRAN_TYPE ='I'   
   BEGIN  
    
			SELECT @INT_EXP_ID  = ISNULL(MAX(INT_EXP_ID ),0) + 1 
			FROM T0150_TRAVEL_SETTLEMENT_APPROVAL_EXPENSE WITH (NOLOCK) --AND CMP_ID=@CMP_ID
      
			SELECT  @EXPENSE_TYPE_ID = EXPENSE_TYPE_ID 
			FROM T0040_EXPENSE_TYPE_MASTER WITH (NOLOCK)
			WHERE EXPENSE_TYPE_NAME = @EXPENSE_TYPE_ID AND CMP_ID=@CMP_ID
     
   
     
		   INSERT INTO T0150_TRAVEL_SETTLEMENT_APPROVAL_EXPENSE  
			  (  
					int_Exp_Id,int_Id,Travel_Settlement_Id,Travel_Approval_Id,Emp_ID,Cmp_ID,For_Date,Amount,Approved_Amount,Expense_Type_id,
					Comments,Missing,From_Time,To_Time,Duration,Appr_From_Time,Appr_To_Time,Appr_Duration,Grp_Emp,Grp_Emp_ID,Curr_ID,
					Curr_Amount,Exchange_rate,ExpKm,SelfPay,No_of_days,GuestName
			  )  
			  VALUES        
			  (
					@int_Exp_Id
				   ,@Int_Id  
				   ,@Travel_Settlement_Id
				   ,@Travel_Approval_ID  
				   ,@Emp_ID 
				   ,@Cmp_ID 
				   ,@for_Date 
				   ,@Amount  
				   ,@Approved_Amount
				   ,@expense_type_id  
				   ,@Comments  
				   ,@Missing  
				   ,@from_Time 
				   ,@To_Time
				   ,@Duration
				   ,@Appr_From_Time
				   ,@Appr_To_Time
				   ,@Appr_Duration
				   ,@Grp_Emp
				   ,@Grp_Emp_ID
				   ,@Curr_ID
				   ,@Curr_Amount
				   ,@Ex_rate
				   ,@Exp_Km
				   ,@SelfPay
				   ,@No_of_Days
				   ,@GuestName
			   )  
			
			
			IF EXISTS(	SELECT	1
						FROM	T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK)
						WHERE	INT_ID = @INT_ID AND TRAVEL_SET_APPLICATION_ID = @TRAVEL_SETTLEMENT_ID AND CMP_ID = @CMP_ID)
				BEGIN
				
					SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
					FROM T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE WITH (NOLOCK)
					
					
					
					INSERT INTO T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE
					SELECT TOP 1	@MODE_TRAN_ID,CMP_ID,INT_ID,@TRAVEL_SETTLEMENT_ID,@TRAVEL_APPROVAL_ID,TRAVEL_MODE,
							FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CHECK_OUT_DATE,NO_PASSENGER,BOOKING_DATE,PICK_UP_ADDRESS,
							PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[Description]
					FROM	T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK)
					WHERE	INT_ID = @INT_ID AND TRAVEL_SET_APPLICATION_ID = @TRAVEL_SETTLEMENT_ID AND CMP_ID = @CMP_ID
				
				END
	
			
       
   
 END  
 ELSE IF @TRAN_TYPE ='U'   
    BEGIN  
     
				 update T0150_Travel_Settlement_Approval_Expense   
					 set for_Date = @for_Date  
						 ,Amount = @Amount
						 ,expense_type_id = @expense_type_id  
						 ,Comments = @Comments
						 ,Missing=@Missing
						 ,Approved_Amount=@Approved_Amount
						 ,From_Time = @From_Time
						 ,To_Time = @To_Time
						 ,Duration = @Duration
						 ,Appr_From_Time = @Appr_From_Time
						 ,Appr_To_Time = @Appr_To_Time
						 ,Appr_Duration = @Appr_Duration
						 ,Grp_Emp=@Grp_Emp
						 ,Grp_Emp_ID=@Grp_Emp_ID
						 ,Curr_ID=@Curr_ID
						 ,Curr_Amount=@Curr_Amount
						 ,Exchange_rate=@Ex_rate
						 ,ExpKm=@Exp_Km
						 ,SelfPay=@SelfPay
						 ,No_of_days=@No_of_Days
						 ,GuestName=@GuestName
				 where   emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and int_id=@Int_Id and int_Exp_Id=@int_Exp_Id
				 
				 
			---- CURSOR FOR TRAVEL MODE DETAILS ENTRY
			--DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR		
			--SELECT	TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,NO_PESSENGER,
			--		CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,
			--		PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION] 
			--FROM	#ITEMTEMP
			
			--OPEN ITEM_CURSOR
			--FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
			--									@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
			--WHILE @@fetch_status = 0
			--	BEGIN
					
			--		SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 
			--		FROM T0150_TRAVEL_SETTLEMENT_APPROVAL_EXPENSE

					
			--		INSERT INTO T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE
			--		(
			--			TRAN_ID,
			--			CMP_ID,
			--			INT_ID,
			--			TRAVEL_SETTLEMENT_ID,
			--			TRAVEL_APPROVAL_ID,
			--			TRAVEL_MODE,
			--			FROM_PLACE,
			--			TO_PLACE,
			--			MODE_NAME,
			--			MODE_NO,
			--			CITY,
			--			CHECK_OUT_DATE,
			--			NO_PASSENGER,
			--			BOOKING_DATE,
			--			PICK_UP_ADDRESS,
			--			PICK_UP_TIME,
			--			DROP_ADDRESS,
			--			BILL_NO,
			--			[DESCRIPTION]
			--		)
			--		VALUES
			--		(
			--			@MODE_TRAN_ID,
			--			@CMP_ID,
			--			@INT_ID,
			--			@TRAVEL_SETTLEMENT_ID,
			--			@TRAVEL_APPROVAL_ID, 
			--			@TRAVEL_MODE,
			--			@FROM_PLACE,
			--			@TO_PLACE,
			--			@MODE_NAME,
			--			@MODE_NO,
			--			@CITY,
			--			@CHECK_OUT_DATE,
			--			@NO_PESSENGER,
			--			@BOOKING_DATE,
			--			@PICK_UP_ADDRESS,
			--			@PICK_UP_TIME,
			--			@DROP_ADDRESS,
			--			@BILL_NO,
			--			@TDescription
					
			--		)
					
			--		FETCH NEXT FROM ITEM_CURSOR INTO	@TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,
			--											@PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription 
			--	END
			--CLOSE ITEM_CURSOR
			--DEALLOCATE ITEM_CURSOR
				 
				 
    end  
  else if @tran_type ='D'  
  begin  
  
	delete from T0150_Travel_Settlement_Approval_Expense 
	where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and int_id=@Int_Id and int_Exp_Id=@int_Exp_Id
	
  end
  
 RETURN  
  
  
  
  
  
  