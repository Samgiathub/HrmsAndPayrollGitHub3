CREATE TABLE [dbo].[T0210_MONTHLY_CLAIM_PAYMENT] (
    [Claim_Pay_ID]       NUMERIC (18)    NOT NULL,
    [Claim_Apr_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NOT NULL,
    [Sal_Tran_ID]        NUMERIC (18)    NULL,
    [Claim_Pay_Code]     VARCHAR (20)    NULL,
    [Claim_Pay_Amount]   NUMERIC (18, 3) NOT NULL,
    [Claim_Pay_Comments] VARCHAR (250)   NOT NULL,
    [Claim_Payment_Date] DATETIME        NOT NULL,
    [Claim_Payment_Type] VARCHAR (20)    NOT NULL,
    [Bank_Name]          VARCHAR (50)    NOT NULL,
    [Claim_Cheque_No]    VARCHAR (50)    NOT NULL,
    [Temp_Sal_Tran_ID]   NUMERIC (18)    NULL,
    [Voucher_No]         VARCHAR (50)    DEFAULT (NULL) NULL,
    [Voucher_Date]       DATETIME        DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0210_MONTHLY_CLAIM_PAYMENT] PRIMARY KEY CLUSTERED ([Claim_Pay_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0210_MONTHLY_CLAIM_PAYMENT_T0120_CLAIM_APPROVAL] FOREIGN KEY ([Claim_Apr_ID]) REFERENCES [dbo].[T0120_CLAIM_APPROVAL] ([Claim_Apr_ID])
);

