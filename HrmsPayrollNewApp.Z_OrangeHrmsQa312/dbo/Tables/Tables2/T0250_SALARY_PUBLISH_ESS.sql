CREATE TABLE [dbo].[T0250_SALARY_PUBLISH_ESS] (
    [Publish_ID]  NUMERIC (18)  NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NOT NULL,
    [Branch_ID]   NUMERIC (18)  NULL,
    [Month]       NUMERIC (5)   NOT NULL,
    [Year]        NUMERIC (5)   NULL,
    [Is_Publish]  NUMERIC (1)   CONSTRAINT [DF_Table_1_Is_Lock] DEFAULT ((0)) NOT NULL,
    [User_ID]     NUMERIC (18)  NOT NULL,
    [System_Date] DATETIME      NOT NULL,
    [Emp_ID]      NUMERIC (18)  CONSTRAINT [DF_T0250_SALARY_PUBLISH_ESS_Emp_ID] DEFAULT ((0)) NOT NULL,
    [Comments]    VARCHAR (MAX) NULL,
    [Sal_Type]    VARCHAR (12)  DEFAULT ('Salary') NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_T0250_SALARY_PUBLISH_ESS_Cmp_ID_Month_Year_Emp_ID]
    ON [dbo].[T0250_SALARY_PUBLISH_ESS]([Cmp_ID] ASC, [Month] ASC, [Year] ASC, [Emp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0250_SALARY_PUBLISH_ESS_SP_IT_TAX_PREPARATION]
    ON [dbo].[T0250_SALARY_PUBLISH_ESS]([Sal_Type] ASC)
    INCLUDE([Month], [Year], [Is_Publish], [Emp_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0250_SALARY_PUBLISH_ESS_SP_IT_TAX_PREPARATION1]
    ON [dbo].[T0250_SALARY_PUBLISH_ESS]([Month] ASC, [Year] ASC, [Emp_ID] ASC, [Sal_Type] ASC)
    INCLUDE([Is_Publish]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Login_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'T0250_SALARY_PUBLISH_ESS', @level2type = N'COLUMN', @level2name = N'User_ID';

