CREATE TABLE [dbo].[T0090_EMP_ASSET_DETAIL_Clone] (
    [Emp_Asset_ID]  NUMERIC (18)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NOT NULL,
    [Emp_ID]        NUMERIC (18)  NOT NULL,
    [Asset_ID]      NUMERIC (18)  NOT NULL,
    [Model_No]      VARCHAR (20)  NOT NULL,
    [Issue_Date]    DATETIME      NOT NULL,
    [Return_Date]   DATETIME      NULL,
    [Asset_Comment] VARCHAR (150) NULL,
    [System_Date]   DATETIME      NOT NULL,
    [login_Id]      NUMERIC (18)  NOT NULL
);

