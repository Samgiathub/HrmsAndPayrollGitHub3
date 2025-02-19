
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_CLAIM_PAYMENT_INSERT]
	 @CLAIM_Pay_ID			Numeric output
	,@CLAIM_Apr_ID			Numeric
	,@Cmp_ID				Numeric
	,@Sal_Tran_ID			Numeric 
	,@CLAIM_Pay_Amount		Numeric(18,3)
	,@CLAIM_Pay_Comments		Varchar(250)
	,@CLAIM_Payment_Date		datetime
	,@CLAIM_Pay_Code			varchar(20)
	,@CLAIM_Payment_Type		varchar(20)
	,@Bank_Name				varchar(50)
	,@CLAIM_Cheque_No		varchar(50)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
	Declare @Emp_Code numeric 
	Declare @Emp_ID numeric 
	declare @str_Emp_Code varchar(20)
	Declare @Fix_Code varchar(4)
 
 

	if @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null

				
	if isnull(@Sal_Tran_ID ,0)= 0
		set @Fix_code = 'CMR'
	else
		set @Fix_code = 'CMS'

	if @CLAIM_Pay_ID = 0 
		begin
				
				select @CLAIM_Pay_ID = isnull(max(CLAIM_Pay_ID),0) +1  from T0210_MONTHLY_CLAIM_PAYMENT WITH (NOLOCK)

				/*select @Emp_Code = EMP_CODE ,@Emp_ID= Emp_ID From T0080_EMP_MASTER WHERE 
						EMP_ID  = (Select Emp_ID From T0120_CLAIM_Approval Where CLAIM_Apr_ID= @CLAIM_apr_ID)
			
				
				SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code) 
			
				select @CLAIM_Pay_Code =   cast(isnull(max(substring(CLAIM_Pay_Code,10,len(CLAIM_Pay_Code))),0) + 1 as varchar)  
						from T0210_MONTHLY_CLAIM_PAYMENT 
						where CLAIM_Apr_ID  in (select CLAIM_Apr_ID From T0120_CLAIM_Approval Where Emp_ID = @Emp_ID)
				
				If charindex(':',@CLAIM_Pay_Code) > 0 
					Select @CLAIM_Pay_Code = right(@CLAIM_Pay_Code,len(@CLAIM_Pay_Code) - charindex(':',@CLAIM_Pay_Code))
				
				if @CLAIM_Pay_Code is not null
					begin
						while len(@CLAIM_Pay_Code) <> 4
							begin
								set @CLAIM_Pay_Code = '0' + @CLAIM_Pay_Code
							end
						set @CLAIM_Pay_Code = @Fix_code + @str_Emp_Code +':'+ @CLAIM_Pay_Code  
					end
				else
					SET @CLAIM_Pay_Code = @Fix_code + @str_Emp_Code + ':' + '0001' 					
		
					*/
					set @CLAIM_Pay_Code = cast(@CLAIM_Pay_ID as varchar(20))
					
					insert into T0210_MONTHLY_CLAIM_PAYMENT
					(CLAIM_Pay_ID,CLAIM_Apr_ID,Cmp_ID,Temp_Sal_Tran_ID,CLAIM_Pay_Amount,CLAIM_Pay_Comments,CLAIM_Payment_Date,CLAIM_Payment_Type,Bank_Name,CLAIM_Cheque_No,CLAIM_Pay_Code)
					 values	(@CLAIM_Pay_ID,@CLAIM_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@CLAIM_Pay_Amount,@CLAIM_Pay_Comments,@CLAIM_Payment_Date,@CLAIM_Payment_Type,@Bank_Name,@CLAIM_Cheque_No,@CLAIM_Pay_Code)
					
					
		end 
	else 
		begin
 	select @CLAIM_Pay_Amount
					Update T0210_MONTHLY_CLAIM_PAYMENT 
						set CLAIM_Pay_Amount = @CLAIM_Pay_Amount,
						CLAIM_Pay_Comments = @CLAIM_Pay_Comments,
						CLAIM_Payment_Date = @CLAIM_Payment_Date,
						CLAIM_Payment_Type = @CLAIM_Payment_Type,
						Bank_Name = @Bank_Name,
						CLAIM_Cheque_No = @CLAIM_Cheque_No,
						Temp_Sal_Tran_ID = @Sal_Tran_ID
					where CLAIM_Pay_ID = @CLAIM_Pay_ID and CMP_ID = CMP_ID
		end	
	RETURN




