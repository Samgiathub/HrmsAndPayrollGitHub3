CREATE TABLE [dbo].[T0500_MutualFund] (
    [Tran_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]       NUMERIC (18)    NULL,
    [Trn_Date]     DATETIME        NULL,
    [Emp_Code]     VARCHAR (100)   NULL,
    [Client_code]  VARCHAR (100)   NULL,
    [No_of_SIP]    NUMERIC (18, 2) NULL,
    [SIP_AUM]      NUMERIC (18, 2) NULL,
    [No_of_Lumsum] NUMERIC (18, 2) NULL,
    [Lumsum_AUM]   NUMERIC (18, 2) NULL,
    [Total_No]     NUMERIC (18, 2) NULL,
    [Total_Aum]    NUMERIC (18, 2) NULL,
    [Income]       NUMERIC (18, 2) NULL,
    [UserID]       NUMERIC (18)    NULL,
    [Modify_Date]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

