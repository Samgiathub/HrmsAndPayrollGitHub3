CREATE TABLE [dbo].[T0050_Task_Detail] (
    [Task_Detail_ID] NUMERIC (18) NOT NULL,
    [Task_ID]        NUMERIC (18) NULL,
    [Assign_To]      NUMERIC (18) NULL,
    [Project_ID]     NUMERIC (18) NULL,
    [Cmp_ID]         NUMERIC (18) NULL,
    [Created_By]     NUMERIC (18) NULL,
    [Created_Date]   DATETIME     NULL,
    [Modify_By]      NUMERIC (18) NULL,
    [Modify_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0050_Task_Detail] PRIMARY KEY CLUSTERED ([Task_Detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_Task_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_Task_Detail_T0011_LOGIN] FOREIGN KEY ([Created_By]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0050_Task_Detail_T0040_Task_Master] FOREIGN KEY ([Task_ID]) REFERENCES [dbo].[T0040_Task_Master] ([Task_ID]),
    CONSTRAINT [FK_T0050_Task_Detail_T0040_TS_Project_Master] FOREIGN KEY ([Project_ID]) REFERENCES [dbo].[T0040_TS_Project_Master] ([Project_ID]),
    CONSTRAINT [FK_T0050_Task_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Assign_To]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

