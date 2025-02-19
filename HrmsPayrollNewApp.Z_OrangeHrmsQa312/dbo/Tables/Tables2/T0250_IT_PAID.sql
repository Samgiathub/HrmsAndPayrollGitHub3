CREATE TABLE [dbo].[T0250_IT_PAID] (
    [IT_Paid_ID]            NUMERIC (18)  NOT NULL,
    [Cmp_ID]                NUMERIC (18)  NOT NULL,
    [For_Date]              DATETIME      NOT NULL,
    [IT_Tran_Year]          VARCHAR (12)  NOT NULL,
    [IT_Payment_Date]       DATETIME      NOT NULL,
    [IT_Challan_No]         VARCHAR (30)  NOT NULL,
    [IT_Acknowledgement_No] VARCHAR (30)  NOT NULL,
    [IT_Bank_Name]          VARCHAR (50)  NOT NULL,
    [IT_Bank_BSR_Code]      VARCHAR (20)  NOT NULL,
    [IT_Payment_Mode]       VARCHAR (10)  NOT NULL,
    [IT_Cheque_No]          VARCHAR (15)  NOT NULL,
    [IT_Amount]             NUMERIC (10)  NOT NULL,
    [IT_Interest_Amount]    NUMERIC (7)   NOT NULL,
    [IT_Other_Amount]       NUMERIC (7)   NOT NULL,
    [IT_Total_Amount]       NUMERIC (12)  NOT NULL,
    [IT_Comments]           VARCHAR (250) NOT NULL,
    [Login_ID]              NUMERIC (18)  NOT NULL,
    [System_Date]           DATETIME      NOT NULL,
    CONSTRAINT [PK_T0250_IT_PAID] PRIMARY KEY CLUSTERED ([IT_Paid_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0250_IT_PAID_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

