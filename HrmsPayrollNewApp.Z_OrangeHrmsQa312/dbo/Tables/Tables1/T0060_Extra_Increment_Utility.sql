CREATE TABLE [dbo].[T0060_Extra_Increment_Utility] (
    [Extra_Increment_Utility_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]                     NUMERIC (18)    NOT NULL,
    [EffectiveDate]              DATETIME        NOT NULL,
    [EligibleType]               TINYINT         NOT NULL,
    [Res_Id]                     INT             NOT NULL,
    [Emp_Id]                     NUMERIC (18)    NOT NULL,
    [Amount]                     NUMERIC (18, 2) NOT NULL,
    [Appraisal_From]             DATETIME        NULL,
    [Appraisal_To]               DATETIME        NULL,
    CONSTRAINT [PK_T0060_Extra_Increment_Utility] PRIMARY KEY CLUSTERED ([Extra_Increment_Utility_Id] ASC),
    CONSTRAINT [FK_T0060_Extra_Increment_Utility_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_Extra_Increment_Utility_T0040_Reason_Master] FOREIGN KEY ([Res_Id]) REFERENCES [dbo].[T0040_Reason_Master] ([Res_Id]),
    CONSTRAINT [FK_T0060_Extra_Increment_Utility_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

