CREATE TABLE [dbo].[T0055_INCENTIVE_SCHEME_INC] (
    [Scheme_ID]      NUMERIC (18)    NOT NULL,
    [Row_ID]         NUMERIC (18)    NOT NULL,
    [Inc_Tran_ID]    NUMERIC (18)    NOT NULL,
    [Incentive_Name] VARCHAR (MAX)   NOT NULL,
    [Slab_Type]      TINYINT         NOT NULL,
    [Calc_Type]      VARCHAR (100)   NOT NULL,
    [Calc_ON]        VARCHAR (100)   NOT NULL,
    [From_Slab]      NUMERIC (18, 2) NOT NULL,
    [To_Slab]        NUMERIC (18, 2) NOT NULL,
    [Slab_Value]     NUMERIC (18, 2) NOT NULL,
    [Consider_Para]  VARCHAR (100)   NULL,
    [Incentive_For]  VARCHAR (50)    NULL
);

