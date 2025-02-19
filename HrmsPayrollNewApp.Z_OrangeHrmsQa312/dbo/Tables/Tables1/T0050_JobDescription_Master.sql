CREATE TABLE [dbo].[T0050_JobDescription_Master] (
    [Job_Id]           NUMERIC (18)   NOT NULL,
    [Cmp_Id]           NUMERIC (18)   NOT NULL,
    [Effective_Date]   DATETIME       NOT NULL,
    [Job_Code]         VARCHAR (50)   NOT NULL,
    [Branch_Id]        VARCHAR (MAX)  NULL,
    [Grade_Id]         VARCHAR (MAX)  NULL,
    [Desig_Id]         VARCHAR (MAX)  NULL,
    [Dept_Id]          VARCHAR (MAX)  NULL,
    [Qual_Id]          VARCHAR (MAX)  NULL,
    [Exp_Min]          INT            NULL,
    [Exp_Max]          INT            NULL,
    [Create_Date]      DATETIME       NOT NULL,
    [Create_By]        NUMERIC (18)   NOT NULL,
    [Attach_Doc]       VARCHAR (2000) DEFAULT ('') NOT NULL,
    [status]           INT            DEFAULT ((1)) NOT NULL,
    [Job_Title]        VARCHAR (200)  NULL,
    [Send_To_Superior] INT            NULL,
    [Document_ID]      VARCHAR (250)  DEFAULT ('') NOT NULL,
    [Experience_Type]  INT            NULL,
    CONSTRAINT [PK_T0050_JobDescription_Master] PRIMARY KEY CLUSTERED ([Job_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_JobDescription_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

