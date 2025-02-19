CREATE TABLE [dbo].[T0500_Lead_Visit_Type] (
    [Visit_Type_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Visit_Type_Name] VARCHAR (100) NULL,
    [Cmp_ID]          NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Visit_Type_ID] ASC)
);

