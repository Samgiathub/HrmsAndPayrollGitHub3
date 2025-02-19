CREATE TABLE [dbo].[T0100_IT_DECLARATION_COMPARE] (
    [IT_TRAN_ID]        NUMERIC (18)    NOT NULL,
    [CMP_ID]            NUMERIC (18)    NOT NULL,
    [IT_ID]             NUMERIC (18)    NOT NULL,
    [EMP_ID]            NUMERIC (18)    NOT NULL,
    [FOR_DATE]          DATETIME        NOT NULL,
    [AMOUNT]            NUMERIC (18, 2) NOT NULL,
    [DOC_NAME]          VARCHAR (200)   NOT NULL,
    [LOGIN_ID]          NUMERIC (18)    NULL,
    [SYSTEM_DATE]       DATETIME        NULL,
    [REPEAT_YEARLY]     TINYINT         NULL,
    [AMOUNT_ESS]        NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [IT_Flag]           TINYINT         DEFAULT ((0)) NOT NULL,
    [FINANCIAL_YEAR]    VARCHAR (20)    NULL,
    [Is_Lock]           BIT             DEFAULT ((0)) NOT NULL,
    [Is_Metro_NonMetro] VARCHAR (30)    NULL,
    [IsCompare_Flag]    VARCHAR (50)    NULL
);

