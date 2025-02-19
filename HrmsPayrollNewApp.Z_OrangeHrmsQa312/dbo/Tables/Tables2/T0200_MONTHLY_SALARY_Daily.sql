CREATE TABLE [dbo].[T0200_MONTHLY_SALARY_Daily] (
    [Sal_Tran_ID]              NUMERIC (18)    NOT NULL,
    [Sal_Receipt_No]           NUMERIC (18)    NOT NULL,
    [Emp_ID]                   NUMERIC (18)    NOT NULL,
    [Cmp_ID]                   NUMERIC (18)    NOT NULL,
    [Increment_ID]             NUMERIC (18)    NOT NULL,
    [Month_St_Date]            DATETIME        NOT NULL,
    [Month_End_Date]           DATETIME        NOT NULL,
    [Sal_Generate_Date]        DATETIME        NOT NULL,
    [Sal_Cal_Days]             NUMERIC (18, 1) NOT NULL,
    [Present_Days]             NUMERIC (18, 1) NULL,
    [Absent_Days]              NUMERIC (18, 1) NULL,
    [Holiday_Days]             NUMERIC (18, 1) NULL,
    [Weekoff_Days]             NUMERIC (18, 1) NULL,
    [Cancel_Holiday]           NUMERIC (18, 1) NULL,
    [Cancel_Weekoff]           NUMERIC (18, 1) NULL,
    [Working_Days]             NUMERIC (18, 1) NULL,
    [Outof_Days]               NUMERIC (18, 1) NULL,
    [Total_Leave_Days]         NUMERIC (18, 1) NULL,
    [Paid_Leave_Days]          NUMERIC (18, 1) NULL,
    [Actual_Working_Hours]     VARCHAR (20)    NULL,
    [Working_Hours]            VARCHAR (20)    NULL,
    [Outof_Hours]              VARCHAR (20)    NULL,
    [OT_Hours]                 NUMERIC (18, 1) NULL,
    [Total_Hours]              VARCHAR (20)    NULL,
    [Shift_Day_Sec]            NUMERIC (18)    NULL,
    [Shift_Day_Hour]           VARCHAR (20)    NULL,
    [Basic_Salary]             NUMERIC (18, 2) NULL,
    [Day_Salary]               NUMERIC (18, 5) NULL,
    [Hour_Salary]              NUMERIC (18, 5) NULL,
    [Salary_Amount]            NUMERIC (18, 2) NULL,
    [Allow_Amount]             NUMERIC (18, 2) NULL,
    [OT_Amount]                NUMERIC (18, 2) NULL,
    [Other_Allow_Amount]       NUMERIC (18, 2) NULL,
    [Gross_Salary]             NUMERIC (18, 2) NULL,
    [Dedu_Amount]              NUMERIC (18, 2) NULL,
    [Loan_Amount]              NUMERIC (18, 2) NULL,
    [Loan_Intrest_Amount]      NUMERIC (18, 2) NULL,
    [Advance_Amount]           NUMERIC (18, 2) NULL,
    [Other_Dedu_Amount]        NUMERIC (18, 2) NULL,
    [Total_Dedu_Amount]        NUMERIC (18, 2) NULL,
    [Due_Loan_Amount]          NUMERIC (18, 2) NULL,
    [Net_Amount]               NUMERIC (18, 2) NULL,
    [Actually_Gross_Salary]    NUMERIC (18, 2) NULL,
    [PT_Amount]                NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_PT_Amount] DEFAULT ((0)) NULL,
    [PT_Calculated_Amount]     NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_PT_Calculated_Amount] DEFAULT ((0)) NULL,
    [Total_Claim_Amount]       NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Total_Claim_Amount] DEFAULT ((0)) NULL,
    [M_OT_Hours]               NUMERIC (18, 1) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_M_OT_Hours] DEFAULT ((0)) NULL,
    [M_Adv_Amount]             NUMERIC (18)    NULL,
    [M_Loan_Amount]            NUMERIC (18)    NULL,
    [M_IT_Tax]                 NUMERIC (18)    NULL,
    [LWF_Amount]               NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_LWF_Amount] DEFAULT ((0)) NULL,
    [Revenue_Amount]           NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Revenue_Amount] DEFAULT ((0)) NULL,
    [PT_F_T_Limit]             VARCHAR (20)    NULL,
    [Settelement_Amount]       NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Settelement_Amount] DEFAULT ((0)) NULL,
    [Settelement_Comments]     VARCHAR (250)   NULL,
    [Leave_Salary_Amount]      NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Leave_Salary_Amount] DEFAULT ((0)) NULL,
    [Leave_Salary_Comments]    VARCHAR (250)   NULL,
    [Late_Sec]                 NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Late_Sec] DEFAULT ((0)) NULL,
    [Late_Dedu_Amount]         NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Late_Dedu_Amount] DEFAULT ((0)) NULL,
    [Late_Extra_Dedu_Amount]   NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Late_Extra_Dedu_Amount] DEFAULT ((0)) NULL,
    [Late_Days]                NUMERIC (5, 1)  CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Late_Days] DEFAULT ((0)) NULL,
    [Short_Fall_Days]          NUMERIC (5, 1)  CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Short_Fall_Days] DEFAULT ((0)) NULL,
    [Short_Fall_Dedu_Amount]   NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Shoft_Fall_Dedu_Amount] DEFAULT ((0)) NULL,
    [Gratuity_Amount]          NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Gratuity_Amount] DEFAULT ((0)) NULL,
    [Is_FNF]                   TINYINT         CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Is_FNF] DEFAULT ((0)) NULL,
    [Bonus_Amount]             NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Bonus_Amount] DEFAULT ((0)) NULL,
    [Incentive_Amount]         NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Incentive_Amount] DEFAULT ((0)) NULL,
    [Trav_Earn_Amount]         NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Trav_Earn_Amount] DEFAULT ((0)) NULL,
    [Cust_Res_Earn_Amount]     NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Cust_Res_Earn_Amount] DEFAULT ((0)) NULL,
    [Trav_Rec_Amount]          NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Trav_Rec_Amount] DEFAULT ((0)) NULL,
    [Mobile_Rec_Amount]        NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Mobile_Rec_Amount] DEFAULT ((0)) NULL,
    [Cust_Res_Rec_Amount]      NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Cust_Res_Rec_Amount] DEFAULT ((0)) NULL,
    [Uniform_Rec_Amount]       NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Uniform_Rec_Amount] DEFAULT ((0)) NULL,
    [I_Card_Rec_Amount]        NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_I_Card_Rec_Amount] DEFAULT ((0)) NULL,
    [Excess_Salary_Rec_Amount] NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Excess_Salary_Rec_Amount] DEFAULT ((0)) NULL,
    [Salary_Status]            VARCHAR (20)    NULL,
    [Pre_Month_Net_Salary]     NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Daily_Pre_Month_Net_Salary] DEFAULT ((0)) NULL,
    [IT_M_ED_Cess_Amount]      NUMERIC (18, 2) NULL,
    [IT_M_Surcharge_Amount]    NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0200_MONTHLY_SALARY_Daily] PRIMARY KEY CLUSTERED ([Sal_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_Daily_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_Daily_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_Daily_T0095_INCREMENT] FOREIGN KEY ([Increment_ID]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID])
);


GO





CREATE TRIGGER Tri_T0200_MONTHLY_SALARY_Daily_DELETE
ON dbo.T0200_MONTHLY_SALARY_Daily 
FOR DELETE 
AS
	
	declare @Emp_Id as numeric 
	declare @Cmp_ID as numeric
	declare @For_Date as datetime
	declare @Amount as numeric
	declare @Last_Adv_Closing as numeric


	select @Emp_Id = del.Emp_Id, @Cmp_ID = del.Cmp_ID ,@For_Date = del.Month_End_Date
			,@Amount = del.Advance_aMOUNT from deleted del	

	update T0140_ADVANCE_TRANSACTION set Adv_Return = Adv_Return - @amount 
		,Adv_Closing = Adv_Closing + @amount
	where  emp_id = @emp_id and for_date = @for_date and Cmp_ID = @Cmp_ID	
			
	update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening + @amount
		,Adv_Closing = Adv_Closing + @amount
	where  emp_id = @emp_id and for_date > @for_date and Cmp_ID = @Cmp_ID

	



GO





CREATE TRIGGER Tri_T0200_MONTHLY_SALARY_Daily_UPDATE 
ON dbo.T0200_MONTHLY_SALARY_Daily 
FOR UPDATE

AS
	
	declare @Emp_Id as numeric 
	declare @Cmp_ID as numeric
	declare @For_Date as datetime
	declare @Amount as numeric
	declare @Last_Adv_Closing as numeric
	declare @Old_Amount as numeric
	Declare @Adv_Tran_ID numeric 

	Select @Adv_Tran_ID = Isnull(max(Adv_Tran_ID),0) + 1 From T0140_Advance_Transaction 


	select @Emp_Id = ins.Emp_Id, @Cmp_ID = ins.Cmp_ID ,@For_Date = ins.Month_end_date
			,@Amount = isnull(ins.Advance_Amount,0) from inserted ins	
	
	select @Old_Amount = isnull(del.Advance_Amount,0) from deleted del	

	
		if exists(select * from T0140_ADVANCE_TRANSACTION where for_date = @For_date and emp_id = @emp_Id  
			and Cmp_ID = @Cmp_ID)
			begin
				update T0140_ADVANCE_TRANSACTION set Adv_Return =  @Amount
					,Adv_Closing = Adv_Closing - (@Amount - @Old_Amount)	
				where  for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
				

				update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening + @Amount
					,Adv_Closing = Adv_Closing - (@Amount - @Old_Amount)	
				where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
			end	

		else
			begin
		    	select @Last_Adv_Closing = isnull(Adv_Closing,0) from T0140_ADVANCE_TRANSACTION
		    		where for_date = (select max(for_date) from T0140_ADVANCE_TRANSACTION 
		    				where for_date < @For_date
		    			 and Cmp_ID = @Cmp_ID and emp_id = @emp_Id ) 
		    			and Cmp_ID = @Cmp_ID and emp_id = @emp_Id

				if @Last_Adv_Closing is null 
					set  @Last_Adv_Closing = 0

				insert T0140_ADVANCE_TRANSACTION(Adv_Tran_ID,emp_id,Cmp_ID,For_Date,Adv_Opening,Adv_Return,Adv_Closing,Adv_Issue)
				values(@Adv_Tran_ID,@emp_id,@Cmp_ID,@for_Date,@last_Adv_Closing,@Amount,@last_Adv_Closing - (@Amount - @Old_Amount),0)												    	


				update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening - @Amount
					,Adv_Closing = Adv_Closing - (@Amount - @Old_Amount)	
				where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id

			end

	



GO





CREATE TRIGGER Tri_T0200_MONTHLY_SALARY_Daily_INSERT
ON dbo.T0200_MONTHLY_SALARY_Daily 
FOR  INSERT
AS
	
declare @Emp_Id as numeric 
declare @Cmp_ID as numeric
declare @For_Date as datetime
declare @Amount as numeric
declare @Last_Adv_Closing as numeric
Declare @Adv_Tran_ID numeric 

	Select @Adv_Tran_ID = Isnull(max(Adv_Tran_ID),0) + 1 From T0140_Advance_Transaction 
	

	select @Emp_Id = ins.Emp_Id, @Cmp_ID = ins.Cmp_ID ,@For_Date = ins.Month_End_Date
			,@Amount = ins.Advance_amount from inserted ins	
	if exists(select * from T0140_ADVANCE_TRANSACTION where for_date = @For_date and emp_id = @emp_Id  
		and Cmp_ID = @Cmp_ID)
		begin
			update T0140_ADVANCE_TRANSACTION set Adv_Return = Adv_Return + @Amount
				,Adv_Closing = Adv_Closing - @Amount	
			where  for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
			
			update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening - @Amount
				,Adv_Closing = Adv_Closing - @Amount	
			where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
			
		end	
		else
			begin
		    	select @Last_Adv_Closing = isnull(Adv_Closing,0) from T0140_ADVANCE_TRANSACTION
		    		where for_date = (select max(for_date) from T0140_ADVANCE_TRANSACTION 
		    				where for_date < @For_date
		    			 and Cmp_ID = @Cmp_ID and emp_id = @emp_Id ) 
		    			and Cmp_ID = @Cmp_ID and emp_id = @emp_Id

				if @Last_Adv_Closing is null 
					set  @Last_Adv_Closing = 0

				insert T0140_ADVANCE_TRANSACTION(Adv_Tran_ID,emp_id,Cmp_ID,For_Date,Adv_Opening,Adv_Return,Adv_Closing,Adv_Issue)
				values(@Adv_Tran_ID,@emp_id,@Cmp_ID,@for_Date,@last_Adv_Closing,@Amount,@last_Adv_Closing - @Amount,0)												    	
				
				

				update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening - @Amount
					,Adv_Closing = Adv_Closing - @Amount	
				where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id

			end




