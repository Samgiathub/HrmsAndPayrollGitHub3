CREATE TABLE [dbo].[T0090_EMP_DOC_DETAIL_Clone] (
    [Row_ID]       NUMERIC (18)  NOT NULL,
    [Emp_ID]       NUMERIC (18)  NOT NULL,
    [Cmp_ID]       NUMERIC (18)  NOT NULL,
    [Doc_ID]       NUMERIC (18)  NOT NULL,
    [Doc_Path]     VARCHAR (500) NOT NULL,
    [Doc_Comments] VARCHAR (250) NOT NULL,
    [System_Date]  DATETIME      NOT NULL,
    [Login_Id]     NUMERIC (18)  NOT NULL
);

