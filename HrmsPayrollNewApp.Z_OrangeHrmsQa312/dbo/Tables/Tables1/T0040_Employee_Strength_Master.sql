CREATE TABLE [dbo].[T0040_Employee_Strength_Master] (
    [Tran_Id]         NUMERIC (18) NOT NULL,
    [Cmp_Id]          NUMERIC (18) NULL,
    [Branch_Id]       NUMERIC (18) NULL,
    [Dept_Id]         NUMERIC (18) NULL,
    [Desig_Id]        NUMERIC (18) NULL,
    [Effective_Date]  DATETIME     NULL,
    [Strength]        NUMERIC (18) NULL,
    [Flag]            VARCHAR (3)  NULL,
    [Cat_ID]          NUMERIC (18) NULL,
    [Login_Id]        NUMERIC (18) NULL,
    [System_Datetime] DATETIME     NULL,
    CONSTRAINT [PK_T0040_Employee_Strength_Master] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

