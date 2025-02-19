CREATE TABLE [dbo].[T0040_Speciality_Master] (
    [Speciality_ID]   NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NULL,
    [Speciality_Name] VARCHAR (255) NULL,
    [Description]     VARCHAR (255) NULL,
    CONSTRAINT [PK_T0040_Speciality_Master] PRIMARY KEY CLUSTERED ([Speciality_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Speciality_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

