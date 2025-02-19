CREATE TABLE [dbo].[T0040_Cost_Center] (
    [Tally_Center_ID] NUMERIC (18) NOT NULL,
    [Tally_Cat_ID]    NUMERIC (18) NOT NULL,
    [Cmp_ID]          NUMERIC (18) NOT NULL,
    [Cost_Center]     VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_T0040_Cost_Center] PRIMARY KEY CLUSTERED ([Tally_Center_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Cost_Center_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Cost_Center_T0040_Cost_Category] FOREIGN KEY ([Tally_Cat_ID]) REFERENCES [dbo].[T0040_Cost_Category] ([Tally_Cat_ID])
);

