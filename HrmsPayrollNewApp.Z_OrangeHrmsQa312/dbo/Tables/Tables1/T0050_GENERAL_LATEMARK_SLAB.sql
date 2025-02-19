CREATE TABLE [dbo].[T0050_GENERAL_LATEMARK_SLAB] (
    [TRANS_ID]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [CMP_ID]             NUMERIC (18)    NULL,
    [FROM_MIN]           NUMERIC (18)    NULL,
    [TO_MIN]             NUMERIC (18)    NULL,
    [EXEMPTION_COUNT]    NUMERIC (18)    NULL,
    [DEDUCTION]          NUMERIC (18, 2) NULL,
    [DEDUCTION_TYPE]     VARCHAR (20)    NULL,
    [GEN_ID]             NUMERIC (18)    NULL,
    [ONE_TIME_EXEMPTION] NUMERIC (2)     NOT NULL
);

