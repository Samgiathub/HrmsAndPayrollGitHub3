CREATE TABLE [dbo].[T0050_Travel_Tax_Component_Master] (
    [Tran_ID]           NUMERIC (18)    NOT NULL,
    [Tax_Cmponent_Name] VARCHAR (100)   NOT NULL,
    [Tax_Per]           NUMERIC (18, 2) NOT NULL,
    [Remarks]           VARCHAR (500)   NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Modify_Date]       DATETIME        CONSTRAINT [DF_T0050_Travel_Tax_Component_Master_Modify_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0050_Travel_Tax_Component_Master] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

