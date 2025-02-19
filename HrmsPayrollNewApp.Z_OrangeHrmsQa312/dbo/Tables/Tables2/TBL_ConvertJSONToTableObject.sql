CREATE TABLE [dbo].[TBL_ConvertJSONToTableObject] (
    [EmployeeID] INT           NOT NULL,
    [EmpCode]    VARCHAR (200) NULL,
    [DayInDate]  VARCHAR (200) NULL,
    [DayInTime]  VARCHAR (200) NULL,
    [DayOutDate] VARCHAR (200) NULL,
    [DayOutTime] VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC) WITH (FILLFACTOR = 95)
);

