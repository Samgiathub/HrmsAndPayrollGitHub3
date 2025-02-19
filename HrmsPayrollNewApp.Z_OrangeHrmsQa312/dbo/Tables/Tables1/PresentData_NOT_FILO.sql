CREATE TABLE [dbo].[PresentData_NOT_FILO] (
    [Emp_Id]   NUMERIC (18) NULL,
    [For_date] DATETIME     NULL,
    [Diff_Sec] NUMERIC (18) NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_Data_temp1_Diff_Emp_Id_For_date]
    ON [dbo].[PresentData_NOT_FILO]([Emp_Id] ASC, [For_date] ASC) WITH (FILLFACTOR = 95);

