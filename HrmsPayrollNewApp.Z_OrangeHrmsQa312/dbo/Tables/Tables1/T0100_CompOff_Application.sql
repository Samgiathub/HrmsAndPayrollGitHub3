CREATE TABLE [dbo].[T0100_CompOff_Application] (
    [Compoff_App_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]             NUMERIC (18)  NOT NULL,
    [Emp_ID]             NUMERIC (18)  NOT NULL,
    [S_Emp_ID]           NUMERIC (18)  NULL,
    [Application_Date]   DATETIME      NOT NULL,
    [Extra_Work_Date]    DATETIME      NOT NULL,
    [Extra_Work_Hours]   VARCHAR (10)  NOT NULL,
    [Application_Status] CHAR (1)      NOT NULL,
    [Extra_Work_Reason]  VARCHAR (250) NOT NULL,
    [Login_ID]           NUMERIC (18)  NOT NULL,
    [System_Datetime]    DATETIME      NOT NULL,
    [CompOff_Type]       VARCHAR (2)   NULL,
    [OT_TYPE]            TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_CompOff_Application] PRIMARY KEY CLUSTERED ([Compoff_App_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_CompOff_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_CompOff_Application_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_CompOff_Application_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0100_Compoff_Application_Index]
    ON [dbo].[T0100_CompOff_Application]([Cmp_ID] ASC, [Emp_ID] ASC, [Application_Date] ASC, [Extra_Work_Date] ASC) WITH (FILLFACTOR = 80);

