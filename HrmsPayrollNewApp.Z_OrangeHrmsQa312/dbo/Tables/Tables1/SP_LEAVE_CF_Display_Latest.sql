CREATE TABLE [dbo].[SP_LEAVE_CF_Display_Latest] (
    [LEAVE_CF_ID]                   NUMERIC (18)    NOT NULL,
    [Cmp_ID]                        NUMERIC (18)    NOT NULL,
    [Emp_ID]                        NUMERIC (18)    NOT NULL,
    [Leave_ID]                      NUMERIC (18)    NOT NULL,
    [CF_For_Date]                   DATETIME        NOT NULL,
    [CF_From_Date]                  DATETIME        NOT NULL,
    [CF_To_Date]                    DATETIME        NOT NULL,
    [CF_P_Days]                     NUMERIC (18, 2) NOT NULL,
    [CF_Leave_Days]                 NUMERIC (22, 8) NOT NULL,
    [CF_Type]                       VARCHAR (200)   NOT NULL,
    [Exceed_CF_Days]                NUMERIC (22, 8) NULL,
    [Leave_CompOff_Dates]           NVARCHAR (MAX)  NULL,
    [Is_Fnf]                        TINYINT         NOT NULL,
    [Advance_Leave_Balance]         NUMERIC (18, 2) CONSTRAINT [DF__SP_LEAVE___Advan__1CAFEBDC] DEFAULT ((0)) NOT NULL,
    [Advance_Leave_Recover_balance] NUMERIC (18, 2) CONSTRAINT [DF__SP_LEAVE___Advan__1DA41015] DEFAULT ((0)) NOT NULL,
    [Is_Advance_Leave_Balance]      TINYINT         CONSTRAINT [DF__SP_LEAVE___Is_Ad__1E98344E] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SP_LEAVE_CF_Display_Latest] PRIMARY KEY CLUSTERED ([LEAVE_CF_ID] ASC) WITH (FILLFACTOR = 95)
);

