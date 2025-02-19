CREATE TABLE [dbo].[T0100_ADVANCE_PAYMENT] (
    [Adv_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [For_Date]          DATETIME        NOT NULL,
    [Adv_Amount]        NUMERIC (18)    NOT NULL,
    [Adv_P_Days]        NUMERIC (18, 1) NOT NULL,
    [Adv_Approx_Salary] NUMERIC (18)    NOT NULL,
    [Adv_Comments]      VARCHAR (250)   NOT NULL,
    [Res_Id]            NUMERIC (18)    NULL,
    [Adv_Approval_ID]   NUMERIC (18)    NULL,
    [Sal_Tran_ID]       NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0100_ADVANCE_PAYMENT] PRIMARY KEY CLUSTERED ([Adv_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_ADVANCE_PAYMENT_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_ADVANCE_PAYMENT_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO





CREATE TRIGGER Tri_T0100_ADVANCE_PAYMENT
ON dbo.T0100_ADVANCE_PAYMENT
FOR INSERT,Delete
AS
	
	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @Adv_Tran_ID	numeric
	declare @Adv_Issue		numeric
	declare @Last_Closing		numeric

	select @Adv_Tran_ID = Isnull(Max(Adv_Tran_ID),0)  +1 From T0140_ADVANCE_TRANSACTION

	IF  update(Adv_ID) 
		begin
		
		select @cmp_ID = cmp_ID,@emp_id = Emp_ID , @Adv_Issue = ins.Adv_Amount,@for_Date = For_Date
				from inserted ins	

		if exists(select * from T0140_ADVANCE_TRANSACTION where for_date = @For_date  
			and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
			begin
				update T0140_ADVANCE_TRANSACTION set Adv_Issue = Adv_Issue + @Adv_Issue
					,Adv_Closing = Adv_Closing + @Adv_Issue	
				where for_date = @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id
				
				update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening + @Adv_Issue
					,Adv_Closing = Adv_Closing + @Adv_Issue	
				where for_date > @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id
			end
		else
				begin	    
	    			select @Last_Closing = isnull(Adv_Closing,0) from T0140_ADVANCE_TRANSACTION
	    				where for_date = (select max(for_date) from T0140_ADVANCE_TRANSACTION 
	    						where for_date < @For_date
	    					 and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    					and cmp_ID = @cmp_ID
	    					 and emp_id = @emp_Id
	
					if @Last_Closing is null 
						set  @Last_Closing = 0
					
					insert T0140_ADVANCE_TRANSACTION(Adv_Tran_ID,emp_id,cmp_ID,For_Date,Adv_Opening,Adv_Issue,
						Adv_Closing,Adv_Return)
					values(@Adv_Tran_ID,@emp_id,@cmp_ID,@for_Date,@last_closing,@Adv_Issue
						,@last_closing + @Adv_Issue,0)												    		
				
					update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening + @Adv_Issue
						,Adv_Closing = Adv_Closing + @Adv_Issue	
					where for_date > @For_Date and cmp_ID = @cmp_ID
						and emp_Id = @emp_Id

	    		end	
	    End
	else
		begin

		 	declare curDel cursor for
				select Del.Cmp_ID ,del.Emp_ID ,del.Adv_Amount ,For_Date from deleted del
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID, @Adv_Issue ,@for_Date 
			while @@fetch_status = 0
			begin 
			
				update T0140_ADVANCE_TRANSACTION set Adv_Issue = Adv_Issue - @Adv_Issue 
					,Adv_Closing = Adv_Closing - @Adv_Issue
				where emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
						
				update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening - @Adv_Issue
					,Adv_Closing = Adv_Closing - @Adv_Issue
				where emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
				
				fetch next from curDel into @Cmp_ID, @Emp_ID, @Adv_Issue ,@for_Date 
			end				
			close curDel
			deallocate curDel
		end




