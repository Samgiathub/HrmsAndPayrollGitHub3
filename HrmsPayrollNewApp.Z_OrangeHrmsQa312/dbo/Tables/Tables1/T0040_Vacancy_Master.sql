CREATE TABLE [dbo].[T0040_Vacancy_Master] (
    [Vacancy_ID]   NUMERIC (18) NOT NULL,
    [Vacancy_Name] VARCHAR (50) NOT NULL,
    [Cmp_ID]       NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0040_Vacancy_Master] PRIMARY KEY CLUSTERED ([Vacancy_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_Vacancy_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_Vacancy_Master_T0040_Vacancy_Master1] FOREIGN KEY ([Vacancy_ID]) REFERENCES [dbo].[T0040_Vacancy_Master] ([Vacancy_ID])
);

