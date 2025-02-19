CREATE TABLE [dbo].[T0500_Lead_Type] (
    [Lead_Type_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Lead_Type_Name] VARCHAR (100) NULL,
    [Cmp_ID]         NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Lead_Type_ID] ASC)
);

