CREATE TABLE [dbo].[T0200_Question_Master] (
    [Question_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]      NUMERIC (18)  NOT NULL,
    [Question]    VARCHAR (150) NOT NULL,
    [Description] VARCHAR (100) NULL,
    [Is_Active]   TINYINT       NOT NULL,
    CONSTRAINT [PK_T0200_Question_Master] PRIMARY KEY CLUSTERED ([Question_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_Question_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

