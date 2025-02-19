CREATE TABLE [dbo].[T0140_MONTHLY_EARLYMARK_TRANSACTION] (
    [TRAN_ID]              NUMERIC (18)    NOT NULL,
    [SAL_TRAN_ID]          NUMERIC (18)    NULL,
    [CMP_ID]               NUMERIC (18)    NULL,
    [EMP_ID]               NUMERIC (18)    NULL,
    [EARLY_MIN]            VARCHAR (50)    NULL,
    [EARLY_SEC]            NUMERIC (18)    NULL,
    [FOR_DATE]             DATETIME        NULL,
    [EARLY_CAL_ON_PERCENT] NUMERIC (18, 2) NULL,
    [EARLY_CALC_ON_AMT]    NUMERIC (18, 2) NULL,
    [EARLY_AMOUNT]         NUMERIC (18, 2) NULL,
    [EARLY_LIMIT]          VARCHAR (50)    NULL,
    [SHIFT_ID]             NUMERIC (18)    NOT NULL,
    [SHIFT_NAME]           VARCHAR (200)   NULL,
    [OUT_TIME]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([TRAN_ID] ASC)
);

