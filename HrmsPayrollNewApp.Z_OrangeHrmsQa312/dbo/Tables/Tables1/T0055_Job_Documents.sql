CREATE TABLE [dbo].[T0055_Job_Documents] (
    [Doc_ID]     INT            NOT NULL,
    [Cmp_ID]     NUMERIC (18)   NOT NULL,
    [DocType_ID] NUMERIC (18)   NOT NULL,
    [Job_ID]     NUMERIC (18)   NOT NULL,
    [File_Name]  VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_T0055_Job_Documents] PRIMARY KEY CLUSTERED ([Doc_ID] ASC),
    CONSTRAINT [FK_T0055_Job_Documents_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0055_Job_Documents_T0040_DOCUMENT_MASTER] FOREIGN KEY ([DocType_ID]) REFERENCES [dbo].[T0040_DOCUMENT_MASTER] ([Doc_ID]),
    CONSTRAINT [FK_T0055_Job_Documents_T0050_JobDescription_Master] FOREIGN KEY ([Job_ID]) REFERENCES [dbo].[T0050_JobDescription_Master] ([Job_Id])
);

