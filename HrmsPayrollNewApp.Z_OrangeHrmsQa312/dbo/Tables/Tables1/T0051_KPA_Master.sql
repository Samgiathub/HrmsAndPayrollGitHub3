CREATE TABLE [dbo].[T0051_KPA_Master] (
    [KPA_Id]                 NUMERIC (18)    NOT NULL,
    [Cmp_Id]                 NUMERIC (18)    NOT NULL,
    [Desig_Id]               VARCHAR (MAX)   NULL,
    [KPA_Content]            NVARCHAR (1000) NULL,
    [KPA_Target]             NVARCHAR (1000) NULL,
    [KPA_Weightage]          NUMERIC (18, 2) NULL,
    [Dept_Id]                VARCHAR (MAX)   NULL,
    [Effective_Date]         DATETIME        NULL,
    [KPA_Type_ID]            NUMERIC (18)    NULL,
    [KPA_Performace_Measure] NVARCHAR (500)  NULL,
    [Completion_Date]        DATETIME        NULL,
    [Attach_Docs]            VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0051_KPA_Master] PRIMARY KEY CLUSTERED ([KPA_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0051_KPA_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0051_KPA_Master_T0040_HRMS_KPAType_Master] FOREIGN KEY ([KPA_Type_ID]) REFERENCES [dbo].[T0040_HRMS_KPAType_Master] ([KPA_Type_Id])
);

