CREATE TABLE [dbo].[Emp_PresentOnWeekoff] (
    [Row_ID]         NUMERIC (18) NULL,
    [Emp_ID]         NUMERIC (18) NULL,
    [For_Date]       DATETIME     NULL,
    [PresOnWeek_Day] NUMERIC (18) NULL
);


GO
CREATE CLUSTERED INDEX [IX_Emp_PresentOnWeekoff]
    ON [dbo].[Emp_PresentOnWeekoff]([Emp_ID] ASC, [For_Date] ASC) WITH (FILLFACTOR = 95);

