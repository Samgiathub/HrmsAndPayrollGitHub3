CREATE TABLE [dbo].[MONTHLY_EMP_BANK_PAYMENT] (
    [Emp_ID]             NUMERIC (18)  NOT NULL,
    [Cmp_ID]             NUMERIC (18)  NOT NULL,
    [For_Date]           DATETIME      NOT NULL,
    [Payment_Date]       DATETIME      NOT NULL,
    [Emp_Bank_ID]        NUMERIC (18)  NULL,
    [Payment_Mode]       VARCHAR (100) NULL,
    [Net_Amount]         NUMERIC (18)  NULL,
    [Emp_Bank_AC_No]     VARCHAR (50)  NULL,
    [Cmp_Bank_ID]        NUMERIC (18)  NULL,
    [Emp_Cheque_No]      VARCHAR (20)  NULL,
    [Cmp_Bank_Cheque_No] VARCHAR (20)  NULL,
    [Cmp_Bank_AC_No]     VARCHAR (20)  NULL,
    [Emp_Left]           CHAR (1)      CONSTRAINT [DF_MONTHLY_EMP_BANK_PAYMENT_Emp_Left] DEFAULT ('N') NULL,
    [Status]             VARCHAR (10)  NULL,
    [Process_Type]       VARCHAR (500) CONSTRAINT [DF_MONTHLY_EMP_BANK_PAYMENT_Process_Type] DEFAULT ('Salary') NOT NULL,
    [Ad_Id]              NUMERIC (18)  CONSTRAINT [DF_MONTHLY_EMP_BANK_PAYMENT_Ad_Id] DEFAULT ((0)) NOT NULL,
    [process_type_id]    NUMERIC (18)  CONSTRAINT [DF_MONTHLY_EMP_BANK_PAYMENT_process_type_id] DEFAULT ((0)) NOT NULL,
    [payment_process_id] NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_MONTHLY_EMP_BANK_PAYMENT] PRIMARY KEY CLUSTERED ([Emp_ID] ASC, [For_Date] ASC, [Process_Type] ASC, [Ad_Id] ASC, [process_type_id] ASC),
    CONSTRAINT [FK_MONTHLY_EMP_BANK_PAYMENT_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_MONTHLY_EMP_BANK_PAYMENT_T0080_Emp_Master] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

