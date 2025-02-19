CREATE TABLE [dbo].[T0030_Thana_Master] (
    [Thana_Id]  NUMERIC (18)  NOT NULL,
    [Cmp_Id]    NUMERIC (18)  NULL,
    [ThanaName] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_T0030_Thana_Master] PRIMARY KEY CLUSTERED ([Thana_Id] ASC) WITH (FILLFACTOR = 80)
);

