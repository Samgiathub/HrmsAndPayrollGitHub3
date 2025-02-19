CREATE TABLE [dbo].[T0210_LTA_Medical_Payment] (
    [LM_Pay_ID]       NUMERIC (18)  NOT NULL,
    [LM_Apr_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Sal_Tran_ID]     NUMERIC (18)  NULL,
    [S_Sal_Tran_ID]   NUMERIC (18)  NULL,
    [L_Sal_Tran_ID]   NUMERIC (18)  NULL,
    [LM_Pay_Amount]   NUMERIC (18)  NOT NULL,
    [LM_Pay_Comments] VARCHAR (250) NOT NULL,
    [LM_Payment_Date] DATETIME      NOT NULL,
    [LM_Payment_Type] VARCHAR (20)  NOT NULL,
    [Bank_Name]       VARCHAR (50)  NOT NULL,
    [LM_Cheque_No]    VARCHAR (50)  NOT NULL,
    [LM_Pay_Code]     VARCHAR (20)  NULL,
    CONSTRAINT [PK_T0210_LTA_Medical_Payment] PRIMARY KEY CLUSTERED ([LM_Pay_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0210_LTA_Medical_Payment_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0210_LTA_Medical_Payment_T0120_LTA_Medical_Approval] FOREIGN KEY ([LM_Apr_ID]) REFERENCES [dbo].[T0120_LTA_Medical_Approval] ([LM_Apr_ID]),
    CONSTRAINT [FK_T0210_LTA_Medical_Payment_T0200_MONTHLY_SALARY] FOREIGN KEY ([Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY] ([Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_LTA_Medical_Payment_T0200_MONTHLY_SALARY_LEAVE] FOREIGN KEY ([L_Sal_Tran_ID]) REFERENCES [dbo].[T0200_MONTHLY_SALARY_LEAVE] ([L_Sal_Tran_ID]),
    CONSTRAINT [FK_T0210_LTA_Medical_Payment_T0201_MONTHLY_SALARY_SETT] FOREIGN KEY ([S_Sal_Tran_ID]) REFERENCES [dbo].[T0201_MONTHLY_SALARY_SETT] ([S_Sal_Tran_ID])
);


GO




CREATE TRIGGER [DBO].[Tri_T0210_LTA_Medical_Payment_delete]
ON [dbo].[T0210_LTA_Medical_Payment]
FOR  delete
AS
declare @sal_tran_id as numeric(18,0)
declare @LM_Apr_ID as numeric(18,0)
declare @LM_Pay_Amount as numeric(18,0)
declare @Apr_Amount as numeric(18,0)
declare @P_Status int
declare @type_id int
-------------------LTA & MEDICAL
	select @sal_tran_id=DE.sal_tran_id, @LM_Apr_ID = DE.LM_Apr_ID ,@LM_Pay_Amount=DE.LM_Pay_Amount from DELETED DE	
	
	select @LM_Pay_Amount=isnull(sum(isnull(LM_Pay_Amount,0)),0) from T0210_LTA_Medical_Payment where LM_Apr_ID=@LM_Apr_ID
	select @Apr_Amount=Apr_Amount,@type_id=type_id from T0120_LTA_Medical_Approval where LM_Apr_ID=@LM_Apr_ID
	
	if exists(select LM_Tran_ID from T0240_LTA_Medical_Transaction where LM_Apr_ID=@LM_Apr_ID)
	begin
		if @Apr_Amount=@LM_Pay_Amount
			set @P_Status=1
		else
			set @P_Status=0
		update T0240_LTA_Medical_Transaction set P_Status=@P_Status,sal_tran_id=@sal_tran_id where LM_Apr_ID=@LM_Apr_ID
	end




GO




CREATE TRIGGER [DBO].[Tri_T0210_LTA_Medical_Payment]
ON [dbo].[T0210_LTA_Medical_Payment]
FOR  INSERT,UPDATE
AS
declare @sal_tran_id as numeric(18,0)
declare @LM_Apr_ID as numeric(18,0)
declare @LM_Pay_Amount as numeric(18,0)
declare @Apr_Amount as numeric(18,0)
declare @P_Status int
declare @type_id int
-------------------LTA & MEDICAL
	select @sal_tran_id=ins.sal_tran_id, @LM_Apr_ID = ins.LM_Apr_ID ,@LM_Pay_Amount=ins.LM_Pay_Amount from inserted ins	
	
	select @LM_Pay_Amount=isnull(sum(isnull(LM_Pay_Amount,0)),0) from T0210_LTA_Medical_Payment where LM_Apr_ID=@LM_Apr_ID
	select @Apr_Amount=Apr_Amount,@type_id=type_id from T0120_LTA_Medical_Approval where LM_Apr_ID=@LM_Apr_ID
	
	if exists(select LM_Tran_ID from T0240_LTA_Medical_Transaction where LM_Apr_ID=@LM_Apr_ID)
	begin
		if @Apr_Amount=@LM_Pay_Amount
			set @P_Status=1
		else
			set @P_Status=0
		update T0240_LTA_Medical_Transaction set P_Status=@P_Status,sal_tran_id=@sal_tran_id where LM_Apr_ID=@LM_Apr_ID
	end



