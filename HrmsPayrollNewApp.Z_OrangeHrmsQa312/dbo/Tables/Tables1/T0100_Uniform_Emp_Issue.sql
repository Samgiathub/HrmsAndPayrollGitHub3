CREATE TABLE [dbo].[T0100_Uniform_Emp_Issue] (
    [Uni_Apr_Id]             NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NULL,
    [Emp_ID]                 NUMERIC (18)    NULL,
    [Issue_Date]             DATETIME        NULL,
    [Uni_Id]                 NUMERIC (18)    NULL,
    [Uni_Pieces]             NUMERIC (18)    NULL,
    [Uni_Rate]               NUMERIC (18, 2) NULL,
    [Uni_Amount]             NUMERIC (18, 2) NULL,
    [Uni_deduct_Installment] NUMERIC (18)    NULL,
    [Uni_deduct_Amount]      NUMERIC (18, 2) NULL,
    [Uni_Refund_Installment] NUMERIC (18)    NULL,
    [Uni_Refund_Amount]      NUMERIC (18, 2) NULL,
    [Deduct_Pending_Amount]  NUMERIC (18, 2) NULL,
    [Refund_Pending_Amount]  NUMERIC (18, 2) NULL,
    [Modify_By]              VARCHAR (100)   NULL,
    [Modify_Date]            DATETIME        NULL,
    [Ip_Address]             VARCHAR (100)   NULL,
    [Uni_Stitching_Price]    NUMERIC (18, 2) NULL,
    [Deduction_Start_Date]   DATETIME        NULL,
    [Refund_Start_Date]      DATETIME        NULL,
    [New_Req_Apr_Id]         NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Uni_Apr_Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CLIX_T0100_Uniform_Emp_Issue]
    ON [dbo].[T0100_Uniform_Emp_Issue]([Emp_ID] ASC, [Issue_Date] DESC, [Uni_Id] ASC);


GO
-- =============================================
-- Author:		Nilesh Patel
-- Create date: 05-05-2017
-- Description:	For Uniform Installment Transcation
-- =============================================
CREATE TRIGGER [dbo].[Tri_T0100_Uniform_Emp_Issue]
ON [dbo].[T0100_Uniform_Emp_Issue] 
For INSERT,Delete
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @Uni_Tran_ID Numeric(18,0)
	Declare @Uni_Apr_Id Numeric(18,0)
	Declare @Cmp_ID Numeric(18,0)
	Declare @Uni_ID Numeric(18,0)
	Declare @Emp_ID Numeric(18,0)
	Declare @For_Date Datetime
	Declare @Uni_Opening Numeric(18,2)
	Declare @Uni_Credit Numeric(18,2)
	Declare @Uni_Debit Numeric(18,2)
	Declare @Uni_Balance Numeric(18,2)
	Declare @Uni_Flag Bit --0 For Deduction 1 For Refund
	Declare @Stock_ID Numeric(18,0)
	Declare @No_of_Pieces Numeric(18,0)
	Declare @Stock_Opening Numeric(18,0)
	Declare @Modify_by Varchar(100)
	Declare @Ip_Address Varchar(100)
	Declare @Modify_Date Datetime
	Declare @Pre_Closing numeric(18,2)
	Declare @Temp_Max_Date as datetime
	Declare @Chg_For_Date datetime
	Declare @Chg_Stock_ID numeric 
	Declare @New_Uni_Apr_Id Numeric(18,0)
	set @Temp_Max_Date = null	
	Set @Stock_ID = 0
	Set @No_of_Pieces = 0
	Set @Stock_Opening = 0
	Set @Modify_by = ''
	Set @Ip_Address = ''
	Set @Modify_Date = NULL
	
	Select @Uni_Tran_ID = Isnull(Max(Uni_Tran_ID),0) + 1 From T0140_Uniform_Payment_Transcation
	
	if update(Uni_Apr_Id)
		Begin
			Select @Cmp_ID = ins.Cmp_ID,@Uni_Apr_Id = ins.Uni_Apr_Id,@Uni_ID = ins.Uni_Id,@Emp_ID = ins.Emp_ID,@For_Date = ins.Issue_Date,
			@Uni_Opening = ins.Uni_Amount,	
			@Uni_Balance = ins.Uni_Amount,
			@No_of_Pieces = ins.Uni_Pieces,
			@Modify_by = ins.Modify_By,
			@Modify_Date = ins.Modify_Date,
			@Ip_Address = ins.Ip_Address,
			@New_Uni_Apr_Id=ISNULL(ins.New_Req_Apr_Id,0)
			From inserted ins 
			IF @New_Uni_Apr_Id > 0
			Begin
				return
			End
			
			IF Exists(select 1 from T0140_Uniform_Payment_Transcation where for_date = @For_date and Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and emp_id = @Emp_ID AND Uni_Apr_Id = @Uni_Apr_Id)
				BEGIN
					update T0140_Uniform_Payment_Transcation set Uni_Opening = Uni_Opening + @Uni_Opening 
							,Uni_Balance = Uni_Balance + @Uni_Opening
					where Uni_ID = @Uni_ID and emp_id = @Emp_ID and for_date = @for_Date and cmp_ID = @cmp_ID and Uni_Apr_Id = @Uni_Apr_Id
					
					update T0140_Uniform_Payment_Transcation set Uni_Opening = Uni_Opening + @Uni_Opening
							,Uni_Balance = Uni_Balance + @Uni_Opening
					where Uni_ID = @Uni_ID and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID and Uni_Apr_Id = @Uni_Apr_Id
				END
			Else
				Begin				
					insert T0140_Uniform_Payment_Transcation
					(Uni_Tran_ID,Uni_Apr_Id,Cmp_ID,Uni_ID,Emp_ID,For_Date,Uni_Opening,Uni_Credit,Uni_Debit,Uni_Balance,Uni_Flag)
					values(@Uni_Tran_ID,@Uni_Apr_Id,@Cmp_ID,@Uni_ID,@Emp_ID,@For_Date,@Uni_Opening,0,0,@Uni_Balance,0)
				End	
			
			Select @Stock_ID = Isnull(MAX(Stock_ID),0) + 1 From T0140_Uniform_Stock_Transaction
					
			--Select TOP 1 @Stock_Opening = Stock_Opening From T0140_Uniform_Stock_Transaction where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID
			select @Stock_Opening = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction
	    	where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction 
	    					  where for_date < @For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    	and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID						
			
			if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction Where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID and For_Date = @For_Date)
				BEGIN				
					UPDATE UST
						SET 
							UST.Stock_Opening = @Stock_Opening,
							UST.Stock_Debit = UST.Stock_Debit + @No_of_Pieces,
							UST.Stock_Balance = (@Stock_Opening + UST.Stock_Credit) - (UST.Stock_Debit + @No_of_Pieces)
					From T0140_Uniform_Stock_Transaction UST  
					Where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID and For_Date = @For_Date
					
					update UST set UST.Stock_Opening = @Stock_Opening - (UST.Stock_Debit + @No_of_Pieces),
							UST.Stock_Balance = @Stock_Opening - (UST.Stock_Debit + @No_of_Pieces)
					From T0140_Uniform_Stock_Transaction UST  
					where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID and For_Date > @For_Date
					
				End
			Else
				Begin
					if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction Where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID)
					BEGIN 
						declare @Last_Closing as NUMERIC(18,2)
						declare @Fabric_Price as NUMERIC(18,2)
						
						select @Last_Closing = isnull(Stock_Balance,0),@Fabric_Price=ISNULL(Fabric_Price,0) from T0140_Uniform_Stock_Transaction
	    				where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction 
	    					where for_date < @For_date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    					and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID
	    				
						Insert T0140_Uniform_Stock_Transaction
						(Stock_ID,Cmp_ID,Uni_ID,For_Date,Stock_Opening,Stock_Credit,Stock_Debit,Stock_Balance,Stock_Posting,Modify_By,Modify_Date,Ip_Address,Fabric_Price)
						VALUES(@Stock_ID,@Cmp_ID,@Uni_ID,@For_Date,@Last_Closing,0,@No_of_Pieces,(@Last_Closing - @No_of_Pieces),0,@Modify_by,@Modify_Date,@Ip_Address,@Fabric_Price)	
					END
				End
				
			if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)
			BEGIN								
				if @Pre_Closing is null
					set @Pre_Closing = 0
																					
					declare cur1 cursor for 
						Select Stock_ID,For_Date from dbo.T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date > @for_date order by for_date
					open cur1
					fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
					while @@fetch_status = 0
					begin
						--select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and for_date = @Chg_For_Date
						--Select @Pre_Closing=Stock_Balance from T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date = @Chg_For_Date
						select @Pre_Closing = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction
	    				where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction 
	    					where for_date < @Chg_For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    					and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID
						--select @Chg_For_Date,@Pre_Closing

						update dbo.T0140_Uniform_Stock_Transaction set 
							 Stock_Opening = @Pre_Closing
							,Stock_Balance = @Pre_Closing + Stock_Credit - Stock_Debit 
							,Stock_Posting=0									
						where Stock_ID = @Chg_Stock_ID				
					
						fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
					end					
					close cur1
					deallocate cur1	
			END
		End
	Else
		Begin
		--select * from deleted
			declare curDel cursor for
				select Del.Cmp_ID ,del.Emp_ID ,del.Uni_Id,del.Uni_Amount,del.Issue_Date,del.Uni_Apr_Id,del.Uni_Pieces,Isnull(del.New_Req_Apr_Id,0) from deleted del
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID,@Uni_ID,@Uni_Opening,@for_Date,@Uni_Apr_Id,@No_of_Pieces,@New_Uni_Apr_Id
			while @@fetch_status = 0
			begin 
				
				IF @New_Uni_Apr_Id=0
				Begin
				update T0140_Uniform_Payment_Transcation set Uni_Opening = Uni_Opening - @Uni_Opening 
							,Uni_Balance = Uni_Balance - @Uni_Opening
				where Uni_ID = @Uni_ID and emp_id = @Emp_ID and for_date = @for_Date and cmp_ID = @cmp_ID and Uni_Apr_Id = @Uni_Apr_Id
								
				update T0140_Uniform_Payment_Transcation set Uni_Opening = Uni_Opening - @Uni_Opening
							,Uni_Balance = Uni_Balance - @Uni_Opening
						where Uni_ID = @Uni_ID and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID and Uni_Apr_Id = @Uni_Apr_Id	 
				
				--Select TOP 1 @Stock_Opening = Stock_Opening From T0140_Uniform_Stock_Transaction where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID
				select @Stock_Opening = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction
	    			where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction 
	    					        	where for_date < @For_date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    			and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID
				--select @Stock_Opening,@No_of_Pieces,@Uni_Apr_Id,@For_Date
				--print @No_of_Pieces
				UPDATE UST
					SET UST.Stock_Debit = UST.Stock_Debit - @No_of_Pieces,
						UST.Stock_Balance = @Stock_Opening + Ust.Stock_Credit + @No_of_Pieces - UST.Stock_Debit 
						--UST.Stock_Balance = @Stock_Opening + @No_of_Pieces --Mukti(05062017)
				From T0140_Uniform_Stock_Transaction UST  
				Where Cmp_ID = @Cmp_ID and Uni_ID = @Uni_ID and For_Date = @For_Date
				
			--Added By Mukti(start)05062017	
				if Exists(SELECT 1 From T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID AND Cmp_ID = @CMP_Id)
				BEGIN								
					if @Pre_Closing is null
						set @Pre_Closing = 0
																						
						declare cur1 cursor for 
							Select Stock_ID,For_Date from dbo.T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date > @for_date order by for_date
						open cur1
						fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
						while @@fetch_status = 0
						begin
							--select @Temp_max_Date   = max(For_Date)  from dbo.T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and for_date = @Chg_For_Date
							--Select @Pre_Closing=Stock_Balance from T0140_Uniform_Stock_Transaction where Uni_ID = @Uni_ID and Cmp_ID = @Cmp_ID and for_date = @Chg_For_Date
							select @Pre_Closing = isnull(Stock_Balance,0) from T0140_Uniform_Stock_Transaction
	    					where for_date = (select max(for_date) from T0140_Uniform_Stock_Transaction 
	    						where for_date < @Chg_For_Date and Uni_ID = @Uni_ID and cmp_ID = @cmp_ID) 
	    						and cmp_ID = @cmp_ID and Uni_ID = @Uni_ID
							
							--select @Chg_For_Date,@Pre_Closing
							update dbo.T0140_Uniform_Stock_Transaction set 
								 Stock_Opening = @Pre_Closing
								,Stock_Balance = @Pre_Closing + Stock_Credit - Stock_Debit 
								--,Stock_Balance = @Pre_Closing + Stock_Credit  
								,Stock_Posting=0									
							where Stock_ID = @Chg_Stock_ID				
						
							fetch next from cur1 into @Chg_Stock_ID,@Chg_For_Date
						end					
						close cur1
						deallocate cur1	
				END
			--Added By Mukti(end)05062017
			
			    END
				fetch next from curDel into @Cmp_ID,@Emp_ID,@Uni_ID,@Uni_Opening,@for_Date,@Uni_Apr_Id,@No_of_Pieces,@New_Uni_Apr_Id
			end				
			close curDel
			deallocate curDel
		End
END
