CREATE TABLE [dbo].[T0040_SurveyQuestBank] (
    [SurveyQuestBank_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]             NUMERIC (18)   NULL,
    [Survey_Question]    NVARCHAR (500) NULL,
    [Survey_Type]        VARCHAR (50)   NULL,
    [Question_Option]    NVARCHAR (800) NULL,
    [Answer]             NVARCHAR (500) NULL,
    [Marks]              FLOAT (53)     NULL,
    CONSTRAINT [PK_T0040_SurveyQuestBank] PRIMARY KEY CLUSTERED ([SurveyQuestBank_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_SurveyQuestBank_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);


GO
CREATE STATISTICS [Survey_Question]
    ON [dbo].[T0040_SurveyQuestBank]([Survey_Question]);

