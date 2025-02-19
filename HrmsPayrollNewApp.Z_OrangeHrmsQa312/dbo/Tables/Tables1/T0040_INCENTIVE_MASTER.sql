CREATE TABLE [dbo].[T0040_INCENTIVE_MASTER] (
    [Inc_Tran_ID]    NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]         NUMERIC (18)  NOT NULL,
    [Incentive_Name] VARCHAR (100) NOT NULL,
    [Slab_Type]      TINYINT       NOT NULL,
    [Calc_Type]      VARCHAR (100) NOT NULL,
    [Calc_ON]        VARCHAR (100) NULL,
    [Incentive_For]  VARCHAR (100) NULL,
    [Login_Id]       NUMERIC (18)  NULL,
    [System_Date]    DATETIME      NULL,
    CONSTRAINT [PK_T0040_INCENTIVE_MASTER] PRIMARY KEY CLUSTERED ([Inc_Tran_ID] ASC)
);

