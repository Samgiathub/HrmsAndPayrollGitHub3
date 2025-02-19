CREATE TABLE [dbo].[T0120_RC_Approval] (
    [RC_APR_ID]                NUMERIC (18)    NOT NULL,
    [Cmp_ID]                   NUMERIC (18)    NULL,
    [RC_App_ID]                NUMERIC (18)    NULL,
    [Emp_ID]                   NUMERIC (18)    NULL,
    [RC_ID]                    NUMERIC (18)    NULL,
    [Apr_Date]                 DATETIME        NULL,
    [Apr_Amount]               NUMERIC (18, 2) NULL,
    [Taxable_Exemption_Amount] NUMERIC (18, 2) NULL,
    [APr_Comments]             NVARCHAR (MAX)  NULL,
    [APR_Status]               TINYINT         NULL,
    [RC_Apr_Effect_In_Salary]  NUMERIC (18)    NULL,
    [RC_Apr_Cheque_No]         VARCHAR (10)    NULL,
    [Payment_Mode]             VARCHAR (20)    NULL,
    [CreateBy]                 INT             NOT NULL,
    [DateCreated]              DATETIME        NOT NULL,
    [ModifyBy]                 INT             NULL,
    [ModifyDate]               DATETIME        NULL,
    [S_emp_ID]                 NUMERIC (18)    NULL,
    [Payment_date]             DATETIME        NULL,
    [Direct_Approval]          TINYINT         DEFAULT ((0)) NOT NULL,
    [Reim_Quar_ID]             NUMERIC (5)     DEFAULT ((0)) NOT NULL,
    [Quarter_Name]             VARCHAR (50)    NULL,
    CONSTRAINT [PK_T0120_RC_Approval] PRIMARY KEY CLUSTERED ([RC_APR_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_RC_Approval_T0120_RC_Approval] FOREIGN KEY ([RC_APR_ID]) REFERENCES [dbo].[T0120_RC_Approval] ([RC_APR_ID])
);


GO



CREATE TRIGGER [DBO].[Tri_T0120_RC_APPROVAL]
ON [dbo].[T0120_RC_Approval]
FOR  INSERT,  DELETE 
AS

    declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric
	declare @Payment_type	varchar(255)
	declare @Riem_Tran_ID	numeric
	declare @Rc_Id		numeric
	declare @Reim_Issue		numeric(18,2)
	declare @Last_Closing		numeric(18,2)
	Declare @Reim_Apr_Status	varchar(1)
	Declare @Reim_apr_ID numeric(18,2)
	Declare @Effect_In_salary numeric
	Declare @Taxable_amount numeric(18,2)

	select @Riem_Tran_ID = Isnull(Max(Reim_Tran_ID),0)  +1 From T0140_ReimClaim_Transacation

	IF  UPDATE(RC_Apr_ID) 
		BEGIN
		
			select @cmp_ID = cmp_ID,@emp_id = Emp_ID ,@Rc_Id = ins.RC_ID ,@Reim_Issue = ins.Apr_Amount,@Taxable_amount=ins.Taxable_Exemption_Amount ,@for_Date = ins.Apr_Date
					,@Reim_Apr_Status = ins.APR_Status,@Payment_type =ins.Payment_Mode,@Reim_apr_ID = ins.RC_APR_ID,
					@Effect_In_salary = isnull(ins.RC_Apr_Effect_In_Salary,0)
					from inserted ins	
			
			IF (@payment_type='Cash' or @payment_type='Cheque' or @payment_type='Bank Transfer') and @Effect_In_salary = 0
				BEGIN
					SET @Reim_Issue = @Reim_Issue +ISNULL(@Taxable_amount,0)
					
					IF @Reim_Apr_Status = 1 
						BEGIN	
							
							IF EXISTS(SELECT 1 FROM T0140_ReimClaim_Transacation where for_date = @For_date and RC_ID = @Rc_Id  and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
								BEGIN
									--update T0140_ReimClaim_Transacation set Reim_Credit = Reim_Credit + @Reim_Issue
									--	,Reim_Closing = Reim_Closing + @Reim_Issue, RC_apr_ID=@Reim_apr_ID	
									--where RC_ID = @Rc_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
									--	and emp_Id = @emp_Id
									--update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening + @Reim_Issue
									--	,Reim_Closing = Reim_Closing + @Reim_Issue	
									--where RC_ID = @Rc_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
									--	and emp_Id = @emp_Id
									
									update T0140_ReimClaim_Transacation set Reim_Debit = Reim_Debit + @Reim_Issue
										,Reim_Closing = Reim_Closing - @Reim_Issue, RC_apr_ID=@Reim_apr_ID	
									where RC_ID = @Rc_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
									
									update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening - @Reim_Issue
										,Reim_Closing = Reim_Closing - @Reim_Issue	
									where RC_ID = @Rc_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
									
									IF NOT  EXISTS(SELECT 1 FROM T0210_Monthly_Reim_Detail WHERE EMp_id=@eMP_id AND CMP_id=@Cmp_ID AND for_Date=@For_Date and RC_ID = @Rc_Id and RC_apr_ID = @Reim_apr_ID)
										BEGIN
											INSERT INTO T0210_Monthly_Reim_Detail 
												(Cmp_ID,Emp_ID,RC_ID,RC_apr_ID,Temp_Sal_tran_ID,Sal_tran_ID,for_Date,Amount,Taxable,Tax_Free_amount)
											VALUES	
												(@Cmp_ID,@Emp_Id,@Rc_Id,@Reim_apr_ID,NULL,NULL,@For_Date,0,@Taxable_amount,@Reim_Issue-@Taxable_amount)

										END
								
								END
							ELSE
								BEGIN
					
    								select @Last_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation
    									where for_date = (select max(for_date) from T0140_ReimClaim_Transacation 
    														where for_date < @For_date and RC_ID = @Rc_ID and 
    														cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
    										and cmp_ID = @cmp_ID
    										and RC_ID = @RC_ID  and emp_id = @emp_Id
					
									if @Last_Closing is null 
										set  @Last_Closing = 0
									
										--insert T0140_ReimClaim_Transacation(Reim_Tran_ID,emp_id,RC_ID,cmp_ID,For_Date,Reim_Opening,Reim_Credit,
										--Reim_Closing,Reim_Debit, Rc_apr_ID)
										--values(@Riem_Tran_ID,@emp_id,@RC_ID,@cmp_ID,@for_Date,@last_closing,0
										--	,@Last_Closing  - @Reim_Issue,@Reim_Issue, @Reim_apr_ID)	
												
											
										--	update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening + @Reim_Issue
										--	,Reim_Closing = Reim_Closing + @Reim_Issue	
										--where RC_ID = @RC_ID and for_date > @For_Date and cmp_ID = @cmp_ID
										--	and emp_Id = @emp_Id
										
									insert T0140_ReimClaim_Transacation(Reim_Tran_ID,emp_id,RC_ID,cmp_ID,For_Date,Reim_Opening,Reim_Credit,
											Reim_Closing,Reim_Debit, Rc_apr_ID)
									values(@Riem_Tran_ID,@emp_id,@RC_ID,@cmp_ID,@for_Date,@last_closing,0
											,@Last_Closing  - @Reim_Issue,@Reim_Issue, @Reim_apr_ID)	
									
									update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening - @Reim_Issue
										,Reim_Closing = Reim_Closing - @Reim_Issue	
									where RC_ID = @RC_ID and for_date > @For_Date and cmp_ID = @cmp_ID
										and emp_Id = @emp_Id
									
									IF not  EXISTS(SELECT 1 FROM T0210_Monthly_Reim_Detail WHERE EMp_id=@eMP_id AND CMP_id=@Cmp_ID AND for_Date=@For_Date and RC_ID = @Rc_Id and RC_apr_ID = @Reim_apr_ID)
										BEGIN
											INSERT INTO T0210_Monthly_Reim_Detail 
												(Cmp_ID,Emp_ID,RC_ID,RC_apr_ID,Temp_Sal_tran_ID,Sal_tran_ID,for_Date,Amount,Taxable,Tax_Free_amount)
											VALUES
												(@Cmp_ID,@Emp_Id,@Rc_Id,@Reim_apr_ID,NULL,NULL,@For_Date,0,@Taxable_amount,@Reim_Issue-@Taxable_amount)
										END
								
								----else
								----begin
								
								----insert T0140_ReimClaim_Transacation(Reim_Tran_ID,emp_id,RC_ID,cmp_ID,For_Date,Reim_Opening,Reim_Credit,
								----	Reim_Closing,Reim_Debit,Rc_apr_ID)
								----values(@Riem_Tran_ID,@emp_id,@RC_ID,@cmp_ID,@for_Date,@last_closing,@Reim_Issue
								----	,@Last_Closing + @Reim_Issue,0,@Reim_apr_ID)												    		
								
								
								----end
								
    						END
    						
	    				END
	    		END
	    	
	    END
	ELSE
		BEGIN
			declare @RC_Apr_ID as numeric(18,2)
		 	declare curDel cursor for
				select Del.Cmp_ID ,del.Emp_ID ,del.RC_ID,del.Apr_Amount,del.Taxable_Exemption_Amount ,del.Apr_Date ,del.APR_Status, del.RC_APR_ID,del.Payment_Mode,isnull(del.RC_Apr_Effect_In_Salary,0) from deleted del
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID,@RC_ID,@Reim_Issue,@Taxable_amount,@for_Date,@Reim_Apr_Status,@RC_Apr_ID,@Payment_type,@Effect_In_salary
			while @@fetch_status = 0
			begin
			
				if (@payment_type='Cash' or @payment_type='Cheque' or @payment_type='Bank Transfer') and @Effect_In_salary = 0
					BEGIN
						if @Reim_Apr_Status = 1
							begin
								--update T0140_ReimClaim_Transacation set Reim_Debit = 0
								--	,Reim_Closing = Reim_Closing + @Reim_Issue
								--where RC_ID = @RC_ID and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
								
								--update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening + @Reim_Issue
								--	,Reim_Closing = Reim_Closing + @Reim_Issue
								--where RC_ID = @RC_ID and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
								
								--if  @RC_Apr_ID > 0
								--begin
								--	delete from T0140_ReimClaim_Transacation where RC_apr_ID =@RC_Apr_ID
								--end
								
								set @Reim_Issue = @Reim_Issue +ISNULL(@Taxable_amount,0)
								
								update T0140_ReimClaim_Transacation set 
									 Reim_Debit = Reim_Debit - @Reim_Issue
									,Reim_Closing = Reim_Closing + @Reim_Issue
								where RC_ID = @RC_ID and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
								
								update T0140_ReimClaim_Transacation set 
									 Reim_Opening = Reim_Opening + @Reim_Issue
									,Reim_Closing = Reim_Closing + @Reim_Issue
								where RC_ID = @RC_ID and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
								
								if ((select Reim_Debit from T0140_ReimClaim_Transacation 
										where RC_ID = @RC_ID and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID) = 0)
								begin
									delete from T0140_ReimClaim_Transacation 
											where  RC_ID = @RC_ID and emp_id = @emp_id and 
																  for_date = @for_date and cmp_ID = @cmp_ID
								end
								
							IF EXISTS(SELECT 1 FROM T0210_Monthly_Reim_Detail WHERE Emp_ID=@eMP_id AND CMP_id=@Cmp_ID AND for_Date=@For_Date and RC_ID = @Rc_Id and RC_apr_ID = @Reim_apr_ID)
								BEGIN
										delete from  T0210_Monthly_Reim_Detail  
										where RC_ID = @RC_ID and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID and RC_apr_ID = @Reim_apr_ID
								END
								
						END
					END
				
				fetch next from curDel into @Cmp_ID,@Emp_ID,@RC_ID,@Reim_Issue,@Taxable_amount,@for_Date,@Reim_Apr_Status,@RC_Apr_ID,@Payment_type,@Effect_In_salary--- this changed by nikunj at 19-feb-2010
				
			end				
			close curDel
			deallocate curDel
		END



