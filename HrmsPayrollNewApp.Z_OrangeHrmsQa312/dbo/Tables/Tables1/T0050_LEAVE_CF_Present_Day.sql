CREATE TABLE [dbo].[T0050_LEAVE_CF_Present_Day] (
    [Tran_ID]                   NUMERIC (18)    NOT NULL,
    [Cmp_ID]                    NUMERIC (18)    NULL,
    [Effective_Date]            DATETIME        NULL,
    [Type_ID]                   NUMERIC (18)    NULL,
    [Leave_ID]                  NUMERIC (18)    NULL,
    [Present_Day]               NUMERIC (18, 2) NULL,
    [Leave_Again_Present_Day]   NUMERIC (18, 3) NULL,
    [Present_Day_Max_Limit]     NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Above_MaxLimit_P_Days]     NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Above_MaxLimit_Leave_Days] NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

