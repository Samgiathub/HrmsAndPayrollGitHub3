CREATE TABLE [dbo].[T0052_SurveyTemplate] (
    [SurveyQuestion_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [Survey_Id]         NUMERIC (18)   NULL,
    [Survey_Question]   NVARCHAR (500) NULL,
    [Survey_Type]       VARCHAR (50)   NULL,
    [Sorting_No]        INT            NULL,
    [Question_Option]   NVARCHAR (800) NULL,
    [SubQuestion]       TINYINT        DEFAULT ((0)) NOT NULL,
    [Is_Mandatory]      TINYINT        DEFAULT ((1)) NOT NULL,
    [Answer]            NVARCHAR (500) NULL,
    [Marks]             FLOAT (53)     NULL,
    CONSTRAINT [PK_T0052_SurveyTemplate] PRIMARY KEY CLUSTERED ([SurveyQuestion_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_SurveyTemplate_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_SurveyTemplate_T0050_SurveyMaster] FOREIGN KEY ([Survey_Id]) REFERENCES [dbo].[T0050_SurveyMaster] ([Survey_ID])
);


GO
CREATE STATISTICS [Survey_Question]
    ON [dbo].[T0052_SurveyTemplate]([Survey_Question]);

