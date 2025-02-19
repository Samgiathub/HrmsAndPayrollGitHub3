CREATE TABLE [dbo].[T0100_KPIRating_Level] (
    [Row_Id]                 NUMERIC (18)    NOT NULL,
    [Cmp_Id]                 NUMERIC (18)    NULL,
    [Tran_Id]                NUMERIC (18)    NULL,
    [SubKPIId]               NUMERIC (18)    NULL,
    [Metric_Manager]         VARCHAR (500)   NULL,
    [Rating_Manager]         NUMERIC (18)    NULL,
    [AchievedWeight_Manager] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0100_KPIRating_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_KPIRating_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_KPIRating_Level_T0030_HRMS_RATING_MASTER] FOREIGN KEY ([Rating_Manager]) REFERENCES [dbo].[T0030_HRMS_RATING_MASTER] ([Rate_ID]),
    CONSTRAINT [FK_T0100_KPIRating_Level_T0080_SubKPI_Master] FOREIGN KEY ([SubKPIId]) REFERENCES [dbo].[T0080_SubKPI_Master] ([SubKPIId]),
    CONSTRAINT [FK_T0100_KPIRating_Level_T0090_KPIPMS_EVAL_Approval] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0090_KPIPMS_EVAL_Approval] ([Tran_Id])
);

