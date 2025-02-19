CREATE TABLE [dbo].[T0040_Sales_Week_Master] (
    [Week_Tran_ID]       NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]             NUMERIC (18) NULL,
    [W_Month]            INT          NOT NULL,
    [W_Year]             INT          NOT NULL,
    [Week_Order]         VARCHAR (20) NULL,
    [Week_st_date]       DATETIME     NULL,
    [Week_end_date]      DATETIME     NULL,
    [Total_days_in_week] INT          NULL,
    [Sorting_No]         INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_Sales_Week_Master] PRIMARY KEY CLUSTERED ([Week_Tran_ID] ASC)
);

