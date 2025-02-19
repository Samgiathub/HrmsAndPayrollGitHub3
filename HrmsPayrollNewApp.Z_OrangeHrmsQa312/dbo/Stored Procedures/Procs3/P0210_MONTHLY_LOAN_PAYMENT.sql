



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_LOAN_PAYMENT]
	 @Loan_Pay_ID			Numeric output
	,@Loan_Apr_ID			Numeric
	,@Cmp_ID				Numeric
	,@Sal_Tran_ID			Numeric 
	,@Loan_Pay_Amount		Numeric(18,2)
	,@Loan_Pay_Comments		Varchar(250)
	,@Loan_Payment_Date		datetime
	,@Loan_Payment_Type		varchar(20)
	,@Bank_Name				varchar(50)
	,@Loan_Cheque_No		varchar(50)
	,@tran_type				char(1)
	,@User_Id				numeric(18,0) = 0, -- Add By Mukti 07072016
	 @IP_Address				varchar(30)= '' -- Add By Mukti 07072016
	,@Loan_Interest_Amt     Numeric(18,2) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if exists(select 1 from sys.triggers where is_disabled=1) --for sql 2005 added by hasmukh 
--	if not exists(select 1 from sysobjects a join sysobjects b on a.parent_obj=b.id where a.type = 'tr' AND A.STATUS & 2048 = 0) -- for sql 2000
		begin		
			exec sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all'
			--set @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
			--return 
		end
	
	if @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null

	Declare @Pre_Loan_Pay_Amount numeric 
	set @Pre_Loan_Pay_Amount = 0
	-- Add By Mukti 07072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
	-- Add By Mukti 07072016(end)	
		

	if @tran_type ='I' 
	begin
	
			if exists (Select Loan_Pay_ID  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Payment_Date = @Loan_Payment_Date and Cmp_ID = @Cmp_ID and Loan_Apr_ID=@Loan_Apr_ID and @Loan_Interest_Amt = 0) 
				begin
				
					set @Loan_Pay_ID=0
				end
			else
				Begin
					if @Loan_Pay_Amount > 0 
						Begin
							select @Loan_Pay_ID = isnull(max(Loan_Pay_ID),0) +1  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
								
							Insert into T0210_MONTHLY_LOAN_PAYMENT
							(Loan_Pay_ID,Loan_Apr_ID,Cmp_ID,Sal_Tran_ID,Loan_Pay_Amount,Loan_Pay_Comments,Loan_Payment_Date,Loan_Payment_Type,Bank_Name,Loan_Cheque_No)
							Values	(@Loan_Pay_ID,@Loan_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@Loan_Pay_Amount,@Loan_Pay_Comments,@Loan_Payment_Date,@Loan_Payment_Type,@Bank_Name,@Loan_Cheque_No)
						End
					
					if @Loan_Interest_Amt <> 0 and @Sal_Tran_ID is null
						Begin
							--Set @Loan_Payment_Date = Dateadd(dd,1,@Loan_Payment_Date)
							
							Declare @Loan_Pay_Int_ID Numeric(18,0)
							Set @Loan_Pay_Int_ID = 0
							exec P0210_MONTHLY_LOAN_PAYMENT_INSERT @Loan_Pay_ID=@Loan_Pay_Int_ID output,@Loan_Apr_ID=@Loan_Apr_ID,@Cmp_ID=@Cmp_ID,@Sal_Tran_ID=@Sal_Tran_ID,@Loan_Pay_Amount=0,@Loan_Pay_Comments=@Loan_Pay_Comments,@Loan_Payment_Date= @Loan_Payment_Date ,@Loan_Pay_Code=0,@Loan_Payment_Type=@Loan_Payment_Type,@Bank_Name=@Bank_Name,@Loan_Cheque_No=@Loan_Cheque_No,@Interest_Amount =@Loan_Interest_Amt,@Interest_Percent=0,@Interest_Subsidy_Amount=0,@Is_Loan_Interest_Flag=1,@Temp_Loan_Tran_ID = @Loan_Pay_ID
						End
									
				-- Add By Mukti 07072016(start)
					exec P9999_Audit_get @table = 'T0210_MONTHLY_LOAN_PAYMENT' ,@key_column='Loan_Pay_ID',@key_Values=@Loan_Pay_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add By Mukti 07072016(end)		
		end 
	end
	else if @tran_type ='U' 
		begin
			-- Add By Mukti 07072016(start)
				exec P9999_Audit_get @table='T0210_MONTHLY_LOAN_PAYMENT' ,@key_column='Loan_Pay_ID',@key_Values=@Loan_Pay_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 07072016(end)
			
					select @Pre_Loan_Pay_Amount = Loan_Pay_Amount from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							Where Loan_Pay_ID = @Loan_Pay_ID 
		
			--		update T0120_LOAN_APPROVAL
			 --		set Loan_Apr_Pending_Amount = (Loan_Apr_Pending_Amount - @Loan_Pay_Amount) + @Pre_Loan_Pay_Amount
			--		where  Loan_Apr_ID = @Loan_Apr_ID


					Update T0210_MONTHLY_LOAN_PAYMENT 
						set Loan_Pay_Amount = @Loan_Pay_Amount,
						Loan_Pay_Comments = @Loan_Pay_Comments,
						Loan_Payment_Date = @Loan_Payment_Date,
						Loan_Payment_Type = @Loan_Payment_Type,
						Bank_Name = @Bank_Name,
						Loan_Cheque_No = @Loan_Cheque_No
						where Loan_Pay_ID = @Loan_Pay_ID and CMP_ID = CMP_ID
						
				-- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table = 'T0210_MONTHLY_LOAN_PAYMENT' ,@key_column='Loan_Pay_ID',@key_Values=@Loan_Pay_ID,@String=@String output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add By Mukti 05072016(end)		
		end	
	else if @tran_type ='d' 
		Begin
				select @Pre_Loan_Pay_Amount = Loan_Pay_Amount from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
						Where Loan_Pay_ID = @Loan_Pay_ID 
		
			--		update T0120_LOAN_APPROVAL
			 --		set Loan_Apr_Pending_Amount = Loan_Apr_Pending_Amount - @Pre_Loan_Pay_Amount
			--		where  Loan_Apr_ID = @Loan_Apr_ID
			Declare @Sal_Tran_Id_temp numeric
			set @Sal_Tran_Id_temp = 0
			
			select 	@Sal_Tran_Id_temp = isnull(Sal_Tran_ID,0) from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) where Loan_Pay_ID=@Loan_Pay_ID 
			
			if @Sal_Tran_Id_temp > 0
				begin
					
					if not exists(select * from T0200_MONTHLY_SALARY WITH (NOLOCK) where Sal_Tran_ID = @Sal_Tran_Id_temp)
						begin	
						-- Add By Mukti 07072016(start)
							exec P9999_Audit_get @table='T0210_MONTHLY_LOAN_PAYMENT' ,@key_column='Loan_Pay_ID',@key_Values=@Loan_Pay_ID,@String=@String output
							set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
						-- Add By Mukti 07072016(end)				
							delete  from T0210_MONTHLY_LOAN_PAYMENT where Loan_Pay_ID=@Loan_Pay_ID 
							delete  from T0210_MONTHLY_LOAN_PAYMENT where Temp_Loan_Pay_ID=@Loan_Pay_ID
						end
					else
						begin
							set @Loan_Pay_ID=0
						end
				end
			else
				begin
					-- Add By Mukti 07072016(start)
						exec P9999_Audit_get @table='T0210_MONTHLY_LOAN_PAYMENT' ,@key_column='Loan_Pay_ID',@key_Values=@Loan_Pay_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					-- Add By Mukti 07072016(end)
					delete  from T0210_MONTHLY_LOAN_PAYMENT where Loan_Pay_ID=@Loan_Pay_ID 
					delete  from T0210_MONTHLY_LOAN_PAYMENT where Temp_Loan_Pay_ID=@Loan_Pay_ID
				end
		End
		exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Loan Payment',@OldValue,@Loan_Pay_ID,@User_Id,@IP_Address	
RETURN




