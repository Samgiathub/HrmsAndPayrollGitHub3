CREATE TABLE [dbo].[T0040_LOAN_MASTER] (
    [Loan_ID]                            NUMERIC (18)    NOT NULL,
    [Cmp_ID]                             NUMERIC (18)    NOT NULL,
    [Loan_Name]                          VARCHAR (100)   NOT NULL,
    [Loan_Max_Limit]                     NUMERIC (18)    NOT NULL,
    [Loan_Comments]                      VARCHAR (250)   NOT NULL,
    [Company_Loan]                       TINYINT         NULL,
    [Max_Limit_on_Basic_Gross]           TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Max_Limit_on_Basic_Gross] DEFAULT ((0)) NOT NULL,
    [Allowance_Id_String_Max_Limit]      VARCHAR (MAX)   NULL,
    [No_Of_Times]                        NUMERIC (9, 2)  CONSTRAINT [DF_T0040_Loan_Master_No_Of_Times] DEFAULT ((1)) NULL,
    [Loan_Guarantor]                     TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Loan_Guarantor] DEFAULT ((0)) NOT NULL,
    [Desig_max_limit]                    TINYINT         NULL,
    [Is_Interest_Subsidy_Limit]          TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Is_Interest_Subsidy_Max_Limit] DEFAULT ((0)) NOT NULL,
    [Interest_Recovery_Per]              NUMERIC (18, 2) CONSTRAINT [DF_T0040_LOAN_MASTER_Interest_Recovery_Per] DEFAULT ((0)) NOT NULL,
    [Subsidy_Desig_Id_String]            VARCHAR (MAX)   NULL,
    [Loan_Interest_Type]                 VARCHAR (20)    NULL,
    [Loan_Interest_Per]                  NUMERIC (18, 4) CONSTRAINT [DF_T0040_LOAN_MASTER_Loan_Interest_Per] DEFAULT ((0)) NOT NULL,
    [Is_attachment]                      TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Is_attachment] DEFAULT ((0)) NOT NULL,
    [Is_Eligible]                        TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Is_Eligible] DEFAULT ((0)) NOT NULL,
    [Eligible_Days]                      NUMERIC (18)    CONSTRAINT [DF_T0040_LOAN_MASTER_Eligible_Days] DEFAULT ((0)) NOT NULL,
    [Subsidy_Bond_Days]                  NUMERIC (18, 2) CONSTRAINT [DF_T0040_LOAN_MASTER_Subsidy_Bond_Days] DEFAULT ((0)) NOT NULL,
    [Is_GPF]                             TINYINT         CONSTRAINT [DF__T0040_LOA__Is_GP__0C5990E0] DEFAULT ((0)) NOT NULL,
    [GPF_Eligible_Month]                 NUMERIC (18)    CONSTRAINT [DF__T0040_LOA__GPF_E__0D4DB519] DEFAULT ((0)) NOT NULL,
    [GPF_days_diff_application]          NUMERIC (18)    CONSTRAINT [DF__T0040_LOA__GPF_d__0E41D952] DEFAULT ((0)) NOT NULL,
    [GPF_Max_Loan_per]                   NUMERIC (18)    CONSTRAINT [DF__T0040_LOA__GPF_M__0F35FD8B] DEFAULT ((0)) NOT NULL,
    [Is_Principal_First_than_Int]        TINYINT         CONSTRAINT [DF__T0040_LOA__Is_Pr__102A21C4] DEFAULT ((0)) NOT NULL,
    [Loan_Guarantor2]                    NUMERIC (18)    CONSTRAINT [DF_T0040_LOAN_MASTER_Loan_Guarantor2] DEFAULT ((0)) NOT NULL,
    [Is_Grade_Wise]                      NUMERIC (5)     CONSTRAINT [DF__T0040_LOA__Is_Gr__3C273AAF] DEFAULT ((0)) NOT NULL,
    [Grade_Details]                      VARCHAR (500)   NULL,
    [Loan_Short_Name]                    VARCHAR (50)    NULL,
    [Is_Subsidy_Loan]                    TINYINT         CONSTRAINT [DF_T0040_LOAN_MASTER_Is_Subsidy_Loan] DEFAULT ((0)) NOT NULL,
    [Subsidy_Bond_Month]                 NUMERIC (18, 2) CONSTRAINT [DF_T0040_LOAN_MASTER_Subsidy_Bond_Month] DEFAULT ((0)) NOT NULL,
    [Is_Intrest_Amount_As_Perquisite_IT] TINYINT         NULL,
    [Gujarati_Alias]                     NVARCHAR (500)  NULL,
    [Hide_Loan_Max_Amount]               NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Loan_Application_Reason_Required]   BIT             DEFAULT ((0)) NOT NULL,
    [Max_Installment]                    NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [IsContractDue]                      INT             NULL,
    [ContractDueDays]                    INT             NULL,
    CONSTRAINT [PK_T0040_LOAN_MASTER] PRIMARY KEY CLUSTERED ([Loan_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_LOAN_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);


GO
CREATE STATISTICS [No_Of_Times]
    ON [dbo].[T0040_LOAN_MASTER]([No_Of_Times]);

