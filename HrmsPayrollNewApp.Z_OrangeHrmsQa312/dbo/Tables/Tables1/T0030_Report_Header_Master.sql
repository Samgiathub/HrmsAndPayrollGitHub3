CREATE TABLE [dbo].[T0030_Report_Header_Master] (
    [Report_Id]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]             NUMERIC (18)   NULL,
    [Report_Header_Name] VARCHAR (2000) NULL,
    [Systemdate]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Report_Id] ASC) WITH (FILLFACTOR = 80)
);

