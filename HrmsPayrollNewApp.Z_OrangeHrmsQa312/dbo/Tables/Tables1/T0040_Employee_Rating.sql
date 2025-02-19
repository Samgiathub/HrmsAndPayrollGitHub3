CREATE TABLE [dbo].[T0040_Employee_Rating] (
    [E_Rate_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Branch_ID]         NUMERIC (18)    NULL,
    [E_Rate_From_Limit] NUMERIC (18, 2) NULL,
    [E_Rate_To_Limit]   NUMERIC (18, 2) NULL,
    [E_Rank]            NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0040_Employee_Rating] PRIMARY KEY CLUSTERED ([E_Rate_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Employee_Rating_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Employee_Rating_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

