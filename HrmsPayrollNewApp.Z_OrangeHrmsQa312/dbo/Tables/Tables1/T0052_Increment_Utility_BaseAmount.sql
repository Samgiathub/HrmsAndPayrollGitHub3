CREATE TABLE [dbo].[T0052_Increment_Utility_BaseAmount] (
    [BaseAmt_Id]    NUMERIC (18)    NOT NULL,
    [Cmp_Id]        NUMERIC (18)    NULL,
    [EffectiveDate] DATETIME        NULL,
    [Segment_ID]    NUMERIC (18)    NULL,
    [Grd_Id]        NUMERIC (18)    NULL,
    [desig_Id]      NUMERIC (18)    NULL,
    [Branch_Id]     NUMERIC (18)    NULL,
    [dept_Id]       NUMERIC (18)    NULL,
    [Amount]        NUMERIC (18, 2) NULL,
    [Percentage]    NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0052_Increment_Utility_BaseAmount] PRIMARY KEY CLUSTERED ([BaseAmt_Id] ASC)
);

