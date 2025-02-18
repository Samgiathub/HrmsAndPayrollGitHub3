﻿CREATE TABLE [dbo].[T0100_KPIPMS_Objective_Level] (
    [Row_Id]    NUMERIC (18)  NOT NULL,
    [Cmp_Id]    NUMERIC (18)  NULL,
    [Tran_Id]   NUMERIC (18)  NULL,
    [KPIObj_ID] NUMERIC (18)  NULL,
    [Status]    VARCHAR (250) NULL,
    CONSTRAINT [PK_T0100_KPIPMS_Objective_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_KPIPMS_Objective_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_KPIPMS_Objective_Level_T0080_KPIObjectives] FOREIGN KEY ([KPIObj_ID]) REFERENCES [dbo].[T0080_KPIObjectives] ([KPIObj_ID]),
    CONSTRAINT [FK_T0100_KPIPMS_Objective_Level_T0090_KPIPMS_EVAL_Approval] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0090_KPIPMS_EVAL_Approval] ([Tran_Id])
);

