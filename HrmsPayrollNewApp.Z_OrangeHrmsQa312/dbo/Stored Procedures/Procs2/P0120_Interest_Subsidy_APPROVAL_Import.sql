



CREATE PROCEDURE [dbo].[P0120_Interest_Subsidy_APPROVAL_Import]
	 @cmp_id						Numeric(18,0)
	,@Emp_Code						Varchar(50)
	,@Loan_Name						Varchar(50)	
	,@Loan_Apr_Amount				Numeric
	,@Loan_Apr_No_of_Installment	Numeric
	,@Loan_Apr_Installment_Amount	Numeric
	,@Loan_apr_Intrest_type			varchar(20)
	,@Loan_Apr_Intrest_Per			numeric(12,2)
	,@Loan_Apr_Date					Datetime
	,@Subsidy_Recover_Perc			numeric(18,2)
	,@GUID							Varchar(2000)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

    Declare @Loan_Apr_ID  numeric(18,0)
    declare @Loan_App_ID  numeric(18,0)
    set @Loan_Apr_ID =0
    set @Loan_App_ID=0

    Declare @Loan_Mode as char(1)
	set @Loan_Mode ='A'
	Declare @Loan_Apr_Intrest_Amount Numeric
	set @Loan_Apr_Intrest_Amount =0
	Declare @Loan_Apr_Deduct_From_Sal numeric
	set @Loan_Apr_Deduct_From_Sal=1
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
	 
	if @Loan_apr_Intrest_type = ''
	 Begin
		Set @Loan_apr_Intrest_type = 'Fix'
	 End 
	 --Set @Cmp_ID=1
	  
		if @tran_type ='I' 
			Begin
				
				IF @Emp_Code IS NULL 
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,'','Employee Code cannot be null','','Eneter valid employee code',GETDATE(),'Loan Interest Subsidy',@GUID)  
					END
				ELSE IF NOT EXISTS(SELECT 1 FROM V0080_Employee_Master WHERE Alpha_Emp_Code=@Emp_Code AND Cmp_ID=@cmp_id)
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Employee code not exist',@Emp_Code,'Enter valid employee code.',GETDATE(),'Loan Interest Subsidy',@GUID)  
					END
					
				IF @Loan_Name IS NULL
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Loan Name is not entered','','Enter valid loan name',GETDATE(),'Loan Interest Subsidy',@GUID)  
					END
				ELSE IF NOT EXISTS(SELECT 1 FROM T0040_LOAN_MASTER WITH (NOLOCK) WHERE Loan_Name=@Loan_Name)
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Loan does not exist with this name',@Loan_Name,'Please Enter Correct Loan Name',GETDATE(),'Loan Interest Subsidy',@GUID)  
					END
				
				if isnull(@Loan_Apr_Amount,0) = 0
					Begin
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Enter Correct Loan Amount',@Loan_Name,'Enter Correct Loan Amount',GETDATE(),'Loan Interest Subsidy',@GUID)  
					End
				
				if isnull(@Loan_Apr_No_of_Installment,0) = 0
					Begin
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Enter Correct Loan Installment Details',@Loan_Name,'Enter Correct Loan Installment Details',GETDATE(),'Loan Interest Subsidy',@GUID)  
					End
				
				if isnull(@Loan_Apr_Installment_Amount,0) = 0
					Begin
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Enter Correct Loan Installment Amount ',@Loan_Name,'Enter Correct Loan Installment Amount',GETDATE(),'Loan Interest Subsidy',@GUID)  
					End
				
				IF @Loan_Apr_Date IS NULL
					BEGIN
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Invalid Loan Approval Date"','','Enter valid loan approval date.',GETDATE(),'Loan Interest Subsidy',@GUID)  
					END
				
				If @Subsidy_Recover_Perc >= @Loan_Apr_Intrest_Per 
					Begin
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@cmp_id,@Emp_Code,'Invalid Subsidy Recovery Percentage',@Loan_Apr_Installment_Amount,'Subsidy Recovery Percentage should be less than Loan Interest Amount.',GETDATE(),'Loan Interest Subsidy',@GUID)  
					End
					
				select @Emp_Id = Emp_ID from T0080_Emp_Master WITH (NOLOCK) where alpha_emp_code = @Emp_Code and cmp_id = @cmp_id			
				
				if not exists(select Loan_id from T0040_Loan_MAster WITH (NOLOCK) where  upper(Loan_name) = upper(@Loan_Name) and cmp_id = @cmp_id)
					begin
						
						exec P0040_LOAN_MASTER @loan_Id output,@cmp_Id,@Loan_Name,9999999,'',0,@tran_type,0,'',1,0,0,1,0,''
						
					end
				else
				begin
					select @loan_Id = loan_id from T0040_Loan_Master WITH (NOLOCK) where loan_name = @loan_name
				end
									
				select @Loan_Apr_ID = Isnull(max(Loan_Apr_ID),0) + 1 	From T0120_LOAN_APPROVAL WITH (NOLOCK)
			

			if exists (Select Loan_app_ID from T0100_loan_Application WITH (NOLOCK) where Loan_ID=@Loan_ID and Loan_App_Date =@Loan_Apr_Date and Emp_ID=@Emp_ID)
			  Begin 
				  Return
			  End

			  set @Loan_App_ID =Null
			  
					
				
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
					,Subsidy_Recover_Perc)

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
					,@Subsidy_Recover_Perc)
							
				exec P0120_Installment_Amount_Details 0,@cmp_ID,@Emp_ID,@Loan_ID,@Loan_Apr_ID,@Loan_Apr_Date,@Loan_Apr_Installment_Amount					
				exec P0120_Interest_Yearly_Details 0,@Cmp_ID,@Emp_ID,@Loan_ID,@Loan_Apr_ID,@Loan_Apr_Date,@Loan_Apr_Intrest_Per	
									
			end 
	else if @tran_type ='U' 
				begin
				select @Emp_Id = Emp_ID from T0080_Emp_Master WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and cmp_id = @cmp_id
				alter table T0120_Loan_Approval DISABLE trigger Tri_T0120_LOAN_APPROVAL
				UPDATE    T0100_LOAN_APPLICATION
				SET         Loan_status = @Loan_Mode
				WHERE     (Loan_App_ID = @Loan_App_ID and Cmp_ID=@Cmp_ID)
								
				
				DELETE FROM  T0120_Installment_Amount_Details where Loan_apr_ID = @Loan_Apr_ID
				DELETE FROM  T0120_Interest_Yearly_Details where Loan_apr_ID = @Loan_Apr_ID
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
					,Subsidy_Recover_Perc)

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
					,@Subsidy_Recover_Perc)
					
					exec P0120_Installment_Amount_Details 0,@cmp_ID,@Emp_ID,@Loan_ID,@Loan_Apr_ID,@Loan_Apr_Date,@Loan_Apr_Installment_Amount					
					exec P0120_Interest_Yearly_Details 0,@Cmp_ID,@Emp_ID,@Loan_ID,@Loan_Apr_ID,@Loan_Apr_Date,@Loan_Apr_Intrest_Per	
				
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




