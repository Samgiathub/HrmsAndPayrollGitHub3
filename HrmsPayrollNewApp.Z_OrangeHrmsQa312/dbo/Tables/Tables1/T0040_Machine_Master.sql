CREATE TABLE [dbo].[T0040_Machine_Master] (
    [Machine_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]       NUMERIC (18)  NOT NULL,
    [Machine_Name] VARCHAR (100) NOT NULL,
    [Machine_Code] VARCHAR (50)  NOT NULL,
    [Machine_Type] VARCHAR (50)  NULL,
    [Remarks]      VARCHAR (100) NULL,
    CONSTRAINT [PK_T0040_Machine_Master] PRIMARY KEY CLUSTERED ([Machine_ID] ASC)
);

