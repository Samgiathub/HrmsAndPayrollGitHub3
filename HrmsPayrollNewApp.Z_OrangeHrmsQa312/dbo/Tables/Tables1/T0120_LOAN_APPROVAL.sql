CREATE TABLE [dbo].[T0120_LOAN_APPROVAL] (
    [Loan_Apr_ID]                 NUMERIC (18)    NOT NULL,
    [Cmp_ID]                      NUMERIC (18)    NOT NULL,
    [Loan_App_ID]                 NUMERIC (18)    NULL,
    [Emp_ID]                      NUMERIC (18)    NOT NULL,
    [Loan_ID]                     NUMERIC (18)    NOT NULL,
    [Loan_Apr_Date]               DATETIME        NOT NULL,
    [Loan_Apr_Code]               VARCHAR (20)    NOT NULL,
    [Loan_Apr_Amount]             NUMERIC (18)    NOT NULL,
    [Loan_Apr_No_of_Installment]  NUMERIC (18)    NOT NULL,
    [Loan_Apr_Installment_Amount] NUMERIC (22, 2) NOT NULL,
    [Loan_Apr_Intrest_Type]       VARCHAR (20)    NOT NULL,
    [Loan_Apr_Intrest_Per]        NUMERIC (18, 4) CONSTRAINT [DF_T0120_LOAN_APPROVAL_Loan_Apr_Intrest_Per] DEFAULT ((0)) NOT NULL,
    [Loan_Apr_Intrest_Amount]     NUMERIC (22, 2) NOT NULL,
    [Loan_Apr_Deduct_From_Sal]    NUMERIC (18)    NOT NULL,
    [Loan_Apr_Pending_Amount]     NUMERIC (22, 2) NOT NULL,
    [Loan_Apr_By]                 VARCHAR (100)   NOT NULL,
    [Loan_Apr_Payment_Date]       DATETIME        NULL,
    [Loan_Apr_Payment_Type]       VARCHAR (20)    NOT NULL,
    [Bank_ID]                     NUMERIC (18)    NULL,
    [Loan_Apr_Cheque_No]          VARCHAR (10)    NOT NULL,
    [Loan_Apr_Status]             CHAR (1)        NULL,
    [Loan_Number]                 VARCHAR (50)    NULL,
    [Deduction_Type]              VARCHAR (20)    NULL,
    [Guarantor_Emp_ID]            NUMERIC (18)    NULL,
    [Installment_Start_Date]      DATETIME        NULL,
    [Loan_Approval_Remarks]       VARCHAR (250)   NULL,
    [Subsidy_Recover_Perc]        NUMERIC (18, 2) CONSTRAINT [DF_T0120_LOAN_APPROVAL_Subsidy_Recover_Perc] DEFAULT ((0)) NOT NULL,
    [Attachment_Path]             NVARCHAR (MAX)  NULL,
    [Actual_subsidy_start_date]   DATETIME        NULL,
    [Opening_subsidy_amount]      NUMERIC (18, 2) CONSTRAINT [DF_T0120_LOAN_APPROVAL_Opening_subsidy_amount] DEFAULT ((0)) NOT NULL,
    [No_of_Inst_Loan_Amt]         NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Total_Loan_Int_Amount]       NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Loan_Int_Installment_Amount] NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Loan_Apr_Pending_Int_Amount] NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Paid_Amount]                 NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [No_of_Installment_Paid]      NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Calculated_Interest_Amount]  NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [CF_Loan_Amt]                 NUMERIC (18)    NULL,
    [CF_Loan_Apr_ID]              NUMERIC (18)    NULL,
    [Guarantor_Emp_ID2]           NUMERIC (18)    NULL,
    [SubSidy_Amount]              NUMERIC (18, 2) CONSTRAINT [DF_T0120_LOAN_APPROVAL_SubSidy_Amount] DEFAULT ((0)) NOT NULL,
    [AD_ID]                       NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0120_LOAN_APPROVAL] PRIMARY KEY CLUSTERED ([Loan_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_LOAN_APPROVAL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_LOAN_APPROVAL_T0040_BANK_MASTER] FOREIGN KEY ([Bank_ID]) REFERENCES [dbo].[T0040_BANK_MASTER] ([Bank_ID]),
    CONSTRAINT [FK_T0120_LOAN_APPROVAL_T0040_LOAN_MASTER] FOREIGN KEY ([Loan_ID]) REFERENCES [dbo].[T0040_LOAN_MASTER] ([Loan_ID]),
    CONSTRAINT [FK_T0120_LOAN_APPROVAL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0120_LOAN_APPROVAL_LeaveAppId_EmpId_LoanId]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_App_ID] ASC, [Emp_ID] ASC, [Loan_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0120_LOAN_APPROVAL_10_898102240__K4_K1_K2_K15_K21_K14_K5_6_8_9_10_11_12_13_23_27_36]
    ON [dbo].[T0120_LOAN_APPROVAL]([Emp_ID] ASC, [Loan_Apr_ID] ASC, [Cmp_ID] ASC, [Loan_Apr_Pending_Amount] ASC, [Loan_Apr_Status] ASC, [Loan_Apr_Deduct_From_Sal] ASC, [Loan_ID] ASC)
    INCLUDE([Loan_Apr_Date], [Loan_Apr_Amount], [Loan_Apr_No_of_Installment], [Loan_Apr_Installment_Amount], [Loan_Apr_Intrest_Type], [Loan_Apr_Intrest_Per], [Loan_Apr_Intrest_Amount], [Deduction_Type], [Subsidy_Recover_Perc], [Paid_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_898102240_21_2_4]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_Status], [Cmp_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_898102240_5_1_2_4_15_21]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_ID], [Loan_Apr_ID], [Cmp_ID], [Emp_ID], [Loan_Apr_Pending_Amount], [Loan_Apr_Status]);


GO
CREATE STATISTICS [_dta_stat_898102240_5_4_2_15_21]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_ID], [Emp_ID], [Cmp_ID], [Loan_Apr_Pending_Amount], [Loan_Apr_Status]);


GO
CREATE STATISTICS [_dta_stat_898102240_2_4_15_21]
    ON [dbo].[T0120_LOAN_APPROVAL]([Cmp_ID], [Emp_ID], [Loan_Apr_Pending_Amount], [Loan_Apr_Status]);


GO
CREATE STATISTICS [_dta_stat_898102240_1_4_2_15_21_14]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_ID], [Emp_ID], [Cmp_ID], [Loan_Apr_Pending_Amount], [Loan_Apr_Status], [Loan_Apr_Deduct_From_Sal]);


GO
CREATE STATISTICS [_dta_stat_898102240_15_2]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_Pending_Amount], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_898102240_21_1_4_5_2]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_Status], [Loan_Apr_ID], [Emp_ID], [Loan_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_898102240_4_1_5]
    ON [dbo].[T0120_LOAN_APPROVAL]([Emp_ID], [Loan_Apr_ID], [Loan_ID]);


GO
CREATE STATISTICS [_dta_stat_898102240_5_2]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_898102240_14_1_4_5_2_15]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_Deduct_From_Sal], [Loan_Apr_ID], [Emp_ID], [Loan_ID], [Cmp_ID], [Loan_Apr_Pending_Amount]);


GO
CREATE STATISTICS [_dta_stat_898102240_15_1_4_5]
    ON [dbo].[T0120_LOAN_APPROVAL]([Loan_Apr_Pending_Amount], [Loan_Apr_ID], [Emp_ID], [Loan_ID]);


GO


CREATE TRIGGER [DBO].[Tri_T0120_LOAN_APPROVAL]
ON [dbo].[T0120_LOAN_APPROVAL] 
FOR INSERT,Delete
AS
	

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric

	declare @Loan_Tran_ID	numeric
	declare @Loan_Id		numeric
	declare @Loan_Issue		numeric

	declare @Last_Closing		numeric
	Declare @Loan_apr_STatus	varchar(1)
		
		
	select @Loan_Tran_ID = Isnull(Max(Loan_Tran_ID),0)  +1 From T0140_LOAN_TRANSACTION
	
	

	IF  update(Loan_Apr_ID) 
		begin
			
			Select @cmp_ID = cmp_ID,@emp_id = Emp_ID ,@Loan_Id = ins.Loan_Id ,@Loan_Issue = ins.Loan_Apr_Amount,@for_Date = loan_apr_Date
				   ,@Loan_apr_STatus = Isnull(Loan_apr_STatus,'A')	   	 
			From inserted ins	

			if @Loan_apr_STatus ='A' 
				Begin
					if exists(select 1 from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  
						and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
						begin
							select * from T0140_LOAN_TRANSACTION where for_date = @For_date and loan_Id = @loan_Id  
							and Cmp_ID = @Cmp_ID and emp_id = @Emp_id
							
								update T0140_LOAN_TRANSACTION set Loan_Issue = Loan_Issue + @Loan_Issue
									,Loan_Closing = Loan_Closing + @Loan_Issue	
								where Loan_Id = @Loan_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
									and emp_Id = @emp_Id
								
								update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Issue
									,Loan_Closing = Loan_Closing + @Loan_Issue	
								where Loan_Id = @Loan_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
									and emp_Id = @emp_Id
						end
					else
						Begin	    
    						select @Last_Closing = isnull(Loan_Closing,0) from T0140_LOAN_TRANSACTION
    							where for_date = (select max(for_date) from T0140_LOAN_TRANSACTION 
    									where for_date < @For_date
    								and loan_Id = @loan_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
    								and cmp_ID = @cmp_ID
    								and loan_id = @loan_Id  and emp_id = @emp_Id
			
							if @Last_Closing is null 
								set  @Last_Closing = 0
							
							insert T0140_LOAN_TRANSACTION(Loan_Tran_ID,emp_id,Loan_Id,cmp_ID,For_Date,Loan_Opening,Loan_Issue,
								Loan_Closing,Loan_Return)
							values(@Loan_Tran_ID,@emp_id,@loan_Id,@cmp_ID,@for_Date,@last_closing,@Loan_Issue
								,@last_closing + @Loan_Issue,0)												    		
						
							update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening + @Loan_Issue
								,Loan_Closing = Loan_Closing + @Loan_Issue	
							where Loan_Id = @Loan_Id and for_date > @For_Date and cmp_ID = @cmp_ID
								and emp_Id = @emp_Id

    					end	
	    		End	    	
	    End
	else
		begin

		 	declare curDel cursor for
				select Del.Cmp_ID ,del.Emp_ID ,del.loan_Id,del.Loan_apr_Amount ,loan_apr_Date,isnull(Loan_apr_STatus,'A') from deleted del
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID,@Loan_Id , @Loan_Issue ,@for_Date ,@Loan_apr_STatus
			while @@fetch_status = 0
			begin 
				if @Loan_apr_STatus ='A'
					Begin
						update T0140_LOAN_TRANSACTION set Loan_Issue = Loan_Issue - @Loan_Issue 
							,Loan_Closing = Loan_Closing - @Loan_Issue
						where loan_id = @loan_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
								
						update T0140_LOAN_TRANSACTION set Loan_Opening = Loan_Opening - @Loan_Issue
							,Loan_Closing = Loan_Closing - @Loan_Issue
						where loan_id = @loan_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
					End
				fetch next from curDel into @Cmp_ID, @Emp_ID,@Loan_Id , @Loan_Issue ,@for_Date ,@Loan_apr_STatus
			end				
			close curDel
			deallocate curDel
		end

/*********************************************
**************FOR GPF LOAN********************
*********************************************/
DECLARE @GPF_TRAN_ID	NUMERIC;
DECLARE @GPF_DEBIT		NUMERIC(18,4);

IF EXISTS(SELECT 1 FROM INSERTED I INNER JOIN T0040_LOAN_MASTER L ON I.Cmp_ID=L.Cmp_ID AND I.Loan_ID=L.Loan_ID
			WHERE L.Is_GPF = 1)
	BEGIN
		SELECT	@Cmp_ID=INS.Cmp_ID,@Emp_Id=INS.Emp_ID,@Loan_Id=INS.Loan_ID,@GPF_DEBIT=INS.Loan_Apr_Amount,
					@For_Date=INS.Loan_Apr_Date,@Loan_apr_STatus=ISNULL(INS.Loan_apr_Status,'A')	   	 
		FROM	INSERTED INS
		
		
		SELECT	@GPF_TRAN_ID = TRAN_ID 
		FROM	T0140_EMP_GPF_TRANSACTION GPF
		WHERE	GPF.CMP_ID=@Cmp_ID AND GPF.EMP_ID=@Emp_Id AND GPF.FOR_DATE = @For_Date
				AND GPF.GPF_DEBIT > 0 
		
		IF @GPF_TRAN_ID  IS NOT NULL
			BEGIN
				UPDATE	T0140_EMP_GPF_TRANSACTION 
				SET		GPF_DEBIT = @GPF_DEBIT
				WHERE	TRAN_ID=@GPF_TRAN_ID
			END
		ELSE
			BEGIN
				SET @GPF_TRAN_ID = ISNULL((SELECT MAX(TRAN_ID) FROM T0140_EMP_GPF_TRANSACTION), 0) +1
				
				INSERT	INTO T0140_EMP_GPF_TRANSACTION 
					(CMP_ID,TRAN_ID,EMP_ID,SAL_TRAN_ID,FOR_DATE,GPF_OPENING,GPF_CREDIT,GPF_DEBIT,GPF_CLOSING,SYSTEM_DATE)
				VALUES
					(@Cmp_ID,@GPF_TRAN_ID,@Emp_Id,0,@For_Date, 0,0,@GPF_DEBIT,0, GETDATE())
			END
		
		EXEC dbo.P0140_UPDATE_GPF_CLOSING @CMP_ID, @Emp_Id, @For_Date	
	END
ELSE IF EXISTS(SELECT 1 FROM DELETED D INNER JOIN T0040_LOAN_MASTER L ON D.Cmp_ID=L.Cmp_ID AND D.Loan_ID=L.Loan_ID
			WHERE L.Is_GPF = 1)
	BEGIN
		SELECT	@Cmp_ID=D.Cmp_ID,@Emp_Id=D.Emp_ID,@For_Date=D.Loan_Apr_Date
		FROM	DELETED D
		
		SELECT	@GPF_TRAN_ID = TRAN_ID 
		FROM	T0140_EMP_GPF_TRANSACTION GPF
		WHERE	GPF.CMP_ID=@Cmp_ID AND GPF.EMP_ID=@Emp_Id AND GPF.FOR_DATE = @For_Date
				AND GPF.GPF_DEBIT > 0 
		
		IF @GPF_TRAN_ID IS NOT NULL 
			DELETE FROM T0140_EMP_GPF_TRANSACTION WHERE TRAN_ID=@GPF_TRAN_ID
	END
/*************END FOR GPF LOAN***************/
