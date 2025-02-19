CREATE TABLE [dbo].[T0040_PAY_SCALE_MASTER] (
    [Pay_Scale_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NULL,
    [Pay_Scale_Name]   VARCHAR (500) NULL,
    [Pay_Scale_Detail] VARCHAR (MAX) NULL,
    [Systemdate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Pay_Scale_ID] ASC) WITH (FILLFACTOR = 80)
);

