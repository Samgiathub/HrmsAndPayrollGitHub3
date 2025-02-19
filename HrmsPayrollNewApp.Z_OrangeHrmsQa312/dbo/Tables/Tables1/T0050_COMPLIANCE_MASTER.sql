CREATE TABLE [dbo].[T0050_COMPLIANCE_MASTER] (
    [Compliance_ID]             NUMERIC (18)  NOT NULL,
    [Cmp_ID]                    NUMERIC (18)  NOT NULL,
    [Compliance_Name]           VARCHAR (100) NOT NULL,
    [Compliance_Code]           VARCHAR (100) NOT NULL,
    [Compliance_Year_Type]      TINYINT       NOT NULL,
    [Compliance_Submition_Type] INT           NULL,
    [Updated_Date]              DATETIME      NULL,
    [Compliance_View_IN_Dash]   TINYINT       NOT NULL,
    [Compliance_View_IN_Repo]   TINYINT       NOT NULL,
    [DUE_DATE]                  VARCHAR (100) NOT NULL,
    [DUE_MONTH]                 VARCHAR (100) NULL,
    [TO_EMAIL]                  VARCHAR (300) NULL,
    [CC_EMAIL]                  VARCHAR (300) NULL,
    CONSTRAINT [PK_T0050_COMPLIANCE_MASTER] PRIMARY KEY CLUSTERED ([Compliance_ID] ASC) WITH (FILLFACTOR = 80)
);

