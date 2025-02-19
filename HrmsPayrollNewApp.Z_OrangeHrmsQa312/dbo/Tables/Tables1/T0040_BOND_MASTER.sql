CREATE TABLE [dbo].[T0040_BOND_MASTER] (
    [Bond_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Bond_Name]         VARCHAR (100)   NOT NULL,
    [Bond_Short_Name]   VARCHAR (50)    NOT NULL,
    [Bond_Amount]       NUMERIC (18, 2) NULL,
    [No_of_Installment] INT             NULL,
    [Bond_Comments]     VARCHAR (250)   NULL,
    [Grade_Details]     VARCHAR (500)   NULL,
    CONSTRAINT [PK_T0040_BOND_MASTER] PRIMARY KEY CLUSTERED ([Bond_ID] ASC)
);

