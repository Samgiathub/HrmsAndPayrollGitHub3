CREATE TABLE [dbo].[T0050_Sales_TTP_Income] (
    [Tran_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NULL,
    [Emp_ID]      NUMERIC (18)    NULL,
    [For_Date]    DATETIME        NULL,
    [MF]          NUMERIC (18, 2) NULL,
    [Insurance]   NUMERIC (18, 2) NULL,
    [Other]       NUMERIC (18, 2) NULL,
    [Modify_date] DATETIME        NULL,
    [Modify_by]   VARCHAR (10)    NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

