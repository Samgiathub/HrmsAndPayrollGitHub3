CREATE TABLE [dbo].[T0500_Lead_Status] (
    [Lead_Status_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Lead_Status_Name] VARCHAR (100) NULL,
    [Cmp_ID]           NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Lead_Status_ID] ASC)
);

