CREATE TABLE [dbo].[T0250_CUSTOMIZED_REPORT] (
    [ReportID]   INT           NULL,
    [ReportName] VARCHAR (128) NULL,
    [TypeID]     INT           NULL,
    [ReportType] VARCHAR (128) NULL,
    [Form_ID]    INT           NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0250_CUSTOMIZED_REPORT]
    ON [dbo].[T0250_CUSTOMIZED_REPORT]([TypeID] ASC, [ReportID] ASC);

