CREATE TABLE [dbo].[T0050_GENERAL_OT_RATE_SLABWISE] (
    [Tran_Id]    INT            NOT NULL,
    [Cmp_id]     NUMERIC (18)   NOT NULL,
    [Gen_ID]     NUMERIC (18)   NOT NULL,
    [From_Hours] NUMERIC (9, 2) NOT NULL,
    [To_Hours]   NUMERIC (9, 2) NOT NULL,
    [WD_Rate]    NUMERIC (9, 4) NOT NULL,
    [WO_Rate]    NUMERIC (9, 4) NULL,
    [HO_Rate]    NUMERIC (9, 4) NULL,
    [SystemDate] DATETIME       NULL
);

