CREATE TABLE [dbo].[T0040_Tally_Led_Master] (
    [Tally_Led_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_Id]                NUMERIC (18)  NOT NULL,
    [Tally_Led_Name]        VARCHAR (100) NOT NULL,
    [Parent_Tally_Led_Name] VARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_Tally_Led_Master] PRIMARY KEY CLUSTERED ([Tally_Led_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Tally_Led_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

