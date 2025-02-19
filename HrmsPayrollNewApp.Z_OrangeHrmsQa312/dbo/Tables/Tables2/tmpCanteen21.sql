CREATE TABLE [dbo].[tmpCanteen21] (
    [EMP_ID]                   NUMERIC (18)    NOT NULL,
    [Total Lunch Count]        INT             NULL,
    [grd_id]                   NUMERIC (18)    NULL,
    [Extra Lunch]              INT             NULL,
    [Total Extra Lunch Amount] NUMERIC (29, 2) NULL,
    [GST Percent Lunch]        NUMERIC (18, 2) NULL,
    [GST Lunch Amount]         DECIMAL (10, 2) NULL,
    [Net Lunch Amount]         NUMERIC (30, 2) NULL
);

