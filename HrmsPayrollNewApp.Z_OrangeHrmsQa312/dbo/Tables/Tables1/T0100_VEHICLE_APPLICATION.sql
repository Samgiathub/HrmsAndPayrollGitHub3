CREATE TABLE [dbo].[T0100_VEHICLE_APPLICATION] (
    [Vehicle_App_ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]                   NUMERIC (18)   NOT NULL,
    [Emp_ID]                   NUMERIC (18)   NOT NULL,
    [Vehicle_ID]               INT            NOT NULL,
    [Manufacture_Year]         INT            NOT NULL,
    [Max_Limit]                FLOAT (53)     NOT NULL,
    [Initial_Emp_Contribution] FLOAT (53)     NOT NULL,
    [Vehicle_Cost]             FLOAT (53)     NOT NULL,
    [Employee_Share]           FLOAT (53)     NOT NULL,
    [Attachment]               VARCHAR (5000) NULL,
    [App_Status]               VARCHAR (25)   NOT NULL,
    [Vehicle_App_Date]         DATETIME       NULL,
    [Transaction_By]           INT            NULL,
    [Transaction_Date]         DATETIME       NULL,
    [Vehicle_Model]            VARCHAR (500)  DEFAULT ('') NOT NULL,
    [Vehicle_Manufacture]      VARCHAR (500)  DEFAULT ('') NOT NULL,
    [Vehicle_Option]           VARCHAR (100)  NULL,
    CONSTRAINT [PK_T0100_VEHICLE_APPLICATION] PRIMARY KEY CLUSTERED ([Vehicle_App_ID] ASC),
    CONSTRAINT [FK_T0100_VEHICLE_APPLICATION_T0040_VEHICLE_TYPE_MASTER] FOREIGN KEY ([Vehicle_ID]) REFERENCES [dbo].[T0040_VEHICLE_TYPE_MASTER] ([Vehicle_ID]),
    CONSTRAINT [FK_T0100_VEHICLE_APPLICATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

