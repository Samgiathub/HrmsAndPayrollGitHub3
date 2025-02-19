CREATE TABLE [dbo].[Emp_PresentOnHoliday] (
    [Row_ID]        NUMERIC (18) NULL,
    [Emp_ID]        NUMERIC (18) NULL,
    [For_Date]      DATETIME     NULL,
    [PresOnHol_Day] NUMERIC (18) NULL
);


GO
CREATE CLUSTERED INDEX [IX_Emp_PresentOnHoliday]
    ON [dbo].[Emp_PresentOnHoliday]([Emp_ID] ASC, [For_Date] ASC) WITH (FILLFACTOR = 95);

