CREATE TABLE [dbo].[T0050_Repository_Master] (
    [Repository_ID]   NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]          NUMERIC (18)   NULL,
    [Branch_ID]       VARCHAR (MAX)  NULL,
    [Compliance_ID]   NUMERIC (18)   NULL,
    [Month]           VARCHAR (50)   NULL,
    [Year]            VARCHAR (50)   NULL,
    [Submission_Date] DATETIME       NULL,
    [Remark]          VARCHAR (MAX)  NULL,
    [Attachment_path] NVARCHAR (MAX) NULL,
    [Repository_Name] VARCHAR (200)  NULL,
    CONSTRAINT [PK_T0050_Repository_Master] PRIMARY KEY CLUSTERED ([Repository_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0050_Repository_Master_ComplianceID] FOREIGN KEY ([Compliance_ID]) REFERENCES [dbo].[T0050_COMPLIANCE_MASTER] ([Compliance_ID])
);

