CREATE TABLE [dbo].[T0115_GATE_PASS_LEVEL_APPROVAL] (
    [Tran_ID]         NUMERIC (18)  NOT NULL,
    [App_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Emp_ID]          NUMERIC (18)  NOT NULL,
    [Apr_Date]        DATETIME      NOT NULL,
    [For_Date]        DATETIME      NOT NULL,
    [From_Time]       DATETIME      NOT NULL,
    [To_Time]         DATETIME      NOT NULL,
    [Duration]        VARCHAR (10)  NOT NULL,
    [Reason_ID]       NUMERIC (18)  NOT NULL,
    [Apr_Remarks]     VARCHAR (250) NULL,
    [Apr_User_ID]     NUMERIC (18)  NULL,
    [System_Datetime] DATETIME      NULL,
    [Apr_Status]      CHAR (1)      NULL,
    [S_Emp_ID]        NUMERIC (18)  NOT NULL,
    [Rpt_Level]       NUMERIC (18)  NOT NULL,
    CONSTRAINT [PK_T0115_GATE_PASS_LEVEL_APPROVAL] PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK_T0115_GATE_PASS_LEVEL_APPROVAL_T0100_GATE_PASS_APPLICATION] FOREIGN KEY ([App_ID]) REFERENCES [dbo].[T0100_GATE_PASS_APPLICATION] ([App_ID])
);

