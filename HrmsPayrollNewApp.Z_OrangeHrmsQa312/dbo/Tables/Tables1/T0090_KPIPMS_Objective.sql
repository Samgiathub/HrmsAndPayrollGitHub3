﻿CREATE TABLE [dbo].[T0090_KPIPMS_Objective] (
    [KPIPMS_ObjID] NUMERIC (18)  NOT NULL,
    [Cmp_Id]       NUMERIC (18)  NULL,
    [KPIPMS_ID]    NUMERIC (18)  NULL,
    [KPIObj_ID]    NUMERIC (18)  NULL,
    [Emp_ID]       NUMERIC (18)  NULL,
    [Status]       VARCHAR (250) NULL,
    CONSTRAINT [PK_T0090_KPIPMS_Objective] PRIMARY KEY CLUSTERED ([KPIPMS_ObjID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_KPIPMS_Objective_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_KPIPMS_Objective_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0090_KPIPMS_Objective_T0080_KPIObjectives] FOREIGN KEY ([KPIObj_ID]) REFERENCES [dbo].[T0080_KPIObjectives] ([KPIObj_ID]),
    CONSTRAINT [FK_T0090_KPIPMS_Objective_T0080_KPIPMS_EVAL] FOREIGN KEY ([KPIPMS_ID]) REFERENCES [dbo].[T0080_KPIPMS_EVAL] ([KPIPMS_ID])
);

