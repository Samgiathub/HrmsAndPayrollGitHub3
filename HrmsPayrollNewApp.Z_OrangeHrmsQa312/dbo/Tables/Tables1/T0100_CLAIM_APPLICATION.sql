CREATE TABLE [dbo].[T0100_CLAIM_APPLICATION] (
    [Claim_App_ID]          NUMERIC (18)    NOT NULL,
    [Cmp_ID]                NUMERIC (18)    NOT NULL,
    [Claim_ID]              NUMERIC (18)    NOT NULL,
    [Emp_ID]                NUMERIC (18)    NOT NULL,
    [Claim_App_Date]        DATETIME        NOT NULL,
    [Claim_App_Code]        VARCHAR (20)    NOT NULL,
    [Claim_App_Amount]      NUMERIC (18)    NOT NULL,
    [Claim_App_Description] VARCHAR (250)   NOT NULL,
    [Claim_App_Doc]         VARCHAR (MAX)   NOT NULL,
    [Claim_App_Status]      CHAR (1)        CONSTRAINT [DF_T0100_CLAIM_APPLICATION_Claim_App_Status] DEFAULT ((0)) NULL,
    [S_Emp_ID]              NUMERIC (18)    CONSTRAINT [DF__T0100_CLA__S_Emp__21BC6015] DEFAULT (NULL) NULL,
    [Submit_Flag]           TINYINT         CONSTRAINT [DF__T0100_CLA__Submi__68A7D6FD] DEFAULT ((0)) NOT NULL,
    [Transaction_By]        NUMERIC (18, 2) NULL,
    [Transaction_Date]      DATETIME        NULL,
    [Is_Mobile_Entry]       TINYINT         NULL,
    [Terms_isAccepted]      BIT             NULL,
    [Claim_TermsCondition]  VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0100_CLAIM_APPLICATION] PRIMARY KEY CLUSTERED ([Claim_App_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_CLAIM_APPLICATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_CLAIM_APPLICATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_CLAIM_APPLICATION_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

