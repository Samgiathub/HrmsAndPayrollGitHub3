CREATE TABLE [dbo].[T0040_HRMS_AttributeMaster] (
    [PA_ID]            NUMERIC (18)   NOT NULL,
    [Cmp_ID]           NUMERIC (18)   NOT NULL,
    [PA_Title]         NVARCHAR (250) NULL,
    [PA_Type]          VARCHAR (5)    NULL,
    [PA_Weightage]     NUMERIC (18)   NULL,
    [PA_SortNo]        INT            NULL,
    [PA_Category]      VARCHAR (50)   NULL,
    [PA_EffectiveDate] DATETIME       NULL,
    [PA_DeptId]        VARCHAR (MAX)  NULL,
    [Ref_PAID]         NUMERIC (18)   NULL,
    [PA_Desc]          NVARCHAR (200) NULL,
    [Grade_ID]         VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_T0040_HRMS_AttributeMaster] PRIMARY KEY CLUSTERED ([PA_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_HRMS_AttributeMaster_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

