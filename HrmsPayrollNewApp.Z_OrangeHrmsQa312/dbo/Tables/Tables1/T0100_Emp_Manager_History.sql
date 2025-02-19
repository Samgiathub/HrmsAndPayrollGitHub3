CREATE TABLE [dbo].[T0100_Emp_Manager_History] (
    [row_id]       NUMERIC (18) NOT NULL,
    [Cmp_id]       NUMERIC (18) NOT NULL,
    [Emp_id]       NUMERIC (18) NOT NULL,
    [Increment_id] NUMERIC (18) NOT NULL,
    [emp_superior] NUMERIC (18) NULL,
    [For_date]     DATETIME     NULL,
    CONSTRAINT [PK_T0100_Emp_Manager_History] PRIMARY KEY CLUSTERED ([row_id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_Emp_Manager_History_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_Emp_Manager_History_T0095_INCREMENT] FOREIGN KEY ([Increment_id]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID])
);

