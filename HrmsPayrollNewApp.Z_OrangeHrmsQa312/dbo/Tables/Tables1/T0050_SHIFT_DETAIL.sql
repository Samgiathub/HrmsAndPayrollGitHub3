CREATE TABLE [dbo].[T0050_SHIFT_DETAIL] (
    [Shift_Tran_ID]        NUMERIC (18)    NOT NULL,
    [Shift_ID]             NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NOT NULL,
    [From_Hour]            NUMERIC (18, 2) NULL,
    [To_Hour]              NUMERIC (18, 2) NULL,
    [Minimum_Hour]         NUMERIC (5, 2)  NOT NULL,
    [Calculate_Days]       NUMERIC (5, 2)  NULL,
    [OT_Applicable]        NUMERIC (1)     NOT NULL,
    [Fix_OT_Hours]         NUMERIC (5, 1)  CONSTRAINT [DF_T0050_SHIFT_DETAIL_Fix_OT_Hours] DEFAULT ((0)) NULL,
    [Fix_W_Hours]          NUMERIC (5, 2)  CONSTRAINT [DF_T0050_SHIFT_DETAIL_Fix_W_Hours] DEFAULT ((0)) NULL,
    [OT_Start_Time]        TINYINT         NULL,
    [Rate]                 NUMERIC (18)    NULL,
    [OT_End_Time]          TINYINT         CONSTRAINT [DF_T0050_SHIFT_DETAIL_OT_End_Time] DEFAULT ((0)) NOT NULL,
    [Working_Hrs_End_Time] TINYINT         CONSTRAINT [DF_T0050_SHIFT_DETAIL_Working_Hrs_End_Time] DEFAULT ((0)) NOT NULL,
    [Working_Hrs_St_Time]  TINYINT         CONSTRAINT [DF_T0050_SHIFT_DETAIL_Working_Hrs_St_Time] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_SHIFT_DETAIL] PRIMARY KEY CLUSTERED ([Shift_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_SHIFT_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_SHIFT_DETAIL_T0040_SHIFT_MASTER] FOREIGN KEY ([Shift_ID]) REFERENCES [dbo].[T0040_SHIFT_MASTER] ([Shift_ID])
);

