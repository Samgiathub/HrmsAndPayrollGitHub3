CREATE TABLE [dbo].[T0150_HRMS_TRAINING_Questionnaire] (
    [Training_Que_ID]     NUMERIC (18)    NOT NULL,
    [Question]            NVARCHAR (500)  NOT NULL,
    [Training_Id]         VARCHAR (MAX)   NULL,
    [Cmp_Id]              NUMERIC (18)    NOT NULL,
    [Questionniare_Type]  INT             NULL,
    [Question_Type]       VARCHAR (50)    NULL,
    [Sorting_No]          INT             NULL,
    [Question_Option]     VARCHAR (800)   NULL,
    [Answer]              VARCHAR (800)   NULL,
    [Marks]               NUMERIC (18, 2) NULL,
    [Question_Row_Option] VARCHAR (8000)  NULL,
    [Question_Row_Type]   INT             NULL,
    [Video_Path]          VARCHAR (200)   NULL,
    CONSTRAINT [PK_T0150_HRMS_TRAINING_QUESTIONNAIRE] PRIMARY KEY CLUSTERED ([Training_Que_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0150_HRMS_TRAINING_Questionnaire_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

