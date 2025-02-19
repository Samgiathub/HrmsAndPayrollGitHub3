CREATE TABLE [dbo].[T0240_Default_Report] (
    [Rpt_ID]      INT           IDENTITY (1, 1) NOT NULL,
    [Report_Name] VARCHAR (500) NOT NULL,
    [Rpt_Alias]   VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_T0240_Default_Report] PRIMARY KEY CLUSTERED ([Rpt_ID] ASC) WITH (FILLFACTOR = 80)
);

