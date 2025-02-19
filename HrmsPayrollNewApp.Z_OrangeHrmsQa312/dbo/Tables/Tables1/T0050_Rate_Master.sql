CREATE TABLE [dbo].[T0050_Rate_Master] (
    [Rate_Id]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Emp_ID]         NUMERIC (18) NULL,
    [Cmp_ID]         NUMERIC (18) NULL,
    [Product_ID]     NUMERIC (18) NULL,
    [SubProduct_ID]  NUMERIC (18) NULL,
    [Effective_date] DATETIME     NULL,
    [Login_Id]       NUMERIC (18) NULL,
    [System_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0050_Rate_Master] PRIMARY KEY CLUSTERED ([Rate_Id] ASC)
);

