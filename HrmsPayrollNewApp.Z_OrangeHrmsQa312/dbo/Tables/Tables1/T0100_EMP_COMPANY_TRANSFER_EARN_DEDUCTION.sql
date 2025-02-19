CREATE TABLE [dbo].[T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION] (
    [Row_Id]         NUMERIC (18)    NOT NULL,
    [Tran_Id]        NUMERIC (18)    NOT NULL,
    [Old_Cmp_Id]     NUMERIC (18)    NOT NULL,
    [Old_Emp_Id]     NUMERIC (18)    NOT NULL,
    [Old_Ad_Id]      NUMERIC (18)    NULL,
    [Old_Mode]       VARCHAR (10)    NULL,
    [Old_Percentage] NUMERIC (12, 2) NULL,
    [Old_Amount]     NUMERIC (18, 2) NULL,
    [New_Cmp_Id]     NUMERIC (18)    NOT NULL,
    [New_Emp_Id]     NUMERIC (18)    NOT NULL,
    [New_Ad_Id]      NUMERIC (18)    NULL,
    [New_Mode]       VARCHAR (10)    NULL,
    [New_Percentage] NUMERIC (12, 2) NULL,
    [New_Amount]     NUMERIC (18, 2) NULL,
    [Ad_Row_Id]      NUMERIC (18)    NOT NULL,
    CONSTRAINT [PK_T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION_T0095_EMP_COMPANY_TRANSFER] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0095_EMP_COMPANY_TRANSFER] ([Tran_Id])
);

