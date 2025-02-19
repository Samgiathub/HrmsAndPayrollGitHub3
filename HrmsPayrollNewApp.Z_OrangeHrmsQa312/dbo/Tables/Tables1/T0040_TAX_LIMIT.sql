CREATE TABLE [dbo].[T0040_TAX_LIMIT] (
    [IT_L_ID]           NUMERIC (18)   NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NOT NULL,
    [For_Date]          DATETIME       NOT NULL,
    [Gender]            CHAR (1)       NOT NULL,
    [From_Limit]        NUMERIC (18)   NOT NULL,
    [To_Limit]          NUMERIC (18)   NOT NULL,
    [Percentage]        NUMERIC (7, 2) NOT NULL,
    [Additional_Amount] NUMERIC (18)   NOT NULL,
    [Login_ID]          NUMERIC (18)   NULL,
    [System_Date]       DATETIME       NULL,
    [Regime]            VARCHAR (15)   NULL,
    CONSTRAINT [PK_T0040_TAX_LIMIT] PRIMARY KEY CLUSTERED ([IT_L_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_TAX_LIMIT_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_TAX_LIMIT_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_TAX_LIMIT]
    ON [dbo].[T0040_TAX_LIMIT]([Gender] ASC, [Cmp_ID] ASC, [From_Limit] ASC, [To_Limit] ASC) WITH (FILLFACTOR = 80);

