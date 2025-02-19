CREATE TABLE [dbo].[T0090_Emp_Other_Detail] (
    [Emp_Other_ID]       NUMERIC (18)   NOT NULL,
    [Emp_ID]             NUMERIC (18)   NOT NULL,
    [Cmp_ID]             NUMERIC (18)   NOT NULL,
    [Salary_Acc_No]      VARCHAR (50)   NOT NULL,
    [Pan_No]             VARCHAR (50)   NOT NULL,
    [K11_Certifies]      NUMERIC (18)   NOT NULL,
    [Sales_Training]     NUMERIC (18)   NOT NULL,
    [Account_Training]   NUMERIC (18)   NOT NULL,
    [Induction_Training] NUMERIC (18)   NOT NULL,
    [FCM_ID]             NUMERIC (18)   NOT NULL,
    [CCM_ID]             NUMERIC (18)   NOT NULL,
    [Uniform_Given]      NUMERIC (18)   NOT NULL,
    [Compurter_Litercy]  NUMERIC (18)   NOT NULL,
    [Interview_Comments] VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_T0090_Emp_Other_Detail] PRIMARY KEY CLUSTERED ([Emp_Other_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Emp_Other_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Emp_Other_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

