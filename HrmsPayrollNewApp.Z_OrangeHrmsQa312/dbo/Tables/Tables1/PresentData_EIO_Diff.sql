CREATE TABLE [dbo].[PresentData_EIO_Diff] (
    [Emp_Id]   NUMERIC (18) NULL,
    [For_date] DATETIME     NULL,
    [Out_Time] DATETIME     NULL,
    [In_Time]  DATETIME     NULL,
    [Diff_Sec] NUMERIC (18) NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_Data_temp1_Diff_Emp_Id_For_date]
    ON [dbo].[PresentData_EIO_Diff]([Emp_Id] ASC, [For_date] ASC, [In_Time] ASC) WITH (FILLFACTOR = 95);

