CREATE TABLE [dbo].[T0302_Payment_Process_Travel_Details] (
    [Travel_Payment_Id]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]                 NUMERIC (18)  NOT NULL,
    [Emp_Id]                 NUMERIC (18)  NOT NULL,
    [Travel_Approval_Id]     NUMERIC (18)  NOT NULL,
    [Travel_Set_Approval_Id] NUMERIC (18)  NULL,
    [Payment_Process_Id]     NUMERIC (18)  NOT NULL,
    [Process_Type]           VARCHAR (500) NULL,
    CONSTRAINT [PK_T0302_Payment_Process_Travel_Details] PRIMARY KEY CLUSTERED ([Travel_Payment_Id] ASC),
    CONSTRAINT [FK_T0302_Payment_Process_Travel_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0302_Payment_Process_Travel_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

