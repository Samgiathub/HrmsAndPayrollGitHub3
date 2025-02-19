


 
 ---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Sattlement]   
   @Travel_Set_Application_Id numeric(18, 0) OUTPUT  
  ,@Travel_Approval_ID numeric(18, 0) 
  ,@cmp_id numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@Approval_Date datetime  
  ,@Advance numeric(18,2)
  ,@Expense Numeric(18,2)
  ,@Credit_Amount Numeric(18,2)
  ,@Debit_Amount Numeric(18,2)
  ,@Comments varchar(500)  
  ,@filename varchar(500)  
  ,@visited_Flag varchar(1)
  ,@Direct_Entry tinyint =0
  ,@ODDates varchar(max)=null
  ,@tran_type  Varchar(1) 
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
  ,@IP_Address varchar(30)= '' -- Add By Mukti 11072016  
  ,@TourAgenda varchar(max) = ''
  ,@BusinessAppt varchar(max) = ''
  ,@TourAppt varchar(max) = ''
  ,@TravelTypeId Numeric(18,0)
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
   DECLARE @VISIT TINYINT 
   SET @VISIT = 0
   
   IF (@VISITED_FLAG='0')
	BEGIN
		SET @EXPENSE=0
	END
     
   	-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	-- Add By Mukti 11072016(end)	
	
  IF @TRAN_TYPE ='I' OR @TRAN_TYPE ='M'   
   BEGIN  
   
   
     	DECLARE @STATUS AS VARCHAR(15)
		SET @STATUS = 'P'
		IF (@tran_type = 'M')
			SET @STATUS = 'D'
     
		---- ADDED BY RAJPUT ON 08042019 DUE TO REPLACE CONDITION FROM PAGE LEVEL TO SP   
		IF EXISTS(SELECT 1 FROM T0140_TRAVEL_SETTLEMENT_EXPENSE WITH (NOLOCK) WHERE CMP_ID =@CMP_ID AND EMP_ID=@EMP_ID AND TRAVEL_APPROVAL_ID = @TRAVEL_APPROVAL_ID AND ISNULL(TRAVEL_SET_APPLICATION_ID,0) = @TRAVEL_SET_APPLICATION_ID)
			BEGIN
		 
				DELETE FROM T0140_TRAVEL_SETTLEMENT_EXPENSE 
				WHERE CMP_ID =@CMP_ID AND EMP_ID=@EMP_ID AND TRAVEL_APPROVAL_ID = @TRAVEL_APPROVAL_ID AND 
				ISNULL(TRAVEL_SET_APPLICATION_ID,0) =	CASE 
														WHEN	TRAVEL_SET_APPLICATION_ID IS NULL  
																THEN 
																0 
																ELSE 
																@TRAVEL_SET_APPLICATION_ID 
														END 
														
			END
			IF EXISTS(SELECT 1 FROM T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAVEL_SET_APPLICATION_ID = @Travel_Set_Application_Id)
			BEGIN
			
				DELETE 
				FROM	T0140_Travel_Settlement_Mode_Expense
				WHERE	CMP_ID = @CMP_ID AND TRAVEL_SET_APPLICATION_ID = @Travel_Set_Application_Id
			END
			
	   SELECT @TRAVEL_SET_APPLICATION_ID = ISNULL(MAX(TRAVEL_SET_APPLICATION_ID),0) + 1 
				FROM DBO.T0140_TRAVEL_SETTLEMENT_APPLICATION WITH (NOLOCK)  
		IF EXISTS(	SELECT 1 
					FROM T0140_Travel_Settlement_Application WITH (NOLOCK)
					WHERE TRAVEL_APPROVAL_ID = @Travel_Approval_ID and Travel_Set_Application_id=@Travel_Set_Application_Id AND EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [STATUS]='D')
						BEGIN
							
							UPDATE	T0140_TRAVEL_SETTLEMENT_APPLICATION   
							SET		ADVANCE_AMOUNT = @ADVANCE,
									EXPENCE = @EXPENSE,
									CREDIT = @CREDIT_AMOUNT,
									DEBIT = @DEBIT_AMOUNT,
									COMMENT = @COMMENTS,
									DOCUMENT = @FILENAME,
									VISITED_FLAG = @VISITED_FLAG,
									DIRECTENTRY=@DIRECT_ENTRY,
									ODDATES=@ODDATES,
									Tour_Agenda_Actual=@TourAgenda,
									IMP_Business_Appoint_Actual=@BusinessAppt,
									KRA_Tour_Actual=@TourAppt
									,TravelTypeid=@TravelTypeId
							 WHERE	EMP_ID=@EMP_ID AND TRAVEL_APPROVAL_ID = @TRAVEL_APPROVAL_ID  AND	
									TRAVEL_SET_APPLICATION_ID=@TRAVEL_SET_APPLICATION_ID					

						END
		ELSE
          
          BEGIN
				SELECT @TRAVEL_SET_APPLICATION_ID = ISNULL(MAX(TRAVEL_SET_APPLICATION_ID),0) + 1 
				FROM DBO.T0140_TRAVEL_SETTLEMENT_APPLICATION WITH (NOLOCK)  
			          
			    IF EXISTS(select Emp_ID From T0140_Travel_Settlement_Application WITH (NOLOCK) where Emp_ID = @Emp_ID and Travel_Approval_id = @Travel_Approval_ID and Travel_Set_Application_id=@Travel_Set_Application_Id)
					 BEGIN  
							Set @Travel_Set_Application_Id = 0  
						   RAISERROR('Travel settlement Application already Exist',16,2)
						   RETURN   
					 END  
				 ELSE  
					BEGIN
					
					   INSERT INTO T0140_Travel_Settlement_Application  
						  (  
							  Travel_Set_Application_id  
							  ,Travel_Approval_ID  
							  ,cmp_id  
							  ,emp_id  
							  ,Advance_Amount  
							  ,Expence  
							  ,credit  
							  ,Debit  
							  ,Comment  
							  ,Document  
							  ,For_date  
							  ,Visited_Flag  
							  ,Status
							  ,DirectEntry
							  ,ODDates
							  ,Tour_Agenda_Actual
							  ,IMP_Business_Appoint_Actual
							  ,KRA_Tour_Actual
							  ,TravelTypeId
						  )  
						  VALUES        
						  (
								@Travel_Set_Application_Id  
							   ,@Travel_Approval_ID  
							   ,@Cmp_ID  
							   ,@Emp_ID  
							   ,@Advance  
							   ,@Expense  
							   ,@Credit_Amount  
							   ,@Debit_Amount  
							   ,@Comments  
							   ,@filename  
							   ,GETDATE()  
							   ,@visited_Flag  
							   --,'P'
							   ,@STATUS
							   ,@Direct_Entry
							   ,@ODDates
							   ,@TourAgenda
							   ,@BusinessAppt
							   ,@TourAppt
							   ,@TravelTypeId
						   )  
					       
						   -- Add By Mukti 11072016(start)
							exec P9999_Audit_get @table = 'T0140_Travel_Settlement_Application' ,@key_column='Travel_Set_Application_id',@key_Values=@Travel_Set_Application_Id,@String=@String_val output
							set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
						   -- Add By Mukti 11072016(end)
				   END
		
	   END   
 END  
 else if @tran_type ='U'   
    begin  
    
		---- ADDED BY RAJPUT ON 08042019 DUE TO REPLACE CONDITION FROM PAGE LEVEL TO SP   
		IF EXISTS(SELECT 1 FROM T0140_TRAVEL_SETTLEMENT_EXPENSE WITH (NOLOCK) WHERE CMP_ID =@CMP_ID AND EMP_ID=@EMP_ID AND TRAVEL_APPROVAL_ID = @TRAVEL_APPROVAL_ID AND ISNULL(TRAVEL_SET_APPLICATION_ID,0) = @TRAVEL_SET_APPLICATION_ID)
			BEGIN
		 
				DELETE FROM T0140_TRAVEL_SETTLEMENT_EXPENSE 
				WHERE CMP_ID =@CMP_ID AND EMP_ID=@EMP_ID AND TRAVEL_APPROVAL_ID = @TRAVEL_APPROVAL_ID AND 
				ISNULL(TRAVEL_SET_APPLICATION_ID,0) =	CASE 
														WHEN	TRAVEL_SET_APPLICATION_ID IS NULL  
																THEN 
																0 
																ELSE 
																@TRAVEL_SET_APPLICATION_ID 
														END 
														
			END
		IF EXISTS(SELECT 1 FROM T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAVEL_SET_APPLICATION_ID = @Travel_Set_Application_Id)
			BEGIN
			
				DELETE 
				FROM	T0140_Travel_Settlement_Mode_Expense
				WHERE	CMP_ID = @CMP_ID AND TRAVEL_SET_APPLICATION_ID = @Travel_Set_Application_Id
			END
			
		-- Add By Mukti 11072016(start)
		exec P9999_Audit_get @table='T0140_Travel_Settlement_Application' ,@key_column='Travel_Set_Application_id',@key_Values=@Travel_Set_Application_Id,@String=@String_val output
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
		-- Add By Mukti 11072016(end)
			
		 update T0140_Travel_Settlement_Application   
		 set  
		 Advance_Amount = @Advance  
		 ,Expence = @Expense  
		 ,credit = @Credit_Amount  
		 ,Debit = @Debit_Amount  
		 ,Comment = @Comments  
		 ,Document = @filename  
		 ,Visited_Flag =@visited_Flag
		 ,DirectEntry=@Direct_Entry
		 ,ODDates=@ODDates
		 ,[STATUS] = 'P'
		,Tour_Agenda_Actual=@TourAgenda
		,IMP_Business_Appoint_Actual=@BusinessAppt
		,KRA_Tour_Actual=@TourAppt
		,TravelTypeId=@TravelTypeId
		where   
		 emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  
		 and Travel_Set_Application_id=@Travel_Set_Application_Id
		 
		 -- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table = 'T0140_Travel_Settlement_Application' ,@key_column='Travel_Set_Application_id',@key_Values=@Travel_Set_Application_Id,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
	   -- Add By Mukti 11072016(end)
    end  
  
 else if @tran_type ='D'
	 begin 
	-- select 123
		-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table='T0140_Travel_Settlement_Application' ,@key_column='Travel_Set_Application_id',@key_Values=@Travel_Set_Application_Id,@String=@String_val output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
		-- Add By Mukti 11072016(end)
			
 			delete from T0140_Travel_Settlement_Application where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and Travel_Set_Application_id=@Travel_Set_Application_Id
			delete from T0140_Travel_Settlement_Expense where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  
						and ISNULL(Travel_Set_Application_id,0)=case when Travel_Set_Application_id is null then 0 Else @Travel_Set_Application_Id End
			delete from T0140_Travel_Settlement_Group_Emp where Emp_ID=@Emp_ID and Travel_Approval_ID=@Travel_Approval_ID
			delete from T0140_Travel_Vendor_Expense_Request where Emp_ID=@Emp_ID and Travel_Approval_ID=@Travel_Approval_ID
			
			delete from T0140_Travel_Settlement_Mode_Expense where Travel_Set_Application_ID = @Travel_Set_Application_Id --ADDED BY RAJPUT ON 06082019
			
	 end 
	  
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Settlement Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN  
  
  
  

