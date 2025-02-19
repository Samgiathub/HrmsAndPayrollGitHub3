CREATE TABLE [dbo].[tmpCanteen12] (
    [EMP_ID]                        NUMERIC (18)    NOT NULL,
    [Total Tea/Coffee Count]        INT             NULL,
    [grd_id]                        NUMERIC (18)    NULL,
    [Extra Tea/Coffee]              INT             NULL,
    [Total Extra Tea/Coffee Amount] NUMERIC (29, 2) NULL,
    [GST Percent Tea/Coffee]        NUMERIC (18, 2) NULL,
    [GST Tea/Coffee Amount]         DECIMAL (10, 2) NULL,
    [Net Tea/Coffee Amount]         NUMERIC (30, 2) NULL
);

