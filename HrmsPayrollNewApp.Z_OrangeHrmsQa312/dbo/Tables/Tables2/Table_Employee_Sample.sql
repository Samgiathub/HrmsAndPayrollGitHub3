CREATE TABLE [dbo].[Table_Employee_Sample] (
    [Emp_Id]       INT           NOT NULL,
    [Cmp_Id]       INT           NULL,
    [Emp_FullName] VARCHAR (200) NULL,
    [Salary]       FLOAT (53)    NULL,
    [Age]          INT           NULL,
    [Designation]  VARCHAR (200) NULL,
    [Department]   VARCHAR (200) NULL,
    CONSTRAINT [PK_Table_Employee_Sample] PRIMARY KEY CLUSTERED ([Emp_Id] ASC) WITH (FILLFACTOR = 95)
);

