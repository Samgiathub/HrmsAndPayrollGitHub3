CREATE TABLE [dbo].[T0230_MONTHLY_CLAIM_PAYMENT_DETAIL] (
    [Claim_Pay_Dtl_ID] NUMERIC (18)    NOT NULL,
    [Claim_Pay_Id]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Claim_Apr_Id]     NUMERIC (18)    NOT NULL,
    [Claim_Apr_Dtl_ID] NUMERIC (18)    NOT NULL,
    [Sal_Tran_Id]      NUMERIC (18)    NULL,
    [Claim_Status]     VARCHAR (50)    NULL,
    [Claim_ID]         NUMERIC (18)    NULL,
    [Claim_Apr_Date]   DATETIME        NULL,
    [Claim_PetrolKM]   NUMERIC (18, 3) NULL,
    [Claim_Apr_Amnt]   NUMERIC (18, 3) NULL,
    [Claim_Purpose]    VARCHAR (500)   NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [S_Emp_ID]         NUMERIC (18)    NULL,
    [Claim_App_Amount] NUMERIC (18, 3) DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL] PRIMARY KEY CLUSTERED ([Claim_Pay_Dtl_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL_T0120_CLAIM_APPROVAL] FOREIGN KEY ([Claim_Apr_Id]) REFERENCES [dbo].[T0120_CLAIM_APPROVAL] ([Claim_Apr_ID]),
    CONSTRAINT [FK_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL_T0130_CLAIM_APPROVAL_DETAIL] FOREIGN KEY ([Claim_Apr_Dtl_ID]) REFERENCES [dbo].[T0130_CLAIM_APPROVAL_DETAIL] ([Claim_Apr_Dtl_ID])
);


GO


CREATE TRIGGER [DBO].[Tri_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL]
ON [dbo].[T0230_MONTHLY_CLAIM_PAYMENT_DETAIL]
FOR INSERT,Delete
AS

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @CLAIM_Tran_ID	numeric
	declare @CLAIM_Id		numeric
	declare @CLAIM_Return	numeric	
	declare @Last_Closing		numeric
	Declare @CLAIM_Apr_ID	numeric 
	
	select @CLAIM_Tran_ID = Isnull(Max(CLAIM_Tran_ID),0)  +1 From T0140_CLAIM_TRANSACTION

	IF  update(CLAIM_Apr_ID) 
		begin
		
		select @CLAIM_Apr_ID = ins.Claim_Apr_ID ,@cmp_ID = ins.cmp_ID,@CLAIM_Return = ins.Claim_Apr_Amnt,@for_Date = CLAIM_Payment_Date
				,@Emp_ID = Emp_Id , @CLAIM_ID = CLAIM_ID
				from inserted ins Inner join T0210_MONTHLY_CLAIM_PAYMENT La on La.Claim_Pay_ID=ins.Claim_Pay_ID --T0120_CLAIM_Approval La on ins.CLAIM_apr_ID = La.CLAIM_Apr_ID

		update T0120_CLAIM_APPROVAL
			set CLAIM_Apr_Pending_Amount = (CLAIM_Apr_Pending_Amount - @CLAIM_Return)
			where  CLAIM_Apr_ID = @CLAIM_Apr_ID	
					

		if exists(select * from T0140_CLAIM_TRANSACTION where for_date = @For_date and CLAIM_Id = @CLAIM_Id  
			and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
			begin
				update T0140_CLAIM_TRANSACTION set CLAIM_Return = CLAIM_Return + @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return
				where CLAIM_Id = @CLAIM_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id
				
				update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return
				where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id
			end
		else
				begin	    
	    			select @Last_Closing = isnull(CLAIM_Closing,0) from T0140_CLAIM_TRANSACTION
	    				where for_date = (select max(for_date) from T0140_CLAIM_TRANSACTION 
	    						where for_date < @For_date
	    					and CLAIM_Id = @CLAIM_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    					and cmp_ID = @cmp_ID
	    					and CLAIM_id = @CLAIM_Id  and emp_id = @emp_Id
	
					if @Last_Closing is null 
						set  @Last_Closing = 0
					
					insert T0140_CLAIM_TRANSACTION(CLAIM_Tran_ID,emp_id,CLAIM_Id,cmp_ID,For_Date,CLAIM_Opening,
						CLAIM_Closing,CLAIM_Return,CLAIM_issue)
					values(@CLAIM_Tran_ID,@emp_id,@CLAIM_Id,@cmp_ID,@for_Date,@last_closing,
						@last_closing - @CLAIM_Return,@CLAIM_Return,0)												    		
				
					update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Return
						,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return	
					where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and cmp_ID = @cmp_ID
						and emp_Id = @emp_Id

	    		end	
	    End
	else
		begin

		 	declare curDel_Pay cursor for
				select Del.Cmp_ID ,Emp_Id,CLAIM_ID,del.Claim_Apr_Amnt ,CLAIM_Payment_Date ,del.CLAIM_Apr_ID from deleted del
					Inner join T0210_MONTHLY_CLAIM_PAYMENT La on La.Claim_Pay_ID=del.Claim_pay_Id  --Inner join T0120_CLAIM_Approval La on del.CLAIM_apr_ID = La.CLAIM_Apr_ID
			open curDel_Pay
			fetch next from curDel_Pay into @Cmp_ID,@Emp_ID,@CLAIM_Id , @CLAIM_Return ,@for_Date ,@CLAIM_Apr_ID
			while @@fetch_status = 0
			begin 
				
				update T0120_CLAIM_APPROVAL
					set CLAIM_Apr_Pending_Amount = (CLAIM_Apr_Pending_Amount + @CLAIM_Return)
					where  CLAIM_Apr_ID = @CLAIM_Apr_ID	
			
				update T0140_CLAIM_TRANSACTION set CLAIM_Return = CLAIM_Return - @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Return
				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
						
				update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening + @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Return
				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
				
				fetch next from curDel_Pay into @Cmp_ID, @Emp_ID,@CLAIM_Id , @CLAIM_Return ,@for_Date ,@CLAIM_Apr_ID
			end				
			close curDel_Pay
			deallocate curDel_Pay
		end





GO


CREATE TRIGGER [DBO].[Tri_T0230_MONTHLY_CLAIM_PAYMENT_DETAIL_UPDATE]
ON [dbo].[T0230_MONTHLY_CLAIM_PAYMENT_DETAIL]
FOR UPDATE
AS

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @CLAIM_Tran_ID	numeric
	declare @CLAIM_Id		numeric
	declare @CLAIM_Return	numeric	
	declare @Last_Closing		numeric
	Declare @CLAIM_Apr_ID	numeric 
	
	select @CLAIM_Tran_ID = Isnull(Max(CLAIM_Tran_ID),0)  +1 From T0140_CLAIM_TRANSACTION


	 	declare curDel_Pay cursor for
				select Del.Cmp_ID ,Emp_Id,CLAIM_ID,del.Claim_Apr_Amnt ,CLAIM_Payment_Date ,del.CLAIM_Apr_ID from deleted del
					Inner join T0210_MONTHLY_CLAIM_PAYMENT La on del.Claim_Pay_ID = La.Claim_Pay_Id
			open curDel_Pay
			fetch next from curDel_Pay into @Cmp_ID,@Emp_ID,@CLAIM_Id , @CLAIM_Return ,@for_Date ,@CLAIM_Apr_ID
			while @@fetch_status = 0
			begin 
				
				update T0120_CLAIM_APPROVAL
					set CLAIM_Apr_Pending_Amount = (CLAIM_Apr_Pending_Amount + @CLAIM_Return)
					where  CLAIM_Apr_ID = @CLAIM_Apr_ID	
			
				update T0140_CLAIM_TRANSACTION set CLAIM_Return = CLAIM_Return - @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Return
				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
						
				update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening + @CLAIM_Return
					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Return
				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
				
				fetch next from curDel_Pay into @Cmp_ID, @Emp_ID,@CLAIM_Id , @CLAIM_Return ,@for_Date ,@CLAIM_Apr_ID
			end				
			close curDel_Pay
			deallocate curDel_Pay



		select @CLAIM_Apr_ID = ins.CLAIM_Apr_ID ,@cmp_ID = ins.cmp_ID,@CLAIM_Return = ins.CLAIM_Apr_Amnt,@for_Date = CLAIM_Payment_Date
				,@Emp_ID = Emp_Id , @CLAIM_ID = CLAIM_ID
				from inserted ins	Inner join T0210_MONTHLY_CLAIM_PAYMENT La on ins.Claim_Pay_ID= La.Claim_Pay_ID

	if isnull(@CLAIM_Apr_ID,0) > 0 
		begin
				update T0120_CLAIM_APPROVAL
					set CLAIM_Apr_Pending_Amount = (CLAIM_Apr_Pending_Amount - @CLAIM_Return)
					where  CLAIM_Apr_ID = @CLAIM_Apr_ID	
							

				if exists(select * from T0140_CLAIM_TRANSACTION where for_date = @For_date and CLAIM_Id = @CLAIM_Id  
					and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
					begin
						update T0140_CLAIM_TRANSACTION set CLAIM_Return = CLAIM_Return + @CLAIM_Return
							,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return
						where CLAIM_Id = @CLAIM_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
							and emp_Id = @emp_Id
						
						update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Return
							,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return
						where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
							and emp_Id = @emp_Id
					end
				else
						begin	    
	    					select @Last_Closing = isnull(CLAIM_Closing,0) from T0140_CLAIM_TRANSACTION
	    						where for_date = (select max(for_date) from T0140_CLAIM_TRANSACTION 
	    								where for_date < @For_date
	    							and CLAIM_Id = @CLAIM_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    							and cmp_ID = @cmp_ID
	    							and CLAIM_id = @CLAIM_Id  and emp_id = @emp_Id
			
							if @Last_Closing is null 
								set  @Last_Closing = 0
							
							insert T0140_CLAIM_TRANSACTION(CLAIM_Tran_ID,emp_id,CLAIM_Id,cmp_ID,For_Date,CLAIM_Opening,
								CLAIM_Closing,CLAIM_Return,CLAIM_issue)
							values(@CLAIM_Tran_ID,@emp_id,@CLAIM_Id,@cmp_ID,@for_Date,@last_closing,
								@last_closing - @CLAIM_Return,@CLAIM_Return,0)												    		
						
							update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Return
								,CLAIM_Closing = CLAIM_Closing - @CLAIM_Return	
							where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and cmp_ID = @cmp_ID
								and emp_Id = @emp_Id
		 
				End
		end




