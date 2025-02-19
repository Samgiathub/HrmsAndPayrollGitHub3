CREATE TABLE [dbo].[T0060_Reim_Quarter_Period_Clone] (
    [Tran_ID]            NUMERIC (18) NOT NULL,
    [Reim_Quar_ID]       NUMERIC (18) NULL,
    [AD_ID]              NUMERIC (18) NULL,
    [Cmp_ID]             NUMERIC (18) NULL,
    [Fin_Year]           VARCHAR (20) NULL,
    [Quarter_Name]       VARCHAR (50) NULL,
    [From_Date]          DATETIME     NULL,
    [To_Date]            DATETIME     NULL,
    [Claim_Upto_Date]    DATETIME     NULL,
    [Modify_Date]        DATETIME     NULL,
    [Modify_By]          NUMERIC (18) NULL,
    [Ip_Address]         VARCHAR (20) NULL,
    [Is_Taxable_Quarter] BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

