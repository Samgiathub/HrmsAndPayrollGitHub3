CREATE TABLE [dbo].[T0210_MONTHLY_LOAN_PAYMENT] (
    [Loan_Pay_ID]             NUMERIC (18)    NOT NULL,
    [Loan_Apr_ID]             NUMERIC (18)    NOT NULL,
    [Cmp_ID]                  NUMERIC (18)    NOT NULL,
    [Sal_Tran_ID]             NUMERIC (18)    NULL,
    [S_Sal_Tran_ID]           NUMERIC (18)    NULL,
    [L_Sal_Tran_ID]           NUMERIC (18)    NULL,
    [Loan_Pay_Amount]         NUMERIC (22, 2) NOT NULL,
    [Loan_Pay_Comments]       VARCHAR (250)   NOT NULL,
    [Loan_Payment_Date]       DATETIME        NOT NULL,
    [Loan_Payment_Type]       VARCHAR (20)    NOT NULL,
    [Bank_Name]               VARCHAR (50)    NOT NULL,
    [Loan_Cheque_No]          VARCHAR (50)    NOT NULL,
    [Loan_Pay_Code]           VARCHAR (20)    NULL,
    [Temp_Sal_Tran_ID]        NUMERIC (18)    NULL,
    [Interest_Percent]        NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_LOAN_PAYMENT_Interest_Percent] DEFAULT ((0)) NOT NULL,
    [Interest_Amount]         NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_LOAN_PAYMENT_Interest_Amount] DEFAULT ((0)) NOT NULL,
    [Interest_Subsidy_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_LOAN_PAYMENT_Interest_Subsidy_Amount] DEFAULT ((0)) NOT NULL,
    [Is_Loan_Interest_Flag]   NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Is_Subsidy_Flag]         NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_LOAN_PAYMENT_Is_Subsidy_Flag] DEFAULT ((0)) NOT NULL,
    [Subsidy_Amount]          NUMERIC (18, 2) CONSTRAINT [DF_T0210_MONTHLY_LOAN_PAYMENT_Subsidy_Amount] DEFAULT ((0)) NOT NULL,
    [Temp_Loan_Pay_ID]        NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Pay_Tran_ID]             NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0210_MONTHLY_LOAN_PAYMENT] PRIMARY KEY CLUSTERED ([Loan_Pay_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0210_MONTHLY_LOAN_PAYMENT_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0210_MONTHLY_LOAN_PAYMENT_T0120_LOAN_APPROVAL] FOREIGN KEY ([Loan_Apr_ID]) REFERENCES [dbo].[T0120_LOAN_APPROVAL] ([Loan_Apr_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_LOAN_PAYMENT_T0200_MONTHLY_SALARY] FOREIGN KEY ([Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY] ([Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_LOAN_PAYMENT_T0200_MONTHLY_SALARY_LEAVE] FOREIGN KEY ([L_Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY_LEAVE] ([L_Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_MONTHLY_LOAN_PAYMENT_T0201_MONTHLY_SALARY_SETT] FOREIGN KEY ([S_Sal_Tran_ID]) REFERENCES [dbo].[T0201_MONTHLY_SALARY_SETT] ([S_Sal_Tran_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0210_MONTHLY_LOAN_PAYMENT_10_1394104007__K14_K3_K2_17]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([Temp_Sal_Tran_ID] ASC, [Cmp_ID] ASC, [Loan_Apr_ID] ASC)
    INCLUDE([Interest_Subsidy_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_MONTHLY_LOAN_PAYMENT_GET_Interest_Subsidy_Recover_Amount]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([Loan_Apr_ID] ASC, [Cmp_ID] ASC, [Loan_Payment_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_MONTHLY_LOAN_PAYMENT_For_P0200_Pre_Salary]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([Sal_Tran_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_MONTHLY_LOAN_PAYMENT_For_P0200_Pre_Salary2]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([L_Sal_Tran_ID] ASC);


GO
CREATE STATISTICS [_dta_stat_1394104007_3_2_14]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([Cmp_ID], [Loan_Apr_ID], [Temp_Sal_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_1394104007_2_14]
    ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]([Loan_Apr_ID], [Temp_Sal_Tran_ID]);


GO




CREATE TRIGGER [DBO].[Tri_T0210_MONTHLY_LOAN_PAYMENT]
ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]
FOR INSERT,Delete
AS

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @Loan_Tran_ID	numeric
	declare @Loan_Id		numeric
	declare @Loan_Return	numeric(22,2)	
	declare @Last_Closing		numeric(22,2)
	Declare @LOAN_Apr_ID	numeric
	Declare @Last_Closing_Balance	numeric
	Declare @First_Deduction_Principal_Amt	numeric
	Declare @Sum_of_Interest_Amt numeric(18,2)
	Declare @Loan_Int_Amount numeric
	Declare @Calculated_Interest_Amount numeric(18,2)
	Declare @Subsidy_Amount numeric(18,2)
	
	Set @Last_Closing_Balance = 0

	select @Loan_Tran_ID = Isnull(Max(Loan_Tran_ID),0)  +1 From T0140_LOAN_TRANSACTION

	IF  update(Loan_Apr_ID) 
		begin
		select @cmp_ID = ins.cmp_ID,@Loan_Return = ins.Loan_Pay_Amount,@for_Date = Loan_Payment_Date
				,@Emp_ID = Emp_Id , @Loan_ID = La.loan_ID ,@LOAN_Apr_ID = ins.LOAN_Apr_ID, @First_Deduction_Principal_Amt = LM.Is_Principal_First_than_Int,@Loan_Int_Amount = Interest_Amount,@Calculated_Interest_Amount = Calculated_Interest_Amount
				,@Subsidy_Amount = ins.Subsidy_Amount
				from inserted ins	Inner join T0120_Loan_Approval La on ins.Loan_apr_ID = La.loan_Apr_ID
				Inner JOIN T0040_LOAN_MASTER LM ON LM.Loan_ID = La.Loan_ID

			update T0120_LOAN_APPROVAL
			set LOAN_Apr_Pending_Amount = (LOAN_Apr_Pending_Amount - @LOAN_Return - @Subsidy_Amount)
			where  LOAN_Apr_ID = @LOAN_Apr_ID		
		
		if exists(select * from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  
			and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
			begin

				update T0140_LOAN_TRANSACTION 
				set Loan_Return = Loan_Return + @Loan_Return 
					,Subsidy_Amount = Subsidy_Amount + @Subsidy_Amount
					,Loan_Closing = Loan_Closing - @Loan_Return - @Subsidy_Amount
				where Loan_Id = @Loan_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 0  
					
				
				update T0140_LOAN_TRANSACTION set 
				Loan_Opening = Loan_Opening - @Loan_Return - @Subsidy_Amount
					,Loan_Closing = Loan_Closing - @Loan_Return - @Subsidy_Amount
				where Loan_Id = @Loan_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
					and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 0

				if @First_Deduction_Principal_Amt = 1
					Begin
						select @Last_Closing_Balance = isnull(Loan_Closing,0) from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Is_Loan_Interest_Flag = 0
						
						IF @Last_Closing_Balance = 0 
							Begin 
								if not Exists(select * from T0140_LOAN_TRANSACTION where for_date < @For_date and loan_Id = @loan_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Is_Loan_Interest_Flag = 1)
									BEGIN
										Select @Sum_of_Interest_Amt = Isnull(SUM(Interest_Amount),0) FROM T0210_MONTHLY_LOAN_PAYMENT where Loan_Apr_ID = @LOAN_Apr_ID and Cmp_ID = @Cmp_ID and Is_Loan_Interest_Flag = 0
										
										if @Calculated_Interest_Amount <> 0 
											Begin
												Set @Sum_of_Interest_Amt = @Sum_of_Interest_Amt + @Calculated_Interest_Amount
											End
										
										insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,Loan_Closing,Loan_Return,Loan_issue,Is_Loan_Interest_Flag)
										values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,0,@Sum_of_Interest_Amt,0,@Sum_of_Interest_Amt,1)
										
										Update T0120_LOAN_APPROVAL SET Total_Loan_Int_Amount = @Sum_of_Interest_Amt,Loan_Int_Installment_Amount = (Case When isnull(No_of_Inst_Loan_Amt,0) <> 0 then @Sum_of_Interest_Amt/No_of_Inst_Loan_Amt else 0 end),Loan_Apr_Pending_Int_Amount = @Sum_of_Interest_Amt
										Where Loan_Apr_ID = @Loan_Apr_ID and Emp_ID = @emp_Id and Loan_Id = @Loan_Id and Cmp_ID = @Cmp_ID
									End
								Else
									Begin
										Set @Loan_Return = @Loan_Int_Amount
										
										update T0120_LOAN_APPROVAL
										set Loan_Apr_Pending_Int_Amount  = (Loan_Apr_Pending_Int_Amount  - @LOAN_Return - @Subsidy_Amount)
										where  LOAN_Apr_ID = @LOAN_Apr_ID and @First_Deduction_Principal_Amt = 1
										
										update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return + @Loan_Return 
										,Subsidy_Amount = Subsidy_Amount + @Subsidy_Amount
										,Loan_Closing = Loan_Closing - @Loan_Return - @Subsidy_Amount
										where Loan_Id = @Loan_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 1
									
										update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return - @Subsidy_Amount
										,Loan_Closing = Loan_Closing - @Loan_Return - @Subsidy_Amount
										where Loan_Id = @Loan_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 1
										
										
										--Update T0120_LOAN_APPROVAL SET Total_Loan_Int_Amount = @Sum_of_Interest_Amt,Loan_Int_Installment_Amount = (Case When isnull(No_of_Inst_Loan_Amt,0) <> 0 then @Sum_of_Interest_Amt/No_of_Inst_Loan_Amt else 0 end)
										--Where Loan_Apr_ID = @Loan_Apr_ID and Emp_ID = @emp_Id and Loan_Id = @Loan_Id and Cmp_ID = @Cmp_ID
									End
							End 
					End
			end
		else
				begin	   
					
	    			select @Last_Closing = isnull(Loan_Closing,0) from T0140_LOAN_TRANSACTION
	    				where for_date = (select max(for_date) from T0140_LOAN_TRANSACTION 
	    						where for_date < @For_date
	    					and loan_Id = @loan_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    					and cmp_ID = @cmp_ID
	    					and loan_id = @loan_Id  and emp_id = @emp_Id
	
					if @Last_Closing is null 
						set  @Last_Closing = 0
					--Comment by nilesh patel on 27072015 --start
					--insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,
					--	Loan_Closing,Loan_Return,Loan_issue)
					--values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,@last_closing,
					--	@last_closing - @Loan_Return,@Loan_Return,0)												    		
				
					--update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return
					--	,Loan_Closing = Loan_Closing - @Loan_Return	
					--where Loan_Id = @Loan_Id and for_date > @For_Date and cmp_ID = @cmp_ID
					--	and emp_Id = @emp_Id
					--Comment by nilesh patel on 27072015 --End

					select @Last_Closing_Balance = isnull(Loan_Closing,0) from T0140_LOAN_TRANSACTION 
					where for_date  = (
											select max(for_date) 
												from T0140_LOAN_TRANSACTION 
	    									where for_date < @For_date
	    									and loan_Id = @loan_id and cmp_ID = @cmp_ID and emp_id = @emp_Id and Is_Loan_Interest_Flag = 0 
									   ) 
							and loan_Id = @loan_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Is_Loan_Interest_Flag = 0
						
						IF @Last_Closing_Balance = 0
							BEGIN
								
								if @First_Deduction_Principal_Amt = 1 --'Added by nilesh patel on 22072015 -start
									Begin
												
												Set @Loan_Return = @Loan_Int_Amount
										
												update T0120_LOAN_APPROVAL
												set Loan_Apr_Pending_Int_Amount = (Loan_Apr_Pending_Int_Amount - @LOAN_Return - @Subsidy_Amount)
												where  LOAN_Apr_ID = @LOAN_Apr_ID and @First_Deduction_Principal_Amt = 1
												
												insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,
													Loan_Closing,Loan_Return,Loan_issue,Is_Loan_Interest_Flag,Subsidy_Amount)
												values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,@last_closing,
													@last_closing - @Loan_Return,@Loan_Return,0,1,@Subsidy_Amount)
													
												update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return - @Subsidy_Amount
												,Loan_Closing = Loan_Closing - @Loan_Return	 - @Subsidy_Amount
												where Loan_Id = @Loan_Id and for_date > @For_Date and cmp_ID = @cmp_ID
												and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 1
									End
							End
						Else
							Begin 
								
								insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,
									Loan_Closing,Loan_Return,Loan_issue,Subsidy_Amount)
								values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,@last_closing,
									@last_closing - @Loan_Return,@Loan_Return,0,@Subsidy_Amount)												    		
							
								update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return - @Subsidy_Amount
									,Loan_Closing = Loan_Closing - @Loan_Return	 - @Subsidy_Amount
								where Loan_Id = @Loan_Id and for_date > @For_Date and cmp_ID = @cmp_ID
									and emp_Id = @emp_Id
								
								select @Last_Closing_Balance = isnull(Loan_Closing,0) 
									from T0140_LOAN_TRANSACTION
								where for_date  = (
											select max(for_date) 
												from T0140_LOAN_TRANSACTION 
	    									where for_date <= @For_date
	    									and loan_Id = @loan_id and cmp_ID = @cmp_ID and emp_id = @emp_Id and Is_Loan_Interest_Flag = 0 
									   ) 
								and loan_Id = @loan_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Is_Loan_Interest_Flag = 0
								
								if @Last_Closing_Balance = 0 
									Begin
										if @First_Deduction_Principal_Amt = 1
										Begin
											if not Exists(select * from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id and Is_Loan_Interest_Flag = 1)
												BEGIN 
														select @Loan_Tran_ID = Isnull(Max(Loan_Tran_ID),0)  +1 From T0140_LOAN_TRANSACTION
														Select @Sum_of_Interest_Amt = Isnull(SUM(Interest_Amount),0) FROM T0210_MONTHLY_LOAN_PAYMENT where Loan_Apr_ID = @LOAN_Apr_ID and Cmp_ID = @Cmp_ID
														if @Calculated_Interest_Amount <> 0 
															Begin
																Set @Sum_of_Interest_Amt = @Sum_of_Interest_Amt + @Calculated_Interest_Amount
															End
														insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,Loan_Closing,Loan_Return,Loan_issue,Is_Loan_Interest_Flag,Subsidy_Amount)
														values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,0,@Sum_of_Interest_Amt,0,@Sum_of_Interest_Amt,1,@Subsidy_Amount)
														
														Update T0120_LOAN_APPROVAL SET Total_Loan_Int_Amount = @Sum_of_Interest_Amt,Loan_Int_Installment_Amount = (Case When isnull(No_of_Inst_Loan_Amt,0) <> 0 then @Sum_of_Interest_Amt/No_of_Inst_Loan_Amt else 0 end),Loan_Apr_Pending_Int_Amount = @Sum_of_Interest_Amt
														Where Loan_Apr_ID = @Loan_Apr_ID and Emp_ID = @emp_Id and Loan_Id = @Loan_Id and Cmp_ID = @Cmp_ID
												End
										End
									End
							End
	    		end	
	    End
	else
		begin

		 	declare curDel cursor for
				select Del.Cmp_ID ,Emp_Id,La.Loan_ID,del.Loan_Pay_Amount ,Loan_Payment_Date ,del.Loan_Apr_ID,del.Is_Loan_Interest_Flag,del.Interest_Amount,del.subsidy_Amount from deleted del
					Inner join T0120_Loan_Approval La on del.Loan_apr_ID = La.loan_Apr_ID
					Inner JOIN T0040_LOAN_MASTER LM ON LM.Loan_ID = La.Loan_ID
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID,@Loan_Id , @Loan_Return ,@for_Date ,@Loan_Apr_ID,@First_Deduction_Principal_Amt,@Loan_Int_Amount,@Subsidy_Amount
			while @@fetch_status = 0
			begin 
				--Comment by nilesh patel on 27072015 --start
				--update T0120_LOAN_APPROVAL
				--	set LOAN_Apr_Pending_Amount = (LOAN_Apr_Pending_Amount + @LOAN_Return)
				--	where  LOAN_Apr_ID = @LOAN_Apr_ID	
	 
				--update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return - @Loan_Return
				--	,Loan_Closing = Loan_Closing + @Loan_Return
				--where loan_id = @loan_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
						
				--update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Return
				--	,Loan_Closing = Loan_Closing + @Loan_Return
				--where loan_id = @loan_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID
				--Comment by nilesh patel on 27072015 --End

				if @First_Deduction_Principal_Amt = 1 
					Begin
						Set @Loan_Return = @Loan_Int_Amount
						update T0120_LOAN_APPROVAL
							set Loan_Apr_Pending_Int_Amount = (Loan_Apr_Pending_Int_Amount + @LOAN_Return + @Subsidy_Amount)
							where  LOAN_Apr_ID = @LOAN_Apr_ID and @First_Deduction_Principal_Amt = 1	
			 
						update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return - @Loan_Return 
						,Subsidy_Amount = Subsidy_Amount - @Subsidy_Amount
							,Loan_Closing = Loan_Closing + @Loan_Return
						where loan_id = @loan_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	 and Is_Loan_Interest_Flag = 1
								
						update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Return + @Subsidy_Amount
							,Loan_Closing = Loan_Closing + @Loan_Return + @Subsidy_Amount
						where loan_id = @loan_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	 and Is_Loan_Interest_Flag = 1
					End
				Else
					Begin
						update T0120_LOAN_APPROVAL
							set LOAN_Apr_Pending_Amount = (LOAN_Apr_Pending_Amount + @LOAN_Return + @Subsidy_Amount)
							where  LOAN_Apr_ID = @LOAN_Apr_ID	
			 
						update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return - @Loan_Return
						, Subsidy_Amount = Subsidy_Amount - @Subsidy_Amount
							,Loan_Closing = Loan_Closing + @Loan_Return + @Subsidy_Amount
						where loan_id = @loan_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID and Is_Loan_Interest_Flag = 0	
								
						update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Return + @Subsidy_Amount
							,Loan_Closing = Loan_Closing + @Loan_Return + @Subsidy_Amount
						where loan_id = @loan_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	and Is_Loan_Interest_Flag = 0	
						
						Delete FROM T0140_LOAN_TRANSACTION where loan_id = @loan_Id and emp_id = @emp_id and for_date >= @for_date and cmp_ID = @cmp_ID	and Is_Loan_Interest_Flag = 1
						update T0120_LOAN_APPROVAL
							set Loan_Apr_Pending_Int_Amount = 0
							where  LOAN_Apr_ID = @LOAN_Apr_ID 
					End
				fetch next from curDel into @Cmp_ID, @Emp_ID,@Loan_Id , @Loan_Return ,@for_Date ,@Loan_Apr_ID,@First_Deduction_Principal_Amt,@Loan_Int_Amount,@Subsidy_Amount
			end				
			close curDel
			deallocate curDel
		end



/*********************************************
**************FOR GPF LOAN********************
*********************************************/
DECLARE @GPF_TRAN_ID	NUMERIC;
DECLARE @GPF_CREDIT		NUMERIC(18,4);

-- Commented by nilesh patel on 02012017 After Discussion With Nimesh/Rohitbhai
--if exists (select 1 from sys.tables where name = 'tmpLoanPay')
--	insert into tmpLoanPay select * FROM INSERTED
--else
--	select * INTO tmpLoanPay FROM INSERTED
	

IF EXISTS(SELECT 1 FROM INSERTED I INNER JOIN T0120_LOAN_APPROVAL LA ON I.Cmp_ID=LA.Cmp_ID AND I.Loan_Apr_ID=LA.Loan_Apr_ID 
			INNER JOIN T0040_LOAN_MASTER L ON LA.Cmp_ID=L.Cmp_ID AND LA.Loan_ID=L.Loan_ID 
			WHERE L.Is_GPF = 1)
	BEGIN
		SELECT	@Cmp_ID=INS.Cmp_ID,@Emp_Id=L.Emp_ID,@Loan_Id=L.Loan_ID,@GPF_CREDIT=INS.Loan_Pay_Amount,
					@For_Date=INS.Loan_Payment_Date
		FROM	INSERTED INS INNER JOIN T0120_LOAN_APPROVAL L ON INS.Cmp_ID=L.Cmp_ID AND INS.Loan_Apr_ID=L.Loan_Apr_ID
		
		
		SELECT	@GPF_TRAN_ID = TRAN_ID 
		FROM	T0140_EMP_GPF_TRANSACTION GPF
		WHERE	GPF.CMP_ID=@Cmp_ID AND GPF.EMP_ID=@Emp_Id AND MONTH(GPF.FOR_DATE) = MONTH(@For_Date) AND YEAR(GPF.FOR_DATE) = YEAR(@For_Date)
				AND GPF.GPF_CREDIT > 0 
		
		IF @GPF_TRAN_ID  IS NOT NULL
			BEGIN
				UPDATE	T0140_EMP_GPF_TRANSACTION 
				SET		GPF_CREDIT = ISNULL(GPF_CREDIT, 0) + @GPF_CREDIT
				WHERE	TRAN_ID=@GPF_TRAN_ID
			END
		ELSE
			BEGIN
				SET @GPF_TRAN_ID = ISNULL((SELECT MAX(TRAN_ID) FROM T0140_EMP_GPF_TRANSACTION), 0) +1
				
				INSERT	INTO T0140_EMP_GPF_TRANSACTION 
					(CMP_ID,TRAN_ID,EMP_ID,SAL_TRAN_ID,FOR_DATE,GPF_OPENING,GPF_CREDIT,GPF_DEBIT,GPF_CLOSING,SYSTEM_DATE)
				VALUES
					(@Cmp_ID,@GPF_TRAN_ID,@Emp_Id,0,@For_Date, 0,@GPF_CREDIT,0,0, GETDATE())
			END
		
		EXEC dbo.P0140_UPDATE_GPF_CLOSING @CMP_ID, @Emp_Id, @For_Date	
	END
IF EXISTS(SELECT 1 FROM DELETED D INNER JOIN T0120_LOAN_APPROVAL LA ON D.Cmp_ID=LA.Cmp_ID AND D.Loan_Apr_ID=LA.Loan_Apr_ID 
			INNER JOIN T0040_LOAN_MASTER L ON LA.Cmp_ID=L.Cmp_ID AND LA.Loan_ID=L.Loan_ID 
			WHERE L.Is_GPF = 1)
	BEGIN
		SELECT	@Cmp_ID=D.Cmp_ID,@Emp_Id=L.Emp_ID,@For_Date=D.Loan_Payment_Date
		FROM	DELETED D INNER JOIN T0120_LOAN_APPROVAL L ON D.Cmp_ID=L.Cmp_ID AND D.Loan_Apr_ID=L.Loan_Apr_ID
		
		SELECT	@GPF_TRAN_ID = TRAN_ID 
		FROM	T0140_EMP_GPF_TRANSACTION GPF
		WHERE	GPF.CMP_ID=@Cmp_ID AND GPF.EMP_ID=@Emp_Id AND GPF.FOR_DATE = @For_Date
				AND GPF.GPF_CREDIT > 0 
		
		IF @GPF_TRAN_ID IS NOT NULL 
			DELETE FROM T0140_EMP_GPF_TRANSACTION WHERE TRAN_ID=@GPF_TRAN_ID
		
		EXEC dbo.P0140_UPDATE_GPF_CLOSING @CMP_ID, @Emp_Id, @For_Date	
	END
/*************END FOR GPF LOAN***************/



GO



CREATE TRIGGER [DBO].[Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE]
ON [dbo].[T0210_MONTHLY_LOAN_PAYMENT]
FOR UPDATE
AS
	set nocount on
	

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @Loan_Tran_ID	numeric
	declare @Loan_Id		numeric
	declare @Loan_Return	numeric(18,2)	
	declare @Last_Closing		numeric(18,2)
	Declare @Loan_Apr_ID	numeric 
	declare @Pre_Loan_Pay_Amount numeric (18,2)
	Declare @Loan_Pay_ID numeric 
	declare @subsidy_Amount Numeric(18,2)
		
	
	select @Loan_Tran_ID = Isnull(Max(Loan_Tran_ID),0)  +1 From T0140_LOAN_TRANSACTION

	

	 	declare curDel_Pay cursor for
				select Del.Cmp_ID ,Emp_Id,Loan_ID,del.Loan_Pay_Amount ,Loan_Payment_Date ,del.Loan_Apr_ID,del.subsidy_Amount from deleted del
					Inner join T0120_Loan_Approval La on del.Loan_apr_ID = La.loan_Apr_ID
			open curDel_Pay
			fetch next from curDel_Pay into @Cmp_ID,@Emp_ID,@Loan_Id , @Loan_Return ,@for_Date ,@Loan_Apr_ID,@subsidy_Amount -- changed by rohit on 27072016
			while @@fetch_status = 0
			begin 
				
				update T0120_LOAN_APPROVAL
					set Loan_Apr_Pending_Amount = (Loan_Apr_Pending_Amount + @Loan_Return + @subsidy_Amount)
					where  Loan_Apr_ID = @Loan_Apr_ID	
			
				update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return - @Loan_Return
				,Subsidy_amount = Subsidy_amount - @subsidy_Amount
					,Loan_Closing = Loan_Closing + @Loan_Return + @subsidy_Amount
				where loan_id = @loan_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
						
				update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Return + @subsidy_Amount
					,Loan_Closing = Loan_Closing + @Loan_Return + @subsidy_Amount
				where loan_id = @loan_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
				
				fetch next from curDel_Pay into @Cmp_ID, @Emp_ID,@Loan_Id , @Loan_Return ,@for_Date ,@Loan_Apr_ID,@subsidy_Amount
			end				
			close curDel_Pay
			deallocate curDel_Pay


		
		select @Loan_Apr_ID = ins.Loan_Apr_ID ,@cmp_ID = ins.cmp_ID,@Loan_Return = ins.Loan_Pay_Amount,@for_Date = Loan_Payment_Date
				,@Emp_ID = Emp_Id , @Loan_ID = loan_ID ,@Loan_Pay_ID = Loan_Pay_ID,@subsidy_Amount = ins.Subsidy_Amount
				from inserted ins	Inner join T0120_Loan_Approval La on ins.Loan_apr_ID = La.loan_Apr_ID
	
	
	if isnull(@Loan_Apr_ID,0) > 0 
		begin
		
		
				update T0120_LOAN_APPROVAL
					set Loan_Apr_Pending_Amount = (Loan_Apr_Pending_Amount - @Loan_Return - @subsidy_Amount) 
					where  Loan_Apr_ID = @Loan_Apr_ID	
							

				if exists(select * from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  
					and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
					begin
						update T0140_LOAN_TRANSACTION set Loan_Return = Loan_Return + @Loan_Return
						,Subsidy_amount = Subsidy_amount + @subsidy_Amount
							,Loan_Closing = Loan_Closing - @Loan_Return - @subsidy_Amount
						where Loan_Id = @Loan_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
							and emp_Id = @emp_Id
						
						update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return - @subsidy_Amount
							,Loan_Closing = Loan_Closing - @Loan_Return - @subsidy_Amount
						where Loan_Id = @Loan_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
							and emp_Id = @emp_Id
					end
				else
						begin	    
	    					select @Last_Closing = isnull(Loan_Closing,0) from T0140_LOAN_TRANSACTION
	    						where for_date = (select max(for_date) from T0140_LOAN_TRANSACTION 
	    								where for_date < @For_date
	    							and loan_Id = @loan_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    							and cmp_ID = @cmp_ID
	    							and loan_id = @loan_Id  and emp_id = @emp_Id
			
							if @Last_Closing is null 
								set  @Last_Closing = 0
							
							insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,
								Loan_Closing,Loan_Return,Loan_issue,Subsidy_Amount)
							values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,@last_closing,
								@last_closing - @Loan_Return,@Loan_Return,0,@Subsidy_Amount)												    		
						
							update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Return - @Subsidy_Amount
								,Loan_Closing = Loan_Closing - @Loan_Return	- @Subsidy_Amount
							where Loan_Id = @Loan_Id and for_date > @For_Date and cmp_ID = @cmp_ID
								and emp_Id = @emp_Id
		 
				End
		end

/*********************************************
**************FOR GPF LOAN********************
*********************************************/
DECLARE @GPF_TRAN_ID	NUMERIC;
DECLARE @GPF_CREDIT		NUMERIC(18,4);

IF EXISTS(SELECT 1 FROM INSERTED I INNER JOIN T0120_LOAN_APPROVAL LA ON I.Cmp_ID=LA.Cmp_ID AND I.Loan_Apr_ID=LA.Loan_App_ID 
			INNER JOIN T0040_LOAN_MASTER L ON LA.Cmp_ID=L.Cmp_ID AND LA.Loan_ID=L.Loan_ID 
			WHERE L.Is_GPF = 1)
	BEGIN
		SELECT	@Cmp_ID=INS.Cmp_ID,@Emp_Id=L.Emp_ID,@Loan_Id=L.Loan_ID,@GPF_CREDIT=INS.Loan_Pay_Amount,
					@For_Date=INS.Loan_Payment_Date
		FROM	INSERTED INS INNER JOIN T0120_LOAN_APPROVAL L ON INS.Cmp_ID=L.Cmp_ID AND INS.Loan_Apr_ID=L.Loan_App_ID
		
		
		SELECT	@GPF_TRAN_ID = TRAN_ID 
		FROM	T0140_EMP_GPF_TRANSACTION GPF
		WHERE	GPF.CMP_ID=@Cmp_ID AND GPF.EMP_ID=@Emp_Id AND MONTH(GPF.FOR_DATE) = MONTH(@For_Date) AND YEAR(GPF.FOR_DATE) = YEAR(@For_Date)
				AND GPF.GPF_CREDIT > 0 
		
		IF @GPF_TRAN_ID  IS NOT NULL
			BEGIN
				UPDATE	T0140_EMP_GPF_TRANSACTION 
				SET		GPF_CREDIT = @GPF_CREDIT
				WHERE	TRAN_ID=@GPF_TRAN_ID
			END
		ELSE
			BEGIN
				SET @GPF_TRAN_ID = ISNULL((SELECT MAX(TRAN_ID) FROM T0140_EMP_GPF_TRANSACTION), 0) +1
				
				INSERT	INTO T0140_EMP_GPF_TRANSACTION 
					(CMP_ID,TRAN_ID,EMP_ID,SAL_TRAN_ID,FOR_DATE,GPF_OPENING,GPF_CREDIT,GPF_DEBIT,GPF_CLOSING,SYSTEM_DATE)
				VALUES
					(@Cmp_ID,@GPF_TRAN_ID,@Emp_Id,0,@For_Date, 0,@GPF_CREDIT,0,0, GETDATE())
			END
		
		EXEC dbo.P0140_UPDATE_GPF_CLOSING @CMP_ID, @Emp_Id, @For_Date	
	END
/*************END FOR GPF LOAN***************/




