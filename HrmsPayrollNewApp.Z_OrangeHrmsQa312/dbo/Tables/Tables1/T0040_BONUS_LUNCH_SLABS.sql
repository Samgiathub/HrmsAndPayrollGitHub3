CREATE TABLE [dbo].[T0040_BONUS_LUNCH_SLABS] (
    [Tran_ID]      INT             IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]       NUMERIC (18)    NULL,
    [For_Date]     DATETIME        NULL,
    [Emp_ID]       NUMERIC (18)    NULL,
    [Gender]       VARCHAR (10)    NULL,
    [Designation]  VARCHAR (500)   NULL,
    [FromTime]     NUMERIC (18, 2) NULL,
    [ToTime]       NUMERIC (18, 2) NULL,
    [Bonus_Amount] NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

