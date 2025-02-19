CREATE TABLE [dbo].[T0040_OT_HRS_CNV] (
    [NOID]           INT             IDENTITY (1, 1) NOT NULL,
    [Effective_Date] DATETIME        NOT NULL,
    [Actual_HRS]     NUMERIC (18, 6) NULL,
    [Below_HRS]      NUMERIC (18, 6) NULL,
    [Above_HRS]      NUMERIC (18, 6) NULL,
    [Limit]          NUMERIC (18, 2) NULL,
    [Cmp_ID]         INT             NULL,
    CONSTRAINT [PK_T0040_OT_HRS_CNV] PRIMARY KEY CLUSTERED ([NOID] ASC) WITH (FILLFACTOR = 80)
);

