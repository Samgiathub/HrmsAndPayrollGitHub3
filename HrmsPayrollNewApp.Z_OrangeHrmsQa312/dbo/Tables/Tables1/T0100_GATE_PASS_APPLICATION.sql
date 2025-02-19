CREATE TABLE [dbo].[T0100_GATE_PASS_APPLICATION] (
    [App_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Emp_ID]          NUMERIC (18)  NOT NULL,
    [App_Date]        DATETIME      NOT NULL,
    [For_Date]        DATETIME      NOT NULL,
    [From_Time]       DATETIME      NOT NULL,
    [To_Time]         DATETIME      NOT NULL,
    [Duration]        VARCHAR (10)  NOT NULL,
    [Reason_ID]       NUMERIC (18)  NOT NULL,
    [Remarks]         VARCHAR (250) NULL,
    [App_User_ID]     NUMERIC (18)  NULL,
    [System_Datetime] DATETIME      NULL,
    [App_Status]      CHAR (1)      NULL,
    CONSTRAINT [PK_T0100_GATE_PASS_APPLICATION] PRIMARY KEY CLUSTERED ([App_ID] ASC),
    CONSTRAINT [FK_T0100_GATE_PASS_APPLICATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_GATE_PASS_APPLICATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

