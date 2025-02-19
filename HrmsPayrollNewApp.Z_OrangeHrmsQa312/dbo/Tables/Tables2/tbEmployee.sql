CREATE TABLE [dbo].[tbEmployee] (
    [EmployeeId]   INT          NOT NULL,
    [EmployeeName] VARCHAR (50) NULL,
    [ManagerId]    INT          NULL,
    PRIMARY KEY CLUSTERED ([EmployeeId] ASC) WITH (FILLFACTOR = 95)
);

