CREATE TABLE [dbo].[T0115_Leave_Level_Approval] (
    [Tran_ID]                NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NOT NULL,
    [Leave_Application_ID]   NUMERIC (18)    NOT NULL,
    [Emp_ID]                 NUMERIC (18)    NOT NULL,
    [Leave_ID]               NUMERIC (18)    NOT NULL,
    [From_Date]              DATETIME        NOT NULL,
    [To_Date]                DATETIME        NOT NULL,
    [Leave_Period]           NUMERIC (18, 2) NOT NULL,
    [Leave_Assign_As]        VARCHAR (15)    NOT NULL,
    [Leave_Reason]           VARCHAR (100)   NOT NULL,
    [M_Cancel_WO_HO]         TINYINT         NOT NULL,
    [Half_Leave_Date]        DATETIME        NULL,
    [S_Emp_ID]               NUMERIC (18)    NOT NULL,
    [Approval_Date]          DATETIME        NOT NULL,
    [Approval_Status]        CHAR (1)        NOT NULL,
    [Approval_Comments]      VARCHAR (250)   NOT NULL,
    [Rpt_Level]              TINYINT         NOT NULL,
    [System_Date]            DATETIME        NOT NULL,
    [is_Responsibility_pass] TINYINT         CONSTRAINT [DF_T0115_Leave_Level_Approval_is_Responsibility_pass] DEFAULT ((0)) NOT NULL,
    [Responsible_Emp_id]     NUMERIC (18)    NULL,
    [is_Arrear]              NUMERIC (18)    CONSTRAINT [DF_T0115_Leave_Level_Approval_is_Arrear] DEFAULT ((0)) NOT NULL,
    [arrear_month]           NUMERIC (18)    CONSTRAINT [DF_T0115_Leave_Level_Approval_arrear_month] DEFAULT ((0)) NOT NULL,
    [arrear_year]            NUMERIC (18)    CONSTRAINT [DF_T0115_Leave_Level_Approval_arrear_year] DEFAULT ((0)) NOT NULL,
    [Leave_out_time]         DATETIME        NULL,
    [Leave_In_Time]          DATETIME        NULL,
    [Leave_CompOff_dates]    VARCHAR (MAX)   NULL,
    [Half_Payment]           TINYINT         CONSTRAINT [DF_T0115_Leave_Level_Approval_Half_Payment] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0115_Leave_Level_Approval] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0115_Leave_Level_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_Leave_Level_Approval_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0115_Leave_Level_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0115_Leave_Level_Approval_T0100_LEAVE_APPLICATION] FOREIGN KEY ([Leave_Application_ID]) REFERENCES [dbo].[T0100_LEAVE_APPLICATION] ([Leave_Application_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0115_Leave_Level_Approval_26_589349264__K1_K3]
    ON [dbo].[T0115_Leave_Level_Approval]([Tran_ID] ASC, [Leave_Application_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0115_Leave_Level_Approval_26_589349264__K15_K5_K3_K4_K1]
    ON [dbo].[T0115_Leave_Level_Approval]([Approval_Status] ASC, [Leave_ID] ASC, [Leave_Application_ID] ASC, [Emp_ID] ASC, [Tran_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0115_Leave_Level_Approval_8_589349264__K3_K1_K17_5_6_7_8_11]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_Application_ID] ASC, [Tran_ID] ASC, [Rpt_Level] ASC)
    INCLUDE([Leave_ID], [From_Date], [To_Date], [Leave_Period], [M_Cancel_WO_HO]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0115_Leave_Level_Approval_8_589349264__K3D_K17D_5_6_7_8_11]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_Application_ID] DESC, [Rpt_Level] DESC)
    INCLUDE([Leave_ID], [From_Date], [To_Date], [Leave_Period], [M_Cancel_WO_HO]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_589349264_4_1_5]
    ON [dbo].[T0115_Leave_Level_Approval]([Emp_ID], [Tran_ID], [Leave_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_3_4_5_15]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_Application_ID], [Emp_ID], [Leave_ID], [Approval_Status]);


GO
CREATE STATISTICS [_dta_stat_589349264_5_15_3]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_ID], [Approval_Status], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_5_15_1_3_4]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_ID], [Approval_Status], [Tran_ID], [Leave_Application_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_3_4_1_5]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_Application_ID], [Emp_ID], [Tran_ID], [Leave_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_3_1_5]
    ON [dbo].[T0115_Leave_Level_Approval]([Leave_Application_ID], [Tran_ID], [Leave_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_1_5_15_4]
    ON [dbo].[T0115_Leave_Level_Approval]([Tran_ID], [Leave_ID], [Approval_Status], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_17_1]
    ON [dbo].[T0115_Leave_Level_Approval]([Rpt_Level], [Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_17_3]
    ON [dbo].[T0115_Leave_Level_Approval]([Rpt_Level], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_589349264_1_3_17]
    ON [dbo].[T0115_Leave_Level_Approval]([Tran_ID], [Leave_Application_ID], [Rpt_Level]);

