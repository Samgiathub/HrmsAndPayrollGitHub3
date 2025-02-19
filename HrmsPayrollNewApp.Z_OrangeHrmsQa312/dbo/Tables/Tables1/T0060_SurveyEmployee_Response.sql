CREATE TABLE [dbo].[T0060_SurveyEmployee_Response] (
    [SurveyEmp_Id]      NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NULL,
    [Emp_Id]            NUMERIC (18)   NULL,
    [Survey_Id]         NUMERIC (18)   NULL,
    [SurveyQuestion_Id] NUMERIC (18)   NULL,
    [Answer]            NVARCHAR (MAX) NULL,
    [Response_Date]     DATETIME       NULL,
    CONSTRAINT [PK_T0060_SurveyEmployee_Response] PRIMARY KEY CLUSTERED ([SurveyEmp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0060_SurveyEmployee_Response_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_SurveyEmployee_Response_T0050_SurveyMaster] FOREIGN KEY ([Survey_Id]) REFERENCES [dbo].[T0050_SurveyMaster] ([Survey_ID]),
    CONSTRAINT [FK_T0060_SurveyEmployee_Response_T0052_SurveyTemplate] FOREIGN KEY ([SurveyQuestion_Id]) REFERENCES [dbo].[T0052_SurveyTemplate] ([SurveyQuestion_Id]),
    CONSTRAINT [FK_T0060_SurveyEmployee_Response_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE STATISTICS [Answer]
    ON [dbo].[T0060_SurveyEmployee_Response]([Answer]);

