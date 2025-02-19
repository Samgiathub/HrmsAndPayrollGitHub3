CREATE TABLE [dbo].[T0090_HRMS_RESUME_QUALIFICATION] (
    [Row_ID]              NUMERIC (18)    NOT NULL,
    [Cmp_id]              NUMERIC (18)    NOT NULL,
    [Resume_ID]           NUMERIC (18)    NOT NULL,
    [Qual_ID]             NUMERIC (18)    NOT NULL,
    [Specialization]      VARCHAR (100)   NULL,
    [Year]                NUMERIC (18)    NULL,
    [Score]               NUMERIC (18, 2) NULL,
    [St_Date]             DATETIME        NULL,
    [End_Date]            DATETIME        NULL,
    [Comments]            VARCHAR (250)   NULL,
    [EduCertificate_path] VARCHAR (MAX)   NULL,
    [University]          VARCHAR (200)   NULL,
    [Division]            VARCHAR (50)    NULL,
    CONSTRAINT [PK_T0090_HRMS_RESUME_QUALIFICATION] PRIMARY KEY CLUSTERED ([Row_ID] ASC, [Resume_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_RESUME_QUALIFICATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_HRMS_RESUME_QUALIFICATION_T0040_QUALIFICATION_MASTER] FOREIGN KEY ([Qual_ID]) REFERENCES [dbo].[T0040_QUALIFICATION_MASTER] ([Qual_ID]),
    CONSTRAINT [FK_T0090_HRMS_RESUME_QUALIFICATION_T0055_Resume_Master] FOREIGN KEY ([Resume_ID]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id])
);

