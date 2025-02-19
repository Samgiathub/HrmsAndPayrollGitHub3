

CREATE PROCEDURE [dbo].[P0120_LOAN_APPROVAL_NIIT]
	@cmp_id Numeric(18,0)
	,@Emp_Code				Varchar(50)
	,@Loan_Name				Varchar(50)	
	,@Loan_Apr_Amount				Numeric
	,@Loan_Apr_No_of_Installment	Numeric
	,@Loan_Apr_Installment_Amount	Numeric
	,@Loan_apr_Intrest_type varchar(20)
	,@Loan_Apr_Intrest_Per numeric(12,2)
	,@Loan_Apr_Date			Datetime				
	,@Installment_Start_Date			Datetime	--Added by Nimesh 2015-06-09 (For Installment Start Date)
	,@Paid_Amount Numeric(18,2) = 0 -- Added by nilesh patel on 29072015
	,@No_of_Installment_Paid Numeric(18,0) = 0 -- Added by nilesh patel on 29072015
	,@Calculated_Interest_Amount Numeric(18,2) = 0 -- Added by nilesh patel on 29072015
	,@No_of_Interest_Installment Numeric(18,0) = 0 -- Added by nilesh patel on 06082015
	,@Log_Status Varchar(10)	Output			--Added by Nimesh 2015-06-09 (To return value if log is inserted).
	,@GUID Varchar(2000) = ''  --Added By nilesh patel on 14062016
	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

    Declare @Loan_Apr_ID numeric(18,0)
    declare @Loan_App_ID  numeric(18,0)
    set @Loan_Apr_ID =0
    set @Loan_App_ID=0
    SET @Log_Status = '0' --Added by Nimesh 2015-06-09 (To display error log in Import data)    

    Declare @Loan_Mode as char(1)
	set @Loan_Mode ='A'
	--Declare @Loan_Apr_Intrest_Per Numeric(12,2)
	--Set @Loan_Apr_Intrest_Per =0
	Declare @Loan_Apr_Intrest_Amount Numeric
	set @Loan_Apr_Intrest_Amount =0
	Declare @Loan_Apr_Deduct_From_Sal numeric
	set @Loan_Apr_Deduct_From_Sal=1
	--Declare @Loan_apr_Intrest_type numeric 
 --   set @Loan_apr_Intrest_type =0
	Declare @Loan_Apr_Pending_Amount  Numeric(18,0)
	set @Loan_Apr_Pending_Amount =0
	Declare @Loan_apr_By  varchar(100)
	set @Loan_apr_By=''
	declare @Loan_Apr_Payment_Date as  Datetime
	set @Loan_Apr_Payment_Date =@Loan_Apr_Date
	Declare @Loan_Apr_Payment_Type as Varchar(20)
	set @Loan_Apr_Payment_Type ='Cheque'
	Declare @Bank_ID as Numeric
	set @Bank_ID =null
	Declare @Loan_Apr_Cheque_No  Varchar(10)
	set @Loan_Apr_Cheque_No =0
	declare @Loan_Number varchar(50)
	set @Loan_Number =0
	Declare @Deduction_Type varchar(20)
	set @Deduction_Type='Monthly'
	Declare @tran_type varchar(1)
	set @tran_type ='I'
	
	Declare @Loan_Id as numeric(18,0)

	set @loan_Id = 0
	Declare @Emp_Id as numeric(18,0)
	 
	 --Set @Cmp_ID=1
	 if @Loan_apr_Intrest_type = ''
	 Begin
		Set @Loan_apr_Intrest_type = 'Fix'
	 End 
	 
	 if (@Tran_type = 'I' or @Tran_type='U')
	 BEGIN
		--Added by Nimesh 2015-09-06 (To display Error log in Import Data)				
		DECLARE @RowNo int,
				@TempRowNo int;
		
		SELECT @RowNo = Max(T.Row_No) + 1 FROM T0080_Import_Log T WITH (NOLOCK) WHERE Cmp_Id=@cmp_id
		IF (@RowNo IS NULL)
			SET @RowNo = 1;
			
		SET @TempRowNo = @RowNo;
		
		
		IF @Emp_Code IS NULL 
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,'','Employee Code cannot be null','','Eneter valid employee code',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		ELSE IF NOT EXISTS(SELECT 1 FROM V0080_Employee_Master WHERE Alpha_Emp_Code=@Emp_Code AND Cmp_ID=@cmp_id)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Employee code not exist',@Emp_Code,'Enter valid employee code.',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		
		IF @Loan_Name IS NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Loan Name is not entered','','Enter valid loan name',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		ELSE IF NOT EXISTS(SELECT 1 FROM T0040_LOAN_MASTER WITH (NOLOCK) WHERE Loan_Name=@Loan_Name)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Loan does not exist with this name',@Loan_Name,'Please Enter Correct Loan Name',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		if isnull(@Loan_Apr_Amount,0) = 0
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Enter Correct Loan Amount',@Loan_Name,'Enter Correct Loan Amount',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		End
		if isnull(@Loan_Apr_No_of_Installment,0) = 0
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Enter Correct Loan Installment Details',@Loan_Name,'Enter Correct Loan Installment Details',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		End
		if isnull(@Loan_Apr_Installment_Amount,0) = 0
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Enter Correct Loan Installment Amount ',@Loan_Name,'Enter Correct Loan Installment Amount',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		End
		IF (@Loan_Apr_Amount < @Loan_Apr_Installment_Amount)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Invalid Installment Amount',@Loan_Apr_Installment_Amount,'Installment amount cannot be greater than loan amount.',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		IF (ISNULL(@Loan_Apr_No_of_Installment,0) = 0)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Invalid value "No of Installment"',@Loan_Apr_No_of_Installment,'Value for No of installment field must be supplied.',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		
		IF @Loan_Apr_Date IS NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Invalid Loan Approval Date"','','Enter valid loan approval date.',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		IF @Installment_Start_Date IS NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Invalid Installment Start Date"','','Enter valid loan installment start date.',GETDATE(),'LOAN APPROVAL',@GUID)  
			SET @RowNo = @RowNo + 1;
		END
		
		IF (@RowNo <> @TempRowNo)
		BEGIN
			SET @Log_Status = '1';
			RETURN 0;
		END
	 END
	
		if @tran_type ='I' 
			Begin
				
				select @Emp_Id = Emp_ID from T0080_Emp_Master WITH (NOLOCK) where alpha_emp_code = @Emp_Code and cmp_id = @cmp_id			
				
				if not exists(select Loan_id from T0040_Loan_MAster WITH (NOLOCK) where  upper(Loan_name) = upper(@Loan_Name) and cmp_id = @cmp_id)
					begin
					
					exec P0040_LOAN_MASTER @loan_Id output,@cmp_Id,@Loan_Name,9999999,'',0,@tran_type
				end
				else
				begin
					select @loan_Id = loan_id from T0040_Loan_Master WITH (NOLOCK) where loan_name = @loan_name and Cmp_id=@Cmp_Id
				end
									
				select @Loan_Apr_ID = Isnull(max(Loan_Apr_ID),0) + 1 	From T0120_LOAN_APPROVAL WITH (NOLOCK)
				--End 
				
				if @Paid_Amount <> 0 --Added by nilesh patel on 30072015
				Begin
					Set @Loan_Apr_Amount = @Loan_Apr_Amount - @Paid_Amount
				End
				
				if @No_of_Installment_Paid <> 0 
				Begin
					if @No_of_Installment_Paid > @Loan_Apr_No_of_Installment
						Set @Loan_Apr_No_of_Installment = 0
					Else
						Set @Loan_Apr_No_of_Installment = @Loan_Apr_No_of_Installment - @No_of_Installment_Paid
				End

			if exists (Select Loan_app_ID from T0100_loan_Application WITH (NOLOCK) where Loan_ID=@Loan_ID and Loan_App_Date =@Loan_Apr_Date and Emp_ID=@Emp_ID)
			  Begin 
				  Return
			  End
			  --ALTER TRIGGER Tri_T0120_LOAN_APPROVAL DISABLE
			  --alter table T0120_Loan_Approval DISABLE trigger Tri_T0120_LOAN_APPROVAL	
			  --DISABLE TRIGGER Tri_T0120_LOAN_APPROVAL ON hcl-7;

			-- Modified by Mitesh

			  set @Loan_App_ID =Null
			  --exec P0100_LOAN_APPLICATION @Loan_App_ID output,@Cmp_ID,@Emp_ID,@Loan_Apr_Date,@Loan_Apr_Code,@Loan_ID,@Loan_Apr_Amount,@Loan_Apr_Installment_Amount,@Loan_Apr_Pending_Amount,'','A','','','I'

--New Condition for Restricting Repeated Loan Entry , Added By Ramiz on 08/09/2016
		If EXISTS (Select 1 from T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Loan_ID = @Loan_Id and Emp_ID = @Emp_Id and Loan_Apr_Amount = @Loan_Apr_Amount and Loan_Apr_Date = @Loan_Apr_Date and Installment_Start_Date =  @Installment_Start_Date )
			BEGIN 
				
				INSERT INTO dbo.T0080_Import_Log VALUES (@RowNo,@cmp_id,@Emp_Code,'Loan with Same Details Already Exists',@Loan_Name,'Loan with Same Details Already Exists',@Loan_Apr_Date,'LOAN APPROVAL',@GUID)  
				SET @RowNo = @RowNo + 1;
				SET @Log_Status = '1';
				RETURN 0;
			END
--New Condition for Restricting Repeated Loan Entry Ends			
				
				INSERT INTO T0120_LOAN_APPROVAL
					
					(Loan_Apr_ID
					,Cmp_ID
					,Loan_App_ID
					,Emp_ID
					,Loan_Apr_Date
					,Loan_Apr_Code
					,Loan_ID
					,Loan_Apr_Amount
					,Loan_Apr_No_of_Installment
					,Loan_Apr_Installment_Amount
					,Loan_Apr_Intrest_Type
					,Loan_Apr_Intrest_Per
					,Loan_Apr_Intrest_Amount
					,Loan_Apr_Deduct_From_Sal
					,Loan_Apr_Pending_Amount
					,Loan_apr_By
					,Loan_Apr_Payment_Date
					,Loan_Apr_Payment_Type
					,Bank_ID
					,Loan_Apr_Cheque_No
					,Loan_Apr_Status
					,Loan_Number
					,Deduction_Type
					,Installment_Start_Date
					,Paid_Amount
					,No_of_Installment_Paid
					,Calculated_Interest_Amount
					,No_of_Inst_Loan_Amt) --Added by Nimesh 2015-09-06 

					VALUES   
					(@Loan_Apr_ID
					,@Cmp_ID
					,@Loan_App_ID
					,@Emp_ID
					,@Loan_Apr_Date
					,@Loan_Apr_ID
					,@Loan_ID
					,@Loan_Apr_Amount
					,@Loan_Apr_No_of_Installment
					,@Loan_Apr_Installment_Amount
					,@Loan_Apr_Intrest_Type
					,@Loan_Apr_Intrest_Per
					,@Loan_Apr_Intrest_Amount
					,@Loan_Apr_Deduct_From_Sal
					,@Loan_Apr_Amount
					,@Loan_apr_By
					,@Loan_Apr_Payment_Date
					,@Loan_Apr_Payment_Type
					,@Bank_ID
					,@Loan_Apr_Cheque_No
					,@Loan_Mode
					,@Loan_Number
					,@Deduction_Type
					,@Installment_Start_Date
					,@Paid_Amount
					,@No_of_Installment_Paid
					,@Calculated_Interest_Amount
					,@No_of_Interest_Installment) --Added by Nimesh 2015-09-06 
							
					--alter table T0120_Loan_Approval Enable trigger Tri_T0120_LOAN_APPROVAL					
					
									
			end 
	else if @tran_type ='U' 
				begin
				select @Emp_Id = Emp_ID from T0080_Emp_Master WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and cmp_id = @cmp_id
				alter table T0120_Loan_Approval DISABLE trigger Tri_T0120_LOAN_APPROVAL
				UPDATE    T0100_LOAN_APPLICATION
				SET         Loan_status = @Loan_Mode
				WHERE     (Loan_App_ID = @Loan_App_ID and Cmp_ID=@Cmp_ID)
								
				
				DELETE FROM T0120_LOAN_APPROVAL WHERE Loan_apr_ID = @Loan_Apr_ID

				INSERT INTO T0120_LOAN_APPROVAL
					(Loan_Apr_ID
					,Cmp_ID
					,Loan_App_ID
					,Emp_ID
					,Loan_Apr_Date
					,Loan_Apr_Code
					,Loan_ID
					,Loan_Apr_Amount
					,Loan_Apr_No_of_Installment
					,Loan_Apr_Installment_Amount
					,Loan_Apr_Intrest_Type
					,Loan_Apr_Intrest_Per
					,Loan_Apr_Intrest_Amount
					,Loan_Apr_Deduct_From_Sal
					,Loan_Apr_Pending_Amount
					,Loan_apr_By
					,Loan_Apr_Payment_Date
					,Loan_Apr_Payment_Type
					,Bank_ID
					,Loan_Apr_Cheque_No
					,Loan_Apr_Status
					,Loan_Number
					,Deduction_Type
					,Installment_Start_Date
					,Paid_Amount
					,No_of_Installment_Paid
					,Calculated_Interest_Amount
					,No_of_Inst_Loan_Amt) --Added by Nimesh 2015-09-06 

					VALUES   
					(@Loan_Apr_ID
					,@Cmp_ID
					,@Loan_App_ID
					,@Emp_ID
					,@Loan_Apr_Date
					,0
					,@Loan_ID
					,@Loan_Apr_Amount
					,@Loan_Apr_No_of_Installment
					,@Loan_Apr_Installment_Amount
					,@Loan_Apr_Intrest_Type
					,@Loan_Apr_Intrest_Per
					,@Loan_Apr_Intrest_Amount
					,@Loan_Apr_Deduct_From_Sal
					,@Loan_Apr_Pending_Amount
					,@Loan_apr_By
					,@Loan_Apr_Payment_Date
					,@Loan_Apr_Payment_Type
					,@Bank_ID
					,@Loan_Apr_Cheque_No
					,@Loan_Mode
					,@Loan_Number
					,@Deduction_Type
					,@Installment_Start_Date
					,@Paid_Amount
					,@No_of_Installment_Paid
					,@Calculated_Interest_Amount
					,@No_of_Interest_Installment) --Added by Nimesh 2015-09-06 

				
			alter table T0120_Loan_Approval Enable trigger Tri_T0120_LOAN_APPROVAL
				end
				
	else if @tran_type ='D'
		begin
	
			DELETE FROM T0120_LOAN_APPROVAL where Loan_Apr_ID = @Loan_Apr_ID
	
			UPDATE    T0100_LOAN_APPLICATION
				SET         Loan_status = 'N'
				WHERE     (Loan_App_ID = @Loan_App_ID and Cmp_ID=@Cmp_ID)
			
		end	
	RETURN




