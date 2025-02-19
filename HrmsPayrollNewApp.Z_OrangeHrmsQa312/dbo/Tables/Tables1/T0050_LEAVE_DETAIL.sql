CREATE TABLE [dbo].[T0050_LEAVE_DETAIL] (
    [Leave_ID]                            NUMERIC (18)    NOT NULL,
    [Row_ID]                              NUMERIC (18)    NOT NULL,
    [Grd_ID]                              NUMERIC (18)    NOT NULL,
    [Cmp_ID]                              NUMERIC (18)    NOT NULL,
    [Leave_Days]                          NUMERIC (18, 1) NOT NULL,
    [Bal_After_Encash]                    NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Bal_After_Encash] DEFAULT ((0)) NOT NULL,
    [Min_Leave_Encash]                    NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Min_Leave_Encash] DEFAULT ((0)) NOT NULL,
    [Max_Leave_Encash]                    NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_Leave_Encash] DEFAULT ((0)) NOT NULL,
    [Max_No_Of_Application]               NUMERIC (18)    CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_No_Of_Application] DEFAULT ((0)) NOT NULL,
    [L_Enc_Percentage_Of_Current_Balance] NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_L_Enc_Percentage_Of_Current_Balance] DEFAULT ((0)) NOT NULL,
    [Encash_Appli_After_month]            NUMERIC (18)    CONSTRAINT [DF_T0050_LEAVE_DETAIL_Encash_Appli_After_month] DEFAULT ((0)) NOT NULL,
    [Min_Leave_CF]                        NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Min_Leave_CF] DEFAULT ((0)) NOT NULL,
    [Max_Accumulate_Balance]              NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_Accumulate_Balance] DEFAULT ((0)) NOT NULL,
    [Min_Leave]                           NUMERIC (18, 2) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Min_Leave] DEFAULT ((0)) NOT NULL,
    [Max_Leave]                           NUMERIC (18, 2) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_Leave] DEFAULT ((0)) NOT NULL,
    [Notice_Period]                       NUMERIC (18)    CONSTRAINT [DF_T0050_LEAVE_DETAIL_Notice_Period] DEFAULT ((0)) NOT NULL,
    [Max_Leave_App]                       NUMERIC (18, 2) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_Leave_App] DEFAULT ((0)) NOT NULL,
    [After_Resuming_Duty]                 NUMERIC (18)    CONSTRAINT [DF_T0050_LEAVE_DETAIL_After_Resuming_Duty] DEFAULT ((0)) NOT NULL,
    [Max_CF_From_Last_Yr_Balance]         NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_Max_CF_From_Last_Yr_Balance] DEFAULT ((0)) NOT NULL,
    [Effect_Salary_Cycle]                 TINYINT         CONSTRAINT [DF_T0050_LEAVE_DETAIL_L_Effect_Salary_Cycle] DEFAULT ((0)) NOT NULL,
    [Monthly_Max_Leave]                   NUMERIC (18, 1) CONSTRAINT [DF_T0050_LEAVE_DETAIL_L_Monthly_Max_Leave] DEFAULT ((0)) NOT NULL,
    [Is_Probation]                        TINYINT         CONSTRAINT [DF_T0050_LEAVE_DETAIL_Is_Probation] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_LEAVE_DETAIL] PRIMARY KEY CLUSTERED ([Leave_ID] ASC, [Row_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_LEAVE_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_LEAVE_DETAIL_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID]),
    CONSTRAINT [FK_T0050_LEAVE_DETAIL_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_LEAVE_DETAIL_26_1605580758__K3_K1]
    ON [dbo].[T0050_LEAVE_DETAIL]([Grd_ID] ASC, [Leave_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_LEAVE_DETAIL_26_1605580758__K1_K3]
    ON [dbo].[T0050_LEAVE_DETAIL]([Leave_ID] ASC, [Grd_ID] ASC) WITH (FILLFACTOR = 80);

