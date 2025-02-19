CREATE TABLE [dbo].[T0090_HRMS_RESUME_NOMINEE] (
    [Row_ID]               NUMERIC (18)  NOT NULL,
    [Cmp_id]               NUMERIC (18)  NOT NULL,
    [Resume_ID]            NUMERIC (18)  NOT NULL,
    [Member_Name]          VARCHAR (50)  NULL,
    [Member_Age]           NUMERIC (18)  NULL,
    [Relationship]         VARCHAR (50)  NULL,
    [Occupation]           VARCHAR (50)  NULL,
    [Comments]             VARCHAR (100) NULL,
    [Member_Date_of_Birth] DATETIME      NULL,
    [Relationship_ID]      NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0090_HRMS_RESUME_NOMINEE_1] PRIMARY KEY CLUSTERED ([Row_ID] ASC, [Resume_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0090_HRMS_RESUME_NOMINEE_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_HRMS_RESUME_NOMINEE_T0055_Resume_Master] FOREIGN KEY ([Resume_ID]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id])
);

