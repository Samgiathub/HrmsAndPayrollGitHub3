CREATE TABLE [dbo].[T0110_Training_Induction_Details] (
    [Tran_ID]               NUMERIC (18)  NOT NULL,
    [Training_Induction_ID] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                NUMERIC (18)  NOT NULL,
    [Emp_ID]                NUMERIC (18)  NOT NULL,
    [Training_Date]         DATETIME      NOT NULL,
    [Training_Time]         DATETIME      NOT NULL,
    [Modify_By]             NUMERIC (18)  NOT NULL,
    [Modify_Date]           DATETIME      NOT NULL,
    [IP_Address]            VARCHAR (150) NOT NULL,
    CONSTRAINT [PK_T0110_Training_Induction_Details] PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK_T0110_Training_Induction_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_Training_Induction_Details_T0040_Training_Induction_Master] FOREIGN KEY ([Training_Induction_ID]) REFERENCES [dbo].[T0040_Training_Induction_Master] ([Training_Induction_ID]),
    CONSTRAINT [FK_T0110_Training_Induction_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

