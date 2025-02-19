CREATE TABLE [dbo].[T0130_BOND_INSTALLMENT_DETAIL] (
    [Installment_ID]  NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Emp_ID]          NUMERIC (18)    NOT NULL,
    [Bond_ID]         NUMERIC (18)    NULL,
    [Bond_Apr_ID]     NUMERIC (18)    NOT NULL,
    [Effective_Date]  DATETIME        NULL,
    [Installment_Amt] NUMERIC (18, 2) NULL,
    [System_Date]     DATETIME        NULL,
    CONSTRAINT [PK_T0130_BOND_INSTALLMENT_DETAIL] PRIMARY KEY CLUSTERED ([Installment_ID] ASC),
    CONSTRAINT [FK_T0130_BOND_INSTALLMENT_DETAIL_T0120_BOND_APPROVAL] FOREIGN KEY ([Bond_Apr_ID]) REFERENCES [dbo].[T0120_BOND_APPROVAL] ([Bond_Apr_Id])
);

