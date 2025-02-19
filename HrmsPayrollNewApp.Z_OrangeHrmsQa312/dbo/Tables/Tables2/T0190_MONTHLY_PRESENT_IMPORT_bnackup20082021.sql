CREATE TABLE [dbo].[T0190_MONTHLY_PRESENT_IMPORT_bnackup20082021] (
    [Tran_ID]              NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Emp_ID]               NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NOT NULL,
    [Month]                INT             NOT NULL,
    [Year]                 INT             NOT NULL,
    [For_Date]             DATETIME        NOT NULL,
    [P_Days]               NUMERIC (18, 2) NOT NULL,
    [Extra_Days]           NUMERIC (5, 1)  NOT NULL,
    [Extra_Day_Month]      NUMERIC (18)    NOT NULL,
    [Extra_Day_Year]       NUMERIC (18)    NOT NULL,
    [Cancel_Weekoff_Day]   NUMERIC (18)    NOT NULL,
    [Cancel_Holiday]       NUMERIC (18)    NOT NULL,
    [Over_Time]            NUMERIC (18, 2) NOT NULL,
    [Payble_Amount]        NUMERIC (18, 2) NOT NULL,
    [User_ID]              INT             NULL,
    [Time_Stamp]           DATETIME        NULL,
    [Backdated_Leave_Days] NUMERIC (18, 2) NOT NULL,
    [WO_OT_Hour]           NUMERIC (18, 2) NOT NULL,
    [HO_OT_Hour]           NUMERIC (18, 2) NOT NULL,
    [Present_on_holiday]   NUMERIC (18, 2) NOT NULL
);

