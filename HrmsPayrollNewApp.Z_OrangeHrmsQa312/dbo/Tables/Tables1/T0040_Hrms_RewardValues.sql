CREATE TABLE [dbo].[T0040_Hrms_RewardValues] (
    [RewardValues_Id]   NUMERIC (18)  NOT NULL,
    [Cmp_Id]            NUMERIC (18)  NOT NULL,
    [RewardValues_Name] VARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_Hrms_RewardValues] PRIMARY KEY CLUSTERED ([RewardValues_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Hrms_RewardValues_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

