CREATE TABLE [dbo].[T0190_Production_Bonus_Variable_Import] (
    [Tran_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NOT NULL,
    [AD_ID]       NUMERIC (18)    NOT NULL,
    [Month]       INT             NOT NULL,
    [Year]        INT             NOT NULL,
    [Amount_Perc] NUMERIC (18, 2) NULL,
    [Comment]     VARCHAR (MAX)   NULL,
    [System_date] DATETIME        NOT NULL,
    [User_ID]     NCHAR (10)      NOT NULL,
    [IP_Address]  VARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_T0190_Production_Bonus_Variable_Import] PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK_T0190_Production_Bonus_Variable_Import_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0190_Production_Bonus_Variable_Import_T0190_Production_Bonus_Variable_Import] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID])
);

