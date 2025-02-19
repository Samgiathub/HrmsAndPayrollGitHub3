CREATE TABLE [dbo].[T0100_TS_Application] (
    [Timesheet_ID]      NUMERIC (18)  NOT NULL,
    [Employee_ID]       NUMERIC (18)  NULL,
    [Timesheet_Period]  VARCHAR (50)  NULL,
    [Timesheet_Type]    VARCHAR (50)  NULL,
    [Entry_Date]        DATETIME      NULL,
    [Total_Time]        VARCHAR (50)  NULL,
    [Project_Status_ID] NUMERIC (18)  NULL,
    [Project_ID]        NUMERIC (18)  NULL,
    [Task_ID]           NUMERIC (18)  NULL,
    [Description]       VARCHAR (MAX) NULL,
    [Cmp_ID]            NUMERIC (18)  NULL,
    [Created_By]        NUMERIC (18)  NULL,
    [Created_Date]      DATETIME      NULL,
    [Modify_By]         NUMERIC (18)  NULL,
    [Modify_Date]       DATETIME      NULL,
    [Attachment]        VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0100_TS_Application] PRIMARY KEY CLUSTERED ([Timesheet_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_TS_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_TS_Application_T0040_Project_Status] FOREIGN KEY ([Project_Status_ID]) REFERENCES [dbo].[T0040_Project_Status] ([Project_Status_ID]),
    CONSTRAINT [FK_T0100_TS_Application_T0080_EMP_MASTER] FOREIGN KEY ([Employee_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

