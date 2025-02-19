CREATE TABLE [dbo].[T0140_MONTHLY_LATEMARK_TRANSACTION] (
    [TRAN_ID]             NUMERIC (18)    NOT NULL,
    [SAL_TRAN_ID]         NUMERIC (18)    NULL,
    [CMP_ID]              NUMERIC (18)    NULL,
    [EMP_ID]              NUMERIC (18)    NULL,
    [LATE_MIN]            VARCHAR (50)    NULL,
    [LATE_SEC]            NUMERIC (18)    NULL,
    [FOR_DATE]            DATETIME        NULL,
    [LATE_CAL_ON_PERCENT] NUMERIC (18, 2) NULL,
    [LATE_CALC_ON_AMT]    NUMERIC (18, 2) NULL,
    [LATE_AMOUNT]         NUMERIC (18, 2) NULL,
    [LATE_LIMIT]          VARCHAR (50)    NULL,
    [SHIFT_ID]            NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [SHIFT_NAME]          VARCHAR (200)   NULL,
    [IN_TIME]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([TRAN_ID] ASC)
);

