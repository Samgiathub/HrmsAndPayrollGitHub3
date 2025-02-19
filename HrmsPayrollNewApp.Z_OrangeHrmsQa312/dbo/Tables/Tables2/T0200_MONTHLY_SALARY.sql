CREATE TABLE [dbo].[T0200_MONTHLY_SALARY] (
    [Sal_Tran_ID]                   NUMERIC (18)    NOT NULL,
    [Sal_Receipt_No]                NUMERIC (18)    NOT NULL,
    [Emp_ID]                        NUMERIC (18)    NOT NULL,
    [Cmp_ID]                        NUMERIC (18)    NOT NULL,
    [Increment_ID]                  NUMERIC (18)    NOT NULL,
    [Month_St_Date]                 DATETIME        NOT NULL,
    [Month_End_Date]                DATETIME        NOT NULL,
    [Sal_Generate_Date]             DATETIME        NOT NULL,
    [Sal_Cal_Days]                  NUMERIC (18, 2) NOT NULL,
    [Present_Days]                  NUMERIC (18, 2) NULL,
    [Absent_Days]                   NUMERIC (18, 2) NULL,
    [Holiday_Days]                  NUMERIC (18, 2) NULL,
    [Weekoff_Days]                  NUMERIC (18, 2) NULL,
    [Cancel_Holiday]                NUMERIC (18, 2) NULL,
    [Cancel_Weekoff]                NUMERIC (18, 2) NULL,
    [Working_Days]                  NUMERIC (18, 2) NULL,
    [Outof_Days]                    NUMERIC (18, 2) NULL,
    [Total_Leave_Days]              NUMERIC (18, 2) NULL,
    [Paid_Leave_Days]               NUMERIC (18, 2) NULL,
    [Actual_Working_Hours]          VARCHAR (20)    NULL,
    [Working_Hours]                 VARCHAR (20)    NULL,
    [Outof_Hours]                   VARCHAR (20)    NULL,
    [OT_Hours]                      NUMERIC (18, 2) NULL,
    [Total_Hours]                   VARCHAR (20)    NULL,
    [Shift_Day_Sec]                 NUMERIC (18)    NULL,
    [Shift_Day_Hour]                VARCHAR (20)    NULL,
    [Basic_Salary]                  NUMERIC (18, 2) NULL,
    [Day_Salary]                    NUMERIC (18, 5) NULL,
    [Hour_Salary]                   NUMERIC (18, 5) NULL,
    [Salary_Amount]                 NUMERIC (18, 2) NULL,
    [Allow_Amount]                  NUMERIC (18, 2) NULL,
    [OT_Amount]                     NUMERIC (18, 2) NULL,
    [Other_Allow_Amount]            NUMERIC (18, 2) NULL,
    [Gross_Salary]                  NUMERIC (18, 2) NULL,
    [Dedu_Amount]                   NUMERIC (18, 2) NULL,
    [Loan_Amount]                   NUMERIC (18, 2) NULL,
    [Loan_Intrest_Amount]           NUMERIC (18, 2) NULL,
    [Advance_Amount]                NUMERIC (18, 2) NULL,
    [Other_Dedu_Amount]             NUMERIC (18, 2) NULL,
    [Total_Dedu_Amount]             NUMERIC (18, 2) NULL,
    [Due_Loan_Amount]               NUMERIC (18, 2) NULL,
    [Net_Amount]                    NUMERIC (18, 2) NULL,
    [Actually_Gross_Salary]         NUMERIC (18, 2) NULL,
    [PT_Amount]                     NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_PT_Amount] DEFAULT ((0)) NULL,
    [PT_Calculated_Amount]          NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_PT_Calculated_Amount] DEFAULT ((0)) NULL,
    [Total_Claim_Amount]            NUMERIC (18, 3) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Total_Claim_Amount] DEFAULT ((0)) NULL,
    [M_OT_Hours]                    NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_M_OT_Hours] DEFAULT ((0)) NULL,
    [M_Adv_Amount]                  NUMERIC (18)    NULL,
    [M_Loan_Amount]                 NUMERIC (18)    NULL,
    [M_IT_Tax]                      NUMERIC (18)    NULL,
    [LWF_Amount]                    NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_LWF_Amount] DEFAULT ((0)) NULL,
    [Revenue_Amount]                NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Revenue_Amount] DEFAULT ((0)) NULL,
    [PT_F_T_Limit]                  VARCHAR (20)    NULL,
    [Settelement_Amount]            NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Settelement_Amount] DEFAULT ((0)) NULL,
    [Settelement_Comments]          VARCHAR (250)   NULL,
    [Leave_Salary_Amount]           NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Leave_Salary_Amount] DEFAULT ((0)) NULL,
    [Leave_Salary_Comments]         VARCHAR (250)   NULL,
    [Late_Sec]                      NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Late_Sec] DEFAULT ((0)) NULL,
    [Late_Dedu_Amount]              NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Late_Dedu_Amount] DEFAULT ((0)) NULL,
    [Late_Extra_Dedu_Amount]        NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Late_Extra_Dedu_Amount] DEFAULT ((0)) NULL,
    [Late_Days]                     NUMERIC (5, 2)  CONSTRAINT [DF_T0200_MONTHLY_SALARY_Late_Days] DEFAULT ((0)) NULL,
    [Short_Fall_Days]               NUMERIC (5, 1)  CONSTRAINT [DF_T0200_MONTHLY_SALARY_Short_Fall_Days] DEFAULT ((0)) NULL,
    [Short_Fall_Dedu_Amount]        NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Shoft_Fall_Dedu_Amount] DEFAULT ((0)) NULL,
    [Gratuity_Amount]               NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Gratuity_Amount] DEFAULT ((0)) NULL,
    [Is_FNF]                        TINYINT         CONSTRAINT [DF_T0200_MONTHLY_SALARY_Is_FNF] DEFAULT ((0)) NULL,
    [Bonus_Amount]                  NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Bonus_Amount] DEFAULT ((0)) NULL,
    [Incentive_Amount]              NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Incentive_Amount] DEFAULT ((0)) NULL,
    [Trav_Earn_Amount]              NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Trav_Earn_Amount] DEFAULT ((0)) NULL,
    [Cust_Res_Earn_Amount]          NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Cust_Res_Earn_Amount] DEFAULT ((0)) NULL,
    [Trav_Rec_Amount]               NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Trav_Rec_Amount] DEFAULT ((0)) NULL,
    [Mobile_Rec_Amount]             NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Mobile_Rec_Amount] DEFAULT ((0)) NULL,
    [Cust_Res_Rec_Amount]           NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Cust_Res_Rec_Amount] DEFAULT ((0)) NULL,
    [Uniform_Rec_Amount]            NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_Uniform_Rec_Amount] DEFAULT ((0)) NULL,
    [I_Card_Rec_Amount]             NUMERIC (7)     CONSTRAINT [DF_T0200_MONTHLY_SALARY_I_Card_Rec_Amount] DEFAULT ((0)) NULL,
    [Excess_Salary_Rec_Amount]      NUMERIC (10)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Excess_Salary_Rec_Amount] DEFAULT ((0)) NULL,
    [Salary_Status]                 VARCHAR (20)    NULL,
    [Pre_Month_Net_Salary]          NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Pre_Month_Net_Salary] DEFAULT ((0)) NULL,
    [IT_M_ED_Cess_Amount]           NUMERIC (18, 2) NULL,
    [IT_M_Surcharge_Amount]         NUMERIC (18, 2) NULL,
    [Early_Sec]                     NUMERIC (18)    CONSTRAINT [DF__T0200_MON__Early__76226739] DEFAULT ((0)) NULL,
    [Early_Dedu_Amount]             NUMERIC (18)    CONSTRAINT [DF__T0200_MON__Early__77168B72] DEFAULT ((0)) NULL,
    [Early_Extra_Dedu_Amount]       NUMERIC (18)    CONSTRAINT [DF__T0200_MON__Early__780AAFAB] DEFAULT ((0)) NULL,
    [Early_Days]                    NUMERIC (5, 2)  CONSTRAINT [DF__T0200_MON__Early__78FED3E4] DEFAULT ((0)) NULL,
    [Deficit_Sec]                   NUMERIC (18)    CONSTRAINT [DF__T0200_MON__Defic__79F2F81D] DEFAULT ((0)) NULL,
    [Deficit_Dedu_Amount]           NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Defic__7AE71C56] DEFAULT ((0)) NULL,
    [Deficit_Extra_Dedu_Amount]     NUMERIC (18)    CONSTRAINT [DF__T0200_MON__Defic__7BDB408F] DEFAULT ((0)) NULL,
    [Deficit_Days]                  NUMERIC (5, 2)  CONSTRAINT [DF__T0200_MON__Defic__7CCF64C8] DEFAULT ((0)) NULL,
    [Total_Earning_Fraction]        NUMERIC (5, 2)  CONSTRAINT [DF_T0200_MONTHLY_SALARY_Total_Earning_Fraction] DEFAULT ((0)) NOT NULL,
    [Late_Early_Penalty_days]       NUMERIC (5, 2)  CONSTRAINT [DF__T0200_MON__Late___49A4C67D] DEFAULT ((0)) NULL,
    [M_WO_OT_Hours]                 NUMERIC (18, 2) NULL,
    [M_HO_OT_Hours]                 NUMERIC (18, 2) NULL,
    [M_WO_OT_Amount]                NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_M_WO_OT_Amount] DEFAULT ((0)) NOT NULL,
    [M_HO_OT_Amount]                NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_M_HO_OT_Amount] DEFAULT ((0)) NOT NULL,
    [is_Monthly_Salary]             TINYINT         CONSTRAINT [DF_T0200_MONTHLY_SALARY_is_Monthly_Salary] DEFAULT ((0)) NOT NULL,
    [Arear_Basic]                   NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Basic] DEFAULT ((0)) NOT NULL,
    [Arear_Gross]                   NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Gross] DEFAULT ((0)) NOT NULL,
    [Arear_Day]                     NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Day] DEFAULT ((0)) NOT NULL,
    [OD_Leave_Days]                 NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_OD_Leave_Days] DEFAULT ((0)) NOT NULL,
    [Extra_AB_Days]                 NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Extra_AB_Deduction] DEFAULT ((0)) NOT NULL,
    [Extra_AB_Rate]                 NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Extra_AB_Deduction1] DEFAULT ((0)) NOT NULL,
    [Extra_AB_Amount]               NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Extra_AB_Deduction2] DEFAULT ((0)) NOT NULL,
    [Access_Leave_Recovery]         NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Access_Leave_Recovery] DEFAULT ((0)) NOT NULL,
    [Access_Leave_Recovery_Day]     NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Access_Leave_Recovery_Day] DEFAULT ((0)) NOT NULL,
    [Net_Salary_Round_Diff_Amount]  NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Net_Salary_Round_Diff_Amount] DEFAULT ((0)) NOT NULL,
    [Access_Leave_Recovery_Type]    VARCHAR (250)   NULL,
    [Arear_Month]                   NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Month] DEFAULT ((0)) NOT NULL,
    [Arear_Year]                    NUMERIC (18)    CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Year] DEFAULT ((0)) NOT NULL,
    [GatePass_Deduct_Days]          NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_GatePass_Deduct_Days] DEFAULT ((0)) NOT NULL,
    [GatePass_Amount]               NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_GatePass_Amount] DEFAULT ((0)) NOT NULL,
    [Cutoff_Date]                   DATETIME        NULL,
    [Arear_Day_Previous_month]      NUMERIC (18, 3) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Arear_Day_Previous_month] DEFAULT ((0)) NOT NULL,
    [Basic_Salary_Arear_cutoff]     NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Basic_Salary_Arear_cutoff] DEFAULT ((0)) NOT NULL,
    [Gross_Salary_Arear_cutoff]     NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Gross_Salary_Arear_cutoff] DEFAULT ((0)) NOT NULL,
    [Asset_Installment]             NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Asset__432840D8] DEFAULT ((0)) NOT NULL,
    [FNF_Subsidy_Recover_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_FNF_Subsidy_Recover_Amount] DEFAULT ((0)) NOT NULL,
    [Extra_AB_Holiday_Days_Dection] NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Extra__58E34324] DEFAULT ((0)) NOT NULL,
    [Travel_Amount]                 NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Travel_Amount] DEFAULT ((0)) NOT NULL,
    [Travel_Advance_Amount]         NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Travel_Advance_Amount] DEFAULT ((0)) NOT NULL,
    [FNF_Comments]                  VARCHAR (MAX)   CONSTRAINT [DF__T0200_MON__FNF_C__2A51D7E0] DEFAULT (NULL) NULL,
    [Present_On_Holiday]            NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_Present_On_Holiday] DEFAULT ((0)) NOT NULL,
    [FNF_Training_Bnd_Rec_Amt]      NUMERIC (18, 2) CONSTRAINT [DF_T0200_MONTHLY_SALARY_FNF_Training_Bnd_Rec_Amt] DEFAULT ((0)) NOT NULL,
    [Uniform_Dedu_Amount]           NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Unifo__2DC1DC84] DEFAULT ((0)) NOT NULL,
    [Uniform_Refund_Amount]         NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Unifo__2EB600BD] DEFAULT ((0)) NOT NULL,
    [OT_Adj_against_absent]         NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__OT_Ad__69D85D39] DEFAULT ((0)) NOT NULL,
    [OT_Adj_Against_Absent_Hours]   VARCHAR (6)     NULL,
    [Bond_Amount]                   NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Bond___35056D9E] DEFAULT ((0)) NULL,
    [Retain_Days]                   NUMERIC (18, 2) CONSTRAINT [DF__T0200_MON__Retai__099B531F] DEFAULT ((0)) NULL,
    [Late_Days_Arear_Cutoff]        NUMERIC (5, 2)  DEFAULT ((0.0)) NOT NULL,
    [Early_Days_Arear_Cutoff]       NUMERIC (5, 2)  DEFAULT ((0.0)) NOT NULL,
    CONSTRAINT [PK_T0200_MONTHLY_SALARY] PRIMARY KEY CLUSTERED ([Sal_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_T0095_INCREMENT] FOREIGN KEY ([Increment_ID]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0200_Monthly_Salary_Index]
    ON [dbo].[T0200_MONTHLY_SALARY]([Cmp_ID] ASC, [Emp_ID] ASC, [Month_St_Date] ASC, [Month_End_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0200_MONTHLY_SALARY_12_1653580929__K3_K7_K1_33_56]
    ON [dbo].[T0200_MONTHLY_SALARY]([Emp_ID] ASC, [Month_End_Date] ASC, [Sal_Tran_ID] ASC)
    INCLUDE([Other_Allow_Amount], [Leave_Salary_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0200_MONTHLY_SALARY_Emp_ID_IS_FNF]
    ON [dbo].[T0200_MONTHLY_SALARY]([Emp_ID] ASC, [Is_FNF] ASC)
    INCLUDE([Sal_Tran_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0200_MONTHLY_SALARY_24_114099447__K3_K4_K7_K1_10_33_39_47_49_50]
    ON [dbo].[T0200_MONTHLY_SALARY]([Emp_ID] ASC, [Cmp_ID] ASC, [Month_End_Date] ASC, [Sal_Tran_ID] ASC)
    INCLUDE([Present_Days], [Other_Allow_Amount], [Other_Dedu_Amount], [M_OT_Hours], [M_Loan_Amount], [M_IT_Tax]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0200_MONTHLY_SALARY_24_114099447__K4_K3_K7_K1_10_33_39_47_49_50]
    ON [dbo].[T0200_MONTHLY_SALARY]([Cmp_ID] ASC, [Emp_ID] ASC, [Month_End_Date] ASC, [Sal_Tran_ID] ASC)
    INCLUDE([Present_Days], [Other_Allow_Amount], [Other_Dedu_Amount], [M_OT_Hours], [M_Loan_Amount], [M_IT_Tax]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0200_MONTHLY_SALARY_10_1887397843__K3_K65_K1]
    ON [dbo].[T0200_MONTHLY_SALARY]([Emp_ID] ASC, [Is_FNF] ASC, [Sal_Tran_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0200_MONTHLY_SALARY_10_1887397843__K7_K4_K3_K6_K1_38]
    ON [dbo].[T0200_MONTHLY_SALARY]([Month_End_Date] ASC, [Cmp_ID] ASC, [Emp_ID] ASC, [Month_St_Date] ASC, [Sal_Tran_ID] ASC)
    INCLUDE([Advance_Amount]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0200_MONTHLY_SALARY_Cmp_ID]
    ON [dbo].[T0200_MONTHLY_SALARY]([Cmp_ID] ASC)
    INCLUDE([Sal_Receipt_No], [Month_St_Date]) WITH (FILLFACTOR = 80);


GO
CREATE TRIGGER Tri_T0200_MONTHLY_SALARY_INSERT
ON dbo.T0200_MONTHLY_SALARY 
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

GO
CREATE TRIGGER Tri_T0200_MONTHLY_SALARY_DELETE
ON dbo.T0200_MONTHLY_SALARY 
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
CREATE TRIGGER [DBO].[Tri_T0200_MONTHLY_SALARY_UPDATE] 
ON dbo.T0200_MONTHLY_SALARY 
FOR UPDATE
AS
	
	declare @Emp_Id as numeric 
	declare @Cmp_ID as numeric
	declare @For_Date as datetime
	declare @Amount as numeric
	declare @Last_Adv_Closing as numeric
	declare @Old_Amount as numeric
	Declare @Adv_Tran_ID numeric 
	set @Emp_Id =0
	set @Cmp_ID =0
	set @Amount =0
	set @Last_Adv_Closing =0
	set @Old_Amount =0
	
	Select @Adv_Tran_ID = Isnull(max(Adv_Tran_ID),0) + 1 From T0140_Advance_Transaction 

	if not exists(Select 1 from inserted)
		and not exists(Select 1 from deleted)
		return 

	select @Emp_Id = ins.Emp_Id, @Cmp_ID = ins.Cmp_ID ,@For_Date = ins.Month_end_date
			,@Amount = isnull(ins.Advance_Amount,0) from inserted ins	
	
	select @Old_Amount = isnull(del.Advance_Amount,0) from deleted del	
	
	if @Emp_Id IS NULL OR @For_Date IS NULL
		RETURN
	
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

				IF @for_Date is not null
					Begin
						insert T0140_ADVANCE_TRANSACTION(Adv_Tran_ID,emp_id,Cmp_ID,For_Date,Adv_Opening,Adv_Return,Adv_Closing,Adv_Issue)
						values(@Adv_Tran_ID,@emp_id,@Cmp_ID,@for_Date,@last_Adv_Closing,@Amount,@last_Adv_Closing - (@Amount - @Old_Amount),0)
				
						update T0140_ADVANCE_TRANSACTION set Adv_Opening = Adv_Opening - @Amount
							,Adv_Closing = Adv_Closing - (@Amount - @Old_Amount)	
						where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
					End
			end
