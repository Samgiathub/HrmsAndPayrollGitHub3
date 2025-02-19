CREATE TABLE [dbo].[T0250_Change_Password_History] (
    [Tran_ID]             NUMERIC (18) NOT NULL,
    [Cmp_ID]              NUMERIC (18) NOT NULL,
    [Emp_ID]              NUMERIC (18) NULL,
    [Password]            VARCHAR (50) NOT NULL,
    [Effective_From_Date] DATETIME     NOT NULL,
    CONSTRAINT [PK_T0250_Change_Password_History] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0250_Change_Password_History_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0250_Change_Password_History_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

