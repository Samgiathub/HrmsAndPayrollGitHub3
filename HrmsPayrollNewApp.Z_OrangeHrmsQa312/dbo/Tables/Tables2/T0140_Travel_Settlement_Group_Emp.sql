CREATE TABLE [dbo].[T0140_Travel_Settlement_Group_Emp] (
    [Tran_ID]               INT          NOT NULL,
    [Cmp_ID]                NUMERIC (18) NOT NULL,
    [Emp_ID]                NUMERIC (18) NOT NULL,
    [Travel_Approval_ID]    NUMERIC (18) NOT NULL,
    [Travel_Application_ID] NUMERIC (18) NOT NULL,
    [Branch_ID]             NUMERIC (18) NOT NULL,
    [Modify_Date]           DATETIME     NOT NULL,
    [Selected_Emp_ID]       NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0140_Travel_Settlement_Group_Emp] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0140_Travel_Settlement_Group_Emp_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0140_Travel_Settlement_Group_Emp_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0140_Travel_Settlement_Group_Emp_T0120_TRAVEL_APPROVAL] FOREIGN KEY ([Travel_Approval_ID]) REFERENCES [dbo].[T0120_TRAVEL_APPROVAL] ([Travel_Approval_ID])
);

