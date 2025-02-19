
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_CLAIM_PAYMENT]
	 @Claim_Pay_ID			Numeric output
	,@Claim_Apr_ID			Numeric
	,@Cmp_ID				Numeric
	,@Sal_Tran_ID			Numeric 
	,@Claim_Pay_Amount		Numeric(18,3)
	,@Claim_Pay_Comments		Varchar(250)
	,@Claim_Payment_Date		datetime
	,@Claim_Payment_Type		varchar(20)
	,@Bank_Name				varchar(50)
	,@Claim_Cheque_No		varchar(50)
	,@Voucher_No			varchar(50)
	,@Voucher_Date			datetime
	,@tran_type				char(1)
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
    ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null
	if @Claim_Apr_ID=0
	set @Claim_Apr_ID=null	
	if @Voucher_Date=''
	set @Voucher_Date=null

   Declare @Pre_Claim_Pay_Amount numeric 
	set @Pre_Claim_Pay_Amount = 0
    
    -- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 08072016(end)

	if @tran_type ='I' 
	begin
		
			if exists (Select Claim_Pay_ID  from T0210_MONTHLY_CLAIM_PAYMENT WITH (NOLOCK) Where Claim_Payment_Date = @Claim_Payment_Date and Cmp_ID = @Cmp_ID and Claim_Apr_ID=@Claim_Apr_ID) 
				begin
					set @Claim_Pay_ID=0
					
				end
			else
				begin
					select @Claim_Pay_ID = isnull(max(Claim_Pay_ID),0) +1  from T0210_MONTHLY_Claim_PAYMENT WITH (NOLOCK)
					
				
					insert into T0210_MONTHLY_CLAIM_PAYMENT
					(Claim_Pay_ID,Claim_Apr_ID,Cmp_ID,Sal_Tran_ID,Claim_Pay_Amount,Claim_Pay_Comments,Claim_Payment_Date,Claim_Payment_Type,Bank_Name,Claim_Cheque_No,Voucher_No,Voucher_Date)
			 values	(@Claim_Pay_ID,@Claim_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@Claim_Pay_Amount,@Claim_Pay_Comments,@Claim_Payment_Date,@Claim_Payment_Type,@Bank_Name,@Claim_Cheque_No,@Voucher_No,@Voucher_Date)
				
			 -- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0210_MONTHLY_CLAIM_PAYMENT' ,@key_column='Claim_Pay_ID',@key_Values=@Claim_Pay_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			 -- Add By Mukti 05072016(end)	
		end 
	end
	else if @tran_type ='U' 
		begin
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table='T0210_MONTHLY_CLAIM_PAYMENT' ,@key_column='Claim_Pay_ID',@key_Values=@Claim_Pay_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)

					Update T0210_MONTHLY_CLAIM_PAYMENT 
						set Claim_Pay_Amount = @Claim_Pay_Amount,
						Claim_Apr_ID=@Claim_Apr_ID,
						Claim_Pay_Comments = @Claim_Pay_Comments,
						Claim_Payment_Date = @Claim_Payment_Date,
						Claim_Payment_Type = @Claim_Payment_Type,
						Bank_Name = @Bank_Name,
						Claim_Cheque_No = @Claim_Cheque_No,
						Voucher_No=@Voucher_No,
						Voucher_Date=@Voucher_Date						
					where Claim_Pay_ID = @Claim_Pay_ID and CMP_ID = @Cmp_ID
					
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0210_MONTHLY_CLAIM_PAYMENT' ,@key_column='Claim_Pay_ID',@key_Values=@Claim_Pay_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)    
		end	
	else if @tran_type ='d' 
		Begin
				select @Pre_Claim_Pay_Amount = Claim_Pay_Amount from T0210_MONTHLY_Claim_PAYMENT WITH (NOLOCK)
						Where Claim_Pay_ID = @Claim_Pay_ID 
			-- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table='T0210_MONTHLY_CLAIM_PAYMENT' ,@key_column='Claim_Pay_ID',@key_Values=@Claim_Pay_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)
				
			delete from T0230_MONTHLY_CLAIM_PAYMENT_DETAIL where Claim_Pay_Id=@Claim_Pay_ID
			delete  from T0210_MONTHLY_Claim_PAYMENT where Claim_Pay_ID=@Claim_Pay_ID 
			
		End
			exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Payment',@OldValue,@Claim_Pay_ID,@User_Id,@IP_Address
RETURN




