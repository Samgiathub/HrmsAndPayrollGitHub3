CREATE TABLE [dbo].[T0045_INCENTIVE_DETAIL] (
    [Row_Id]         NUMERIC (18)    NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Inc_Tran_ID]    NUMERIC (18)    NOT NULL,
    [From_Slab]      NUMERIC (18, 2) NULL,
    [To_Slab]        NUMERIC (18, 2) NULL,
    [Slab_Value]     NUMERIC (18, 2) NULL,
    [Incentive_Name] VARCHAR (100)   NULL,
    [Slab_Type]      TINYINT         NULL,
    [Calc_Type]      VARCHAR (100)   NULL,
    [Calc_ON]        VARCHAR (100)   NULL,
    [Incentive_For]  VARCHAR (50)    NULL,
    CONSTRAINT [FK_T0045_INCENTIVE_DETAIL_T0040_INCENTIVE_MASTER] FOREIGN KEY ([Inc_Tran_ID]) REFERENCES [dbo].[T0040_INCENTIVE_MASTER] ([Inc_Tran_ID])
);

