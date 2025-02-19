CREATE TABLE [dbo].[T0115_RecruitmentResponsibilty_Level] (
    [Row_Id]         NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [RecApp_Id]      NUMERIC (18)  NOT NULL,
    [Responsibility] VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_T0115_RecruitmentResponsibilty_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0115_RecruitmentResponsibilty_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

