CREATE TABLE [dbo].[Default_Report_Fromat] (
    [Trans_ID]    NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_ID]      NUMERIC (18)  NULL,
    [UserID]      NUMERIC (18)  NULL,
    [Report_ID]   NUMERIC (18)  NULL,
    [Report_Name] VARCHAR (500) NULL,
    [ddlformat]   VARCHAR (500) NULL,
    [ddl_Type]    VARCHAR (500) NULL,
    [sys_date]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC)
);

