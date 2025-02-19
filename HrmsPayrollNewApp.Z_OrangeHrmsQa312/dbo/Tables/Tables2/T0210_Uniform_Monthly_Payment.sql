CREATE TABLE [dbo].[T0210_Uniform_Monthly_Payment] (
    [Uni_Pay_ID]     NUMERIC (18)    NOT NULL,
    [Uni_Apr_Id]     NUMERIC (18)    NULL,
    [Emp_ID]         NUMERIC (18)    NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Sal_Tran_ID]    NUMERIC (18)    NULL,
    [Payment_Amount] NUMERIC (18, 2) NULL,
    [Payment_Date]   DATETIME        NULL,
    [Uni_Flag]       BIT             NULL,
    PRIMARY KEY CLUSTERED ([Uni_Pay_ID] ASC)
);


GO
-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 06/05/2017
-- Description:	Uniform Payment Transcation
-- =============================================
CREATE TRIGGER  [dbo].[Tri_T0210_Uniform_Monthly_Payment]
   ON  [dbo].[T0210_Uniform_Monthly_Payment]
   FOR Insert,Delete
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Uni_Tran_ID	numeric
	declare @Uni_Id		numeric
	declare @Uni_Return	numeric(22,2)	
	declare @Uni_Closing	numeric(22,2)
	Declare @Uni_Apr_ID	numeric
	Declare @Uni_Closing_Balance	numeric
	Declare @Uni_Flag Numeric(1,0)
	Declare @Uni_Amount Numeric(18,2)
	Declare @Uni_Pieces Numeric(18,0)
	Declare @Uni_Stiching_Price Numeric(18,2)
	Declare @Uni_Deduct_Install Numeric(18,0)
	Declare @Uni_Deduct_Install_Amt Numeric(18,2)
	Declare @Uni_Fabric_Amt Numeric(18,2)

	Set @Uni_Return = 0
	Set @Uni_Closing = 0
	Set @Uni_Closing_Balance = 0
	Set @Uni_Amount = 0
	Set @Uni_Pieces =0
	Set @Uni_Stiching_Price =0
	Set @Uni_Deduct_Install=0
	Set @Uni_Deduct_Install_Amt=0
	Set @Uni_Fabric_Amt=0
	

	select @Uni_Tran_ID = Isnull(Max(Uni_Tran_ID),0)  +1 From T0140_Uniform_Payment_Transcation
	
	if update(Uni_Apr_ID)
		Begin
			Select @cmp_ID = ins.cmp_ID,
				 @Uni_Return = ins.Payment_Amount,
				 @for_Date = ins.Payment_Date,
				 @Emp_ID = ins.Emp_Id, 
				 @Uni_Apr_ID = ins.Uni_Apr_Id,
				 @Uni_Id = UEI.Uni_ID,
				 @Uni_Flag = ins.Uni_Flag,
				 @Uni_Amount = UEI.Uni_Amount,
				 @Uni_Pieces=UEI.Uni_Pieces,
				 @Uni_Stiching_Price=ISNULL(UEI.Uni_Stitching_Price,0),
				 @Uni_Deduct_Install=UEI.Uni_deduct_Installment,
				 @Uni_Deduct_Install_Amt=UEI.Uni_deduct_Amount
			 From inserted ins inner JOIN T0100_Uniform_Emp_Issue UEI
			 ON ins.Uni_Apr_Id = UEI.Uni_Apr_Id
			 
			 
			 Declare @Uni_Stiching_Amount Numeric(18,2)
			 Set @Uni_Stiching_Amount=0

			 IF @Uni_Stiching_Price <> 0
			 Begin
				 SET @Uni_Stiching_Amount=round((@Uni_Stiching_Price*@Uni_Pieces)/@Uni_Deduct_Install,0)
				 SET @Uni_Fabric_Amt=round((((@Uni_Deduct_Install_Amt*@Uni_Deduct_Install)-(@Uni_Stiching_Price*@Uni_Pieces))/@Uni_Deduct_Install),0)
			 End
			 Else
			 Begin
				 SET @Uni_Fabric_Amt=@Uni_Deduct_Install_Amt
			 End

			 if @Uni_Flag = 0
				BEGIN
					Update T0100_Uniform_Emp_Issue
					Set Deduct_Pending_Amount = Deduct_Pending_Amount - @Uni_Return
					Where Uni_Apr_Id = @Uni_Apr_ID
				End
			 
			 if Exists(SELECT 1 From T0140_Uniform_Payment_Transcation where for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Apr_Id = @Uni_Apr_ID)
				Begin
					
				--SET @NEW_REQ_APR_ID=(SELECT NEW_REQ_APR_ID FROM T0100_UNIFORM_EMP_ISSUE WHERE UNI_APR_ID=@UNI_APR_ID AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID)
				
					update T0140_Uniform_Payment_Transcation 
					set Uni_Debit = Uni_Debit + @Uni_Return
					   ,Uni_Balance = Uni_Balance - @Uni_Return,Fabric_Amount=@Uni_Fabric_Amt,Stitching_Amount=@Uni_Stiching_Amount
					where for_date = @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id and Uni_Flag = @Uni_Flag  
						and Uni_Apr_Id = @Uni_Apr_ID
					
					update T0140_Uniform_Payment_Transcation 
					set Uni_Opening = Uni_Opening - @Uni_Return 
					   ,Uni_Balance = Uni_Balance - @Uni_Return,
					   Fabric_Amount=0,Stitching_Amount=0
					where for_date > @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id and Uni_Flag = @Uni_Flag 
						and Uni_Apr_Id = @Uni_Apr_ID
						
					select @Uni_Closing_Balance = isnull(Uni_Balance,0) from T0140_Uniform_Payment_Transcation 
					where for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Flag = 0
					and Uni_Apr_Id = @Uni_Apr_ID
					
	
					
					--if @Uni_Flag = 1
					--	Begin
							IF @Uni_Closing_Balance = 0 
								Begin
									if not Exists(select 1 from T0140_Uniform_Payment_Transcation where for_date < @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Flag = 1 AND Uni_Apr_Id = @Uni_Apr_ID)
										BEGIN
										
											Select @Uni_Amount = Isnull(SUM(Uni_Amount),0) FROM T0100_Uniform_Emp_Issue where Uni_Apr_Id = @Uni_Apr_ID and Cmp_ID = @Cmp_ID
								

											insert T0140_Uniform_Payment_Transcation
											(Uni_Tran_ID,Uni_Apr_Id,Cmp_ID,Uni_ID,Emp_ID,For_Date,Uni_Opening,Uni_Credit,Uni_Debit,Uni_Balance,Uni_Flag,Fabric_Amount,Stitching_Amount)
											values(@Uni_Tran_ID,@Uni_Apr_Id,@Cmp_ID,@Uni_Id,@Emp_ID,@For_Date,@Uni_Amount,0,0,@Uni_Amount,1,@Uni_Fabric_Amt,@Uni_Stiching_Amount)
										End
									Else
										Begin
											update T0100_Uniform_Emp_Issue
											set Refund_Pending_Amount  = Refund_Pending_Amount - @Uni_Return
											where  Uni_Apr_Id = @Uni_Apr_ID 
												
											update T0140_Uniform_Payment_Transcation 
											set Uni_Debit = Uni_Debit + @Uni_Return 
												,Uni_Balance = Uni_Balance - @Uni_Return
											where for_date = @For_Date and Cmp_ID = @Cmp_ID
												and emp_Id = @emp_Id and Uni_Apr_Id = @Uni_Apr_ID and Uni_ID = 1
											
											update T0140_Uniform_Payment_Transcation 
												set Uni_Opening = Uni_Opening - @Uni_Return
												   ,Uni_Balance = Uni_Balance - @Uni_Return
											where for_date > @For_Date and Cmp_ID = @Cmp_ID
												and emp_Id = @emp_Id and Uni_Apr_Id = @Uni_Apr_ID and Uni_ID = 1
										End
								End
					--	End
				END
			Else
				Begin
					select @Uni_Closing = isnull(Uni_Balance,0) from T0140_Uniform_Payment_Transcation
	    			where for_date = (select max(for_date) from T0140_Uniform_Payment_Transcation 
	    								where for_date < @For_date
	    							and cmp_ID = @cmp_ID and emp_id = @emp_Id AND Uni_Apr_Id = @Uni_Apr_ID ) 
	    							and cmp_ID = @cmp_ID and emp_id = @emp_Id AND Uni_Apr_Id = @Uni_Apr_ID
	    			
	    			if @Uni_Closing is null 
						set  @Uni_Closing = 0
						
					select @Uni_Closing_Balance = isnull(Uni_Balance,0) from T0140_Uniform_Payment_Transcation 
					where for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Flag = 0
					and Uni_Apr_Id = @Uni_Apr_ID
					
					IF isnull(@Uni_Closing_Balance,0) = 0
						BEGIN
							IF @Uni_Flag = 1
								Begin
								print 'k'
					print @Uni_Apr_ID
									Update T0100_Uniform_Emp_Issue
									Set Refund_Pending_Amount = Refund_Pending_Amount - @Uni_Return
									Where Uni_Apr_Id = @Uni_Apr_ID
									
									insert T0140_Uniform_Payment_Transcation
									(Uni_Tran_ID,Uni_Apr_Id,Cmp_ID,Uni_ID,Emp_ID,For_Date,Uni_Opening,Uni_Credit,Uni_Debit,Uni_Balance,Uni_Flag)
									 values(@Uni_Tran_ID,@Uni_Apr_Id,@Cmp_ID,@Uni_Id,@Emp_ID,@For_Date,@Uni_Closing,0,@Uni_Return,(@Uni_Closing - @Uni_Return),1)
															
									update T0140_Uniform_Payment_Transcation 
										set Uni_Opening = Uni_Opening - @Uni_Return
										,Uni_Balance = Uni_Balance - @Uni_Return
									where for_date > @For_Date and cmp_ID = @cmp_ID
										  and emp_Id = @emp_Id and Uni_Apr_Id = @Uni_Apr_ID and Uni_Flag = 1
								End
							Else
								Begin				
								
									insert T0140_Uniform_Payment_Transcation
									(Uni_Tran_ID,Uni_Apr_Id,Cmp_ID,Uni_ID,Emp_ID,For_Date,Uni_Opening,Uni_Credit,Uni_Debit,Uni_Balance,Uni_Flag,Fabric_Amount)
									values(@Uni_Tran_ID,@Uni_Apr_Id,@Cmp_ID,@Uni_Id,@Emp_ID,@For_Date,@Uni_Closing,0,@Uni_Return,(@Uni_Closing - @Uni_Return),0,@Uni_Fabric_Amt)												    		
									
									update T0140_Uniform_Payment_Transcation 
										set Uni_Opening =  Uni_Opening - @Uni_Return
										   ,Uni_Balance = Uni_Balance - @Uni_Return
									where for_date > @For_Date and cmp_ID = @cmp_ID and emp_Id = @emp_Id and Uni_Apr_Id = @Uni_Apr_ID
										
									select @Uni_Closing_Balance = isnull(Uni_Balance,0) from T0140_Uniform_Payment_Transcation 
									where for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Flag = 0
									and Uni_Apr_Id = @Uni_Apr_ID
										
										if @Uni_Closing_Balance = 0 
											Begin
												IF @Uni_Flag = 1
													Begin
														if not Exists(select 1 from T0140_Uniform_Payment_Transcation where for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Uni_Apr_Id = @Uni_Apr_ID)
															BEGIN
																Select @Uni_Amount = Isnull(SUM(Uni_Amount),0) FROM T0100_Uniform_Emp_Issue where Uni_Apr_Id = @Uni_Apr_ID and Cmp_ID = @Cmp_ID
														
																insert T0140_Uniform_Payment_Transcation
																(Uni_Tran_ID,Uni_Apr_Id,Cmp_ID,Uni_ID,Emp_ID,For_Date,Uni_Opening,Uni_Credit,Uni_Debit,Uni_Balance,Uni_Flag)
																values(@Uni_Tran_ID,@Uni_Apr_Id,@Cmp_ID,@Uni_Id,@Emp_ID,@For_Date,@Uni_Amount,0,0,@Uni_Amount,1)
															End
													End
											End
								End
						End
					
				End
		End
	Else
		Begin
			
			declare curDel cursor for
			Select del.cmp_ID,del.Payment_Amount,del.Payment_Date,del.Emp_Id,del.Uni_Apr_Id,UEI.Uni_ID,del.Uni_Flag
			From deleted del inner JOIN T0100_Uniform_Emp_Issue UEI
			ON del.Uni_Apr_Id = UEI.Uni_Apr_Id
			
			open curDel
			fetch next from curDel into @Cmp_ID,@Uni_Return,@for_Date,@Emp_ID,@Uni_Apr_ID,@Uni_Id,@Uni_Flag
			while @@fetch_status = 0
			begin 

				if @Uni_Flag = 1 
					Begin
						update T0100_Uniform_Emp_Issue
							set Refund_Pending_Amount = (Refund_Pending_Amount + @Uni_Return)
							where  Uni_Apr_Id = @Uni_Apr_ID and @Uni_Flag = 1	
			 
						update T0140_Uniform_Payment_Transcation 
							set Uni_Debit = Uni_Debit - @Uni_Return 
							   ,Uni_Balance = Uni_Balance + @Uni_Return
						where emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID and Uni_Flag = 1 and Uni_Apr_Id = @Uni_Apr_ID
								
						update T0140_Uniform_Payment_Transcation 
							set Uni_Opening = Uni_Opening + @Uni_Return
							  ,Uni_Balance = Uni_Balance + @Uni_Return
						where emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID and Uni_Flag = 1 and Uni_Apr_Id = @Uni_Apr_ID
					End
				Else
					Begin
						
						update T0100_Uniform_Emp_Issue
							set Deduct_Pending_Amount = (Deduct_Pending_Amount + @Uni_Return)
							where  Uni_Apr_Id = @Uni_Apr_ID and @Uni_Flag = 0
							
			 
						update T0140_Uniform_Payment_Transcation 
							set  Uni_Debit = Uni_Debit - @Uni_Return
								,Uni_Balance = Uni_Balance + @Uni_Return 
						where emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID and Uni_Flag = 0 and Uni_Apr_Id = @Uni_Apr_ID
								
						update T0140_Uniform_Payment_Transcation 
							set Uni_Opening = Uni_Opening + @Uni_Return 
							   ,Uni_Balance = Uni_Balance + @Uni_Return
						where emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID and Uni_Flag = 0 and Uni_Apr_Id = @Uni_Apr_ID
						
						Delete FROM T0140_Uniform_Payment_Transcation 
						where emp_id = @emp_id and for_date >= @for_date and cmp_ID = @cmp_ID and Uni_Flag = 1 and Uni_Apr_Id = @Uni_Apr_ID
						
						update T0100_Uniform_Emp_Issue
							set Refund_Pending_Amount = Uni_Amount
							where  Uni_Apr_Id = @Uni_Apr_ID 
					End
				fetch next from curDel into @Cmp_ID,@Uni_Return,@for_Date,@Emp_ID,@Uni_Apr_ID,@Uni_Id,@Uni_Flag
			end				
			close curDel
			deallocate curDel
		End
END