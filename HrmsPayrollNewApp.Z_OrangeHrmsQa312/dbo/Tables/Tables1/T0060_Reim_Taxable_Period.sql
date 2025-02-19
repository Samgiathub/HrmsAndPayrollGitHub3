CREATE TABLE [dbo].[T0060_Reim_Taxable_Period] (
    [Reim_Tax_ID] NUMERIC (18) NOT NULL,
    [AD_ID]       NUMERIC (18) NULL,
    [Cmp_ID]      NUMERIC (18) NULL,
    [Fin_Year]    VARCHAR (20) NULL,
    [From_Date]   DATETIME     NULL,
    [To_Date]     DATETIME     NULL,
    [Modify_Date] DATETIME     NULL,
    [Modify_By]   NUMERIC (18) NULL,
    [Ip_Address]  VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([Reim_Tax_ID] ASC)
);

