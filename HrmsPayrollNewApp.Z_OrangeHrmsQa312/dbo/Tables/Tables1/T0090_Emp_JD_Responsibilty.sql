CREATE TABLE [dbo].[T0090_Emp_JD_Responsibilty] (
    [Emp_JD_Tran_ID] NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Emp_Id]         NUMERIC (18)  NOT NULL,
    [JDCode_Id]      NUMERIC (18)  NOT NULL,
    [EffectiveDate]  DATETIME      NOT NULL,
    [Responsibilty]  VARCHAR (MAX) NULL,
    [Create_Date]    DATETIME      NOT NULL,
    CONSTRAINT [PK_T0090_Emp_JD_Responsibilty] PRIMARY KEY CLUSTERED ([Emp_JD_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Emp_JD_Responsibilty_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Emp_JD_Responsibilty_T0050_JobDescription_Master] FOREIGN KEY ([JDCode_Id]) REFERENCES [dbo].[T0050_JobDescription_Master] ([Job_Id]),
    CONSTRAINT [FK_T0090_Emp_JD_Responsibilty_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

