CREATE TABLE [dbo].[T0100_LEAVE_APPLICATION] (
    [Leave_Application_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]                   NUMERIC (18)  NOT NULL,
    [Emp_ID]                   NUMERIC (18)  NOT NULL,
    [S_Emp_ID]                 NUMERIC (18)  NULL,
    [Application_Date]         DATETIME      NOT NULL,
    [Application_Code]         VARCHAR (20)  NOT NULL,
    [Application_Status]       CHAR (1)      NOT NULL,
    [Application_Comments]     VARCHAR (250) NOT NULL,
    [Login_ID]                 NUMERIC (18)  NOT NULL,
    [System_Date]              DATETIME      NOT NULL,
    [is_backdated_application] TINYINT       CONSTRAINT [DF_T0100_LEAVE_APPLICATION_is_backdated_application] DEFAULT ((0)) NOT NULL,
    [is_Responsibility_pass]   TINYINT       CONSTRAINT [DF_T0100_LEAVE_APPLICATION_is_Responsibility_pass] DEFAULT ((0)) NOT NULL,
    [Responsible_Emp_id]       NUMERIC (18)  NULL,
    [M_Cancel_WO_HO]           TINYINT       CONSTRAINT [DF_T0100_LEAVE_APPLICATION_M_Cancel_WO_HO] DEFAULT ((0)) NOT NULL,
    [Apply_From_AttReg]        TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_LEAVE_APPLICATION] PRIMARY KEY CLUSTERED ([Leave_Application_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_LEAVE_APPLICATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_LEAVE_APPLICATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_LEAVE_APPLICATION_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0100_LEAVE_APPLICATION_26_626101271__K1_K7_K3_K4_5_6_8_11_12_13]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Leave_Application_ID] ASC, [Application_Status] ASC, [Emp_ID] ASC, [S_Emp_ID] ASC)
    INCLUDE([Application_Date], [Application_Code], [Application_Comments], [is_backdated_application], [is_Responsibility_pass], [Responsible_Emp_id]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0100_LEAVE_APPLICATION_24_1333579789__K7_K3]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Application_Status] ASC, [Emp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0100_LEAVE_APPLICATION_9_626101271__K3_K4_K1_5_6_7_8_11_12_13]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID] ASC, [S_Emp_ID] ASC, [Leave_Application_ID] ASC)
    INCLUDE([Application_Date], [Application_Code], [Application_Status], [Application_Comments], [is_backdated_application], [is_Responsibility_pass], [Responsible_Emp_id]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0100_LEAVE_APPLICATION_8_626101271__K7_K1_K3_K4_5_6_11]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Application_Status] ASC, [Leave_Application_ID] ASC, [Emp_ID] ASC, [S_Emp_ID] ASC)
    INCLUDE([Application_Date], [Application_Code], [is_backdated_application]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_626101271_7_1]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Application_Status], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_626101271_3_7_1]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID], [Application_Status], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_626101271_3_1]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_626101271_3_4_7_1]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID], [S_Emp_ID], [Application_Status], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_626101271_1_3_4]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Leave_Application_ID], [Emp_ID], [S_Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1333579789_1_7_3]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Leave_Application_ID], [Application_Status], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1333579789_3_7]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID], [Application_Status]);


GO
CREATE STATISTICS [_dta_stat_1333579789_1_3]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Leave_Application_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_626101271_3_6_7_5_1]
    ON [dbo].[T0100_LEAVE_APPLICATION]([Emp_ID], [Application_Code], [Application_Status], [Application_Date], [Leave_Application_ID]);

