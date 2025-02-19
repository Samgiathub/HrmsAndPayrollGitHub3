CREATE TABLE [dbo].[T0080_Import_Log] (
    [Im_Id]        NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Row_No]       NUMERIC (18)   NOT NULL,
    [Cmp_Id]       NUMERIC (18)   NOT NULL,
    [Emp_Code]     VARCHAR (30)   NULL,
    [Error_Desc]   VARCHAR (500)  NULL,
    [Actual_Value] VARCHAR (100)  NULL,
    [Suggestion]   VARCHAR (100)  NULL,
    [For_Date]     DATETIME       NULL,
    [Import_type]  VARCHAR (100)  NULL,
    [KeyGUID]      VARCHAR (2000) NULL,
    CONSTRAINT [PK_T0080_Import_Log] PRIMARY KEY CLUSTERED ([Im_Id] ASC) WITH (FILLFACTOR = 80)
);

