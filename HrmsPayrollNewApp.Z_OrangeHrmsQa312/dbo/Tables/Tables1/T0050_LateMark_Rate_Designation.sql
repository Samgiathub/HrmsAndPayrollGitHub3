CREATE TABLE [dbo].[T0050_LateMark_Rate_Designation] (
    [Tran_Id]     NUMERIC (18)    NOT NULL,
    [Gen_Id]      NUMERIC (18)    NOT NULL,
    [Cmp_Id]      NUMERIC (18)    NOT NULL,
    [Desig_Id]    NUMERIC (18)    NOT NULL,
    [Normal_Rate] NUMERIC (18, 2) NOT NULL,
    [Lunch_Rate]  NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_T0050_LateMark_Rate_Designation] PRIMARY KEY CLUSTERED ([Tran_Id] ASC)
);

