CREATE TABLE [dbo].[T0050_TS_Project_Detail] (
    [Project_Detail_ID] NUMERIC (18) NOT NULL,
    [Project_ID]        NUMERIC (18) NULL,
    [Assign_To]         NUMERIC (18) NULL,
    [Cmp_ID]            NUMERIC (18) NULL,
    [Created_By]        NUMERIC (18) NULL,
    [Created_Date]      DATETIME     NULL,
    [Modify_By]         NUMERIC (18) NULL,
    [Modify_Date]       DATETIME     NULL,
    [Branch_ID]         NUMERIC (18) NULL,
    CONSTRAINT [PK_T0050_TS_Project_Detail] PRIMARY KEY CLUSTERED ([Project_Detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_TS_Project_Detail_T0040_TS_Project_Master] FOREIGN KEY ([Project_ID]) REFERENCES [dbo].[T0040_TS_Project_Master] ([Project_ID])
);

