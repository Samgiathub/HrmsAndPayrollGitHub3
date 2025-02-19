CREATE TABLE [dbo].[T0090_Emp_Membership_Detail] (
    [Membership_ID]     NUMERIC (18) NOT NULL,
    [Cmp_ID]            NUMERIC (18) NOT NULL,
    [Emp_ID]            NUMERIC (18) NOT NULL,
    [Membership_Date]   DATETIME     NOT NULL,
    [Relation_employee] NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0090_Emp_Membership_Detail] PRIMARY KEY CLUSTERED ([Membership_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Emp_Membership_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Emp_Membership_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

