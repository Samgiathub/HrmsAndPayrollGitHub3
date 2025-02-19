CREATE TABLE [dbo].[T9999_Bank_Transfer_Export] (
    [Cmp_ID]        NUMERIC (18)   NOT NULL,
    [Emp_ID]        NUMERIC (18)   NOT NULL,
    [Emp_Full_Name] NVARCHAR (500) NOT NULL,
    [Month]         VARCHAR (10)   NOT NULL,
    [Year]          NUMERIC (18)   NOT NULL,
    [Generate_Date] DATETIME       NOT NULL,
    [File_Name]     VARCHAR (30)   NOT NULL,
    [Regerate_Flag] NVARCHAR (10)  NULL,
    [Reason]        NVARCHAR (MAX) NULL,
    [Modified_By]   NUMERIC (18)   NULL,
    [Modified_Date] DATETIME       NULL,
    [Flag]          CHAR (1)       NULL
);

