CREATE TABLE [dbo].[T0130_LTA_Jurney_Detail] (
    [LTA_J_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [emp_id]         NUMERIC (18)    NULL,
    [LM_App_ID]      NUMERIC (18)    NOT NULL,
    [JR_Date]        DATETIME        NULL,
    [From_Place]     VARCHAR (100)   NULL,
    [To_Place]       VARCHAR (100)   NULL,
    [Route]          VARCHAR (100)   NULL,
    [Mode_Of_Travel] VARCHAR (100)   NULL,
    [Fare]           NUMERIC (18, 2) NULL,
    [File_Name]      VARCHAR (100)   NULL,
    [LM_Apr_ID]      NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0130_LTA_Jurney_Detail] PRIMARY KEY CLUSTERED ([LTA_J_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_LTA_Jurney_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_LTA_Jurney_Detail_T0080_EMP_MASTER] FOREIGN KEY ([emp_id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0130_LTA_Jurney_Detail_T0110_LTA_Medical_Application] FOREIGN KEY ([LM_App_ID]) REFERENCES [dbo].[T0110_LTA_Medical_Application] ([LM_App_ID]),
    CONSTRAINT [FK_T0130_LTA_Jurney_Detail_T0120_LTA_Medical_Approval] FOREIGN KEY ([LM_Apr_ID]) REFERENCES [dbo].[T0120_LTA_Medical_Approval] ([LM_Apr_ID])
);

