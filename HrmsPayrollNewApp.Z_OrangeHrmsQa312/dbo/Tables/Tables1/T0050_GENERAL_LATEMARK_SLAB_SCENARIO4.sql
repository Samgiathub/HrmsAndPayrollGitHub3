CREATE TABLE [dbo].[T0050_GENERAL_LATEMARK_SLAB_SCENARIO4] (
    [Trans_ID]    NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NULL,
    [From_Min]    NUMERIC (18)    NULL,
    [To_Min]      NUMERIC (18)    NULL,
    [From_Count]  NUMERIC (18)    NULL,
    [To_Count]    NUMERIC (18)    NULL,
    [Deduction]   NUMERIC (18, 2) NULL,
    [Gen_ID]      NUMERIC (18)    NULL,
    [Modify_By]   NUMERIC (18)    NULL,
    [Modify_Date] DATETIME        NULL,
    [Ip_Address]  VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC)
);

