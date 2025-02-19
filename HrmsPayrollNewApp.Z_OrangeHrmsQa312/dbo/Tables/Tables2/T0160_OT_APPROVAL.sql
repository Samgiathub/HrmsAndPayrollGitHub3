CREATE TABLE [dbo].[T0160_OT_APPROVAL] (
    [Tran_ID]              NUMERIC (18)    NOT NULL,
    [Emp_ID]               NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NOT NULL,
    [For_Date]             DATETIME        NOT NULL,
    [Working_Sec]          NUMERIC (18, 2) NOT NULL,
    [OT_Sec]               NUMERIC (18, 2) NOT NULL,
    [Is_Approved]          TINYINT         NOT NULL,
    [Approved_OT_Sec]      NUMERIC (18, 2) NOT NULL,
    [Comments]             VARCHAR (250)   NOT NULL,
    [Login_ID]             NUMERIC (18)    NOT NULL,
    [System_Date]          DATETIME        NOT NULL,
    [Approved_OT_Hours]    VARCHAR (10)    NULL,
    [P_Days_Count]         NUMERIC (18, 2) NULL,
    [Is_Month_Wise]        TINYINT         NULL,
    [Weekoff_OT_Sec]       NUMERIC (18, 2) CONSTRAINT [DF_T0160_OT_APPROVAL_Weekoff_OT_Sec] DEFAULT ((0)) NULL,
    [Approved_WO_OT_Sec]   NUMERIC (18, 2) CONSTRAINT [DF_T0160_OT_APPROVAL_Approved_WO_OT_Sec] DEFAULT ((0)) NULL,
    [Approved_WO_OT_Hours] VARCHAR (10)    NULL,
    [Holiday_OT_Sec]       NUMERIC (18, 2) CONSTRAINT [DF_T0160_OT_APPROVAL_Holiday_OT_Sec] DEFAULT ((0)) NULL,
    [Approved_HO_OT_Sec]   NUMERIC (18, 2) CONSTRAINT [DF_T0160_OT_APPROVAL_Approved_HO_OT_Sec] DEFAULT ((0)) NULL,
    [Approved_HO_OT_Hours] VARCHAR (10)    NULL,
    [Remark]               VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0160_OT_APPROVAL] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0160_OT_APPROVAL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0160_OT_APPROVAL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0160_OT_Approval_Index]
    ON [dbo].[T0160_OT_APPROVAL]([Cmp_ID] ASC, [Emp_ID] ASC, [For_Date] ASC, [Is_Approved] ASC, [Is_Month_Wise] ASC) WITH (FILLFACTOR = 80);

