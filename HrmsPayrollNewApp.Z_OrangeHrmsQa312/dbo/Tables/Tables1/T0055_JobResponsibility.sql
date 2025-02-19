CREATE TABLE [dbo].[T0055_JobResponsibility] (
    [Job_Resp_Id]    NUMERIC (18)  NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Job_Id]         NUMERIC (18)  NOT NULL,
    [Responsibility] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0055_JobResponsibility] PRIMARY KEY CLUSTERED ([Job_Resp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_JobResponsibility_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

