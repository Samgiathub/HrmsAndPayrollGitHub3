CREATE TABLE [dbo].[T0040_LM_SETTING] (
    [Row_ID]          NUMERIC (18)    NULL,
    [Cmp_ID]          NUMERIC (18)    NULL,
    [Branch_id]       NUMERIC (18)    NULL,
    [for_Date]        DATETIME        NULL,
    [start_date]      DATETIME        NULL,
    [end_date]        DATETIME        NULL,
    [Max_limit]       NUMERIC (18, 2) NULL,
    [Type_ID]         INT             NULL,
    [Effective_month] VARCHAR (20)    NULL,
    [Effect_on_CTC]   INT             NULL,
    [Cal_amount_Type] INT             NULL,
    [Show_Yearly]     INT             NULL
);

