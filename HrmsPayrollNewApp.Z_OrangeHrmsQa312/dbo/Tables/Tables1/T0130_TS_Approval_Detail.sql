CREATE TABLE [dbo].[T0130_TS_Approval_Detail] (
    [TS_Approval_Detail_ID] NUMERIC (18)  NOT NULL,
    [Timesheet_Approval_ID] NUMERIC (18)  NULL,
    [Project_ID]            NUMERIC (18)  NULL,
    [Task_ID]               NUMERIC (18)  NULL,
    [Mon]                   VARCHAR (MAX) NULL,
    [Tue]                   VARCHAR (MAX) NULL,
    [Wed]                   VARCHAR (MAX) NULL,
    [Thu]                   VARCHAR (MAX) NULL,
    [Fri]                   VARCHAR (MAX) NULL,
    [Sat]                   VARCHAR (MAX) NULL,
    [Sun]                   VARCHAR (MAX) NULL,
    [Cmp_ID]                NUMERIC (18)  NULL,
    [Created_By]            NUMERIC (18)  NULL,
    [Created_Date]          DATETIME      NULL,
    [Modify_By]             NUMERIC (18)  NULL,
    [Modify_Date]           DATETIME      NULL,
    CONSTRAINT [PK_T0130_TS_Approval_Detail] PRIMARY KEY CLUSTERED ([TS_Approval_Detail_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_TS_Approval_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_TS_Approval_Detail_T0040_Task_Master] FOREIGN KEY ([Task_ID]) REFERENCES [dbo].[T0040_Task_Master] ([Task_ID]),
    CONSTRAINT [FK_T0130_TS_Approval_Detail_T0040_TS_Project_Master] FOREIGN KEY ([Project_ID]) REFERENCES [dbo].[T0040_TS_Project_Master] ([Project_ID]),
    CONSTRAINT [FK_T0130_TS_Approval_Detail_T0120_TS_Approval] FOREIGN KEY ([Timesheet_Approval_ID]) REFERENCES [dbo].[T0120_TS_Approval] ([Timesheet_Approval_ID])
);

