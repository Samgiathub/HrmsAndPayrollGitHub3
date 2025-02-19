CREATE TABLE [dbo].[T0040_Scheme_Master] (
    [Scheme_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Scheme_Name]    VARCHAR (100) NOT NULL,
    [Scheme_Type]    VARCHAR (50)  NOT NULL,
    [Default_Scheme] BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_Scheme_Master] PRIMARY KEY CLUSTERED ([Scheme_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Scheme_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Scheme_Master_T0040_Scheme_Master] FOREIGN KEY ([Scheme_Id]) REFERENCES [dbo].[T0040_Scheme_Master] ([Scheme_Id])
);

