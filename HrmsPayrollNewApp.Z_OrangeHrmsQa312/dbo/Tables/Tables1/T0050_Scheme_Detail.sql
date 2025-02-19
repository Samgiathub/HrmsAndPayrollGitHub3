CREATE TABLE [dbo].[T0050_Scheme_Detail] (
    [Scheme_Detail_Id]                   NUMERIC (18)  NOT NULL,
    [Scheme_Id]                          NUMERIC (18)  NOT NULL,
    [Cmp_Id]                             NUMERIC (18)  NOT NULL,
    [Leave]                              VARCHAR (MAX) NOT NULL,
    [R_Cmp_Id]                           NUMERIC (18)  NULL,
    [R_Desg_Id]                          NUMERIC (18)  NULL,
    [Is_RM]                              TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_RM] DEFAULT ((0)) NOT NULL,
    [Is_BM]                              TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_BM] DEFAULT ((0)) NOT NULL,
    [App_Emp_ID]                         NUMERIC (18)  NULL,
    [Leave_Days]                         NUMERIC (18)  CONSTRAINT [DF_T0050_Scheme_Detail_Leave_Days] DEFAULT ((0)) NULL,
    [Is_Fwd_Leave_Rej]                   TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_Fwd_Leave_Rej] DEFAULT ((0)) NOT NULL,
    [Rpt_Level]                          TINYINT       NOT NULL,
    [TimeStamp]                          DATETIME      NOT NULL,
    [not_mandatory]                      TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_not_mandatory] DEFAULT ((0)) NOT NULL,
    [Approval_Overlimit_Travel_Settlmnt] TINYINT       CONSTRAINT [DF__T0050_Sch__Appro__7DEF6EAB] DEFAULT ((0)) NOT NULL,
    [Is_HOD]                             TINYINT       CONSTRAINT [DF__T0050_Sch__Is_HO__73E87832] DEFAULT ((0)) NOT NULL,
    [Is_HR]                              TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_HR] DEFAULT ((0)) NOT NULL,
    [Is_PRM]                             TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_PRM] DEFAULT ((0)) NOT NULL,
    [Is_RMToRM]                          TINYINT       CONSTRAINT [DF__T0050_Sch__Is_RM__535E40DE] DEFAULT ((0)) NOT NULL,
    [Is_Intimation]                      TINYINT       CONSTRAINT [DF__T0050_Sch__Is_In__14FE2020] DEFAULT ((0)) NOT NULL,
    [Dyn_Hier_Id]                        NUMERIC (18)  NULL,
    [Is_IT]                              TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_IT] DEFAULT ((0)) NOT NULL,
    [Is_Account]                         TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_Account] DEFAULT ((0)) NOT NULL,
    [Is_TravelHelpDesk]                  TINYINT       CONSTRAINT [DF_T0050_Scheme_Detail_Is_TravelHelpDesk] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_Scheme_Detail] PRIMARY KEY CLUSTERED ([Scheme_Detail_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_Scheme_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_Scheme_Detail_T0040_Scheme_Master] FOREIGN KEY ([Scheme_Id]) REFERENCES [dbo].[T0040_Scheme_Master] ([Scheme_Id])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_Scheme_Detail_11_400824590__K2_K11_K7_K12_4]
    ON [dbo].[T0050_Scheme_Detail]([Scheme_Id] ASC, [Is_Fwd_Leave_Rej] ASC, [Is_RM] ASC, [Rpt_Level] ASC)
    INCLUDE([Leave]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_Scheme_Detail_8_400824590__K2_K1_K11_K12_K10_4_7_8_9]
    ON [dbo].[T0050_Scheme_Detail]([Scheme_Id] ASC, [Scheme_Detail_Id] ASC, [Is_Fwd_Leave_Rej] ASC, [Rpt_Level] ASC, [Leave_Days] ASC)
    INCLUDE([Leave], [Is_RM], [Is_BM], [App_Emp_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_Scheme_Detail_8_400824590__K12_K9_K2_K1_K11_K7_K10_4]
    ON [dbo].[T0050_Scheme_Detail]([Rpt_Level] ASC, [App_Emp_ID] ASC, [Scheme_Id] ASC, [Scheme_Detail_Id] ASC, [Is_Fwd_Leave_Rej] ASC, [Is_RM] ASC, [Leave_Days] ASC)
    INCLUDE([Leave]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_Scheme_Detail_8_400824590__K12_K8_K2_K1_K11_K10_4]
    ON [dbo].[T0050_Scheme_Detail]([Rpt_Level] ASC, [Is_BM] ASC, [Scheme_Id] ASC, [Scheme_Detail_Id] ASC, [Is_Fwd_Leave_Rej] ASC, [Leave_Days] ASC)
    INCLUDE([Leave]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_Scheme_Detail_8_400824590__K2_K11_K12_K10_4]
    ON [dbo].[T0050_Scheme_Detail]([Scheme_Id] ASC, [Is_Fwd_Leave_Rej] ASC, [Rpt_Level] ASC, [Leave_Days] ASC)
    INCLUDE([Leave]) WITH (FILLFACTOR = 80);

