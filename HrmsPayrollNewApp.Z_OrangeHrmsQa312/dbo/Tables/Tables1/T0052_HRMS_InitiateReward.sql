CREATE TABLE [dbo].[T0052_HRMS_InitiateReward] (
    [InitReward_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]        NUMERIC (18)  NULL,
    [From_Date]     DATETIME      NULL,
    [To_Date]       DATETIME      NULL,
    [Dept_Id]       VARCHAR (800) NULL,
    [Cat_Id]        VARCHAR (800) NULL,
    CONSTRAINT [PK_T0052_HRMS_InitiateReward] PRIMARY KEY CLUSTERED ([InitReward_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_InitiateReward_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

