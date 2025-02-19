CREATE TABLE [dbo].[T0090_Emp_Medical_Checkup] (
    [Tran_Id]     NUMERIC (18)   NOT NULL,
    [cmp_Id]      NUMERIC (18)   NOT NULL,
    [Emp_Id]      NUMERIC (18)   NOT NULL,
    [Medical_ID]  NUMERIC (18)   NOT NULL,
    [For_Date]    DATETIME       NOT NULL,
    [Description] NVARCHAR (MAX) NULL
);

